#include "SerialPortManager.h"
#include <QDebug>
#include "DatabaseManager.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QTimer>

SerialPortManager::SerialPortManager(QObject *parent)
    : QObject(parent)
    , m_serialPort(new QSerialPort(this))
    , m_busy(false)
{
    // 初始化灯光状态，默认都为关闭
    m_lightStatus.resize(8);
    for (int i = 0; i < m_lightStatus.size(); ++i) {
        m_lightStatus[i] = false;
    }

    // 连接信号槽
    connect(m_serialPort, &QSerialPort::readyRead, this, &SerialPortManager::handleReadyRead);
    connect(m_serialPort, &QSerialPort::errorOccurred, this, &SerialPortManager::handleError);
    
    // 设置命令队列定时器
    connect(&m_commandTimer, &QTimer::timeout, this, &SerialPortManager::processNextCommand);
    m_commandTimer.setInterval(1); // 1微秒间隔
    
    // 初始加载可用端口
    refreshPorts();
    
    // 从数据库加载串口设置并连接
    DatabaseManager dbManager;
    QString savedPort = dbManager.getSetting("serial_port", "auto");
    if (savedPort != "auto") {
        m_currentPort = savedPort;
        emit currentPortChanged();
        
        // 尝试连接串口
        connectToPort();        
    }
}

SerialPortManager::~SerialPortManager()
{
    if (m_serialPort->isOpen()) {
        m_serialPort->close();
    }
    delete m_serialPort;
}

bool SerialPortManager::isConnected() const
{
    return m_serialPort->isOpen();
}

QStringList SerialPortManager::availablePorts() const
{
    return m_availablePorts;
}

QString SerialPortManager::currentPort() const
{
    return m_currentPort;
}

void SerialPortManager::setCurrentPort(const QString &port)
{
    if (m_currentPort != port) {
        m_currentPort = port;
        emit currentPortChanged();
    }
}

QVector<bool> SerialPortManager::lightStatus() const
{
    return m_lightStatus;
}

bool SerialPortManager::refreshPorts()
{
    m_availablePorts.clear();
    
    const auto serialPortInfos = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : serialPortInfos) {
        m_availablePorts.append(info.portName());
    }
    
    emit availablePortsChanged();
    
    // 如果当前选择的端口不在可用端口列表中，则清空当前选择
    if (!m_availablePorts.contains(m_currentPort) && !m_currentPort.isEmpty()) {
        m_currentPort.clear();
        emit currentPortChanged();
    }
    
    return !m_availablePorts.isEmpty();
}

bool SerialPortManager::connectToPort()
{
    if (m_currentPort.isEmpty()) {
        // 如果当前没有选择端口，尝试从数据库读取
        DatabaseManager dbManager;
        QString savedPort = dbManager.getSetting("serial_port", "auto");
        if (savedPort != "auto") {
            m_currentPort = savedPort;
            emit currentPortChanged();
        } else {
            emit serialError("未选择串口");
            return false;
        }
    }
    
    if (m_serialPort->isOpen()) {
        m_serialPort->close();
    }
    
    m_serialPort->setPortName(m_currentPort);
    m_serialPort->setBaudRate(QSerialPort::Baud9600);
    m_serialPort->setDataBits(QSerialPort::Data8);
    m_serialPort->setParity(QSerialPort::NoParity);
    m_serialPort->setStopBits(QSerialPort::OneStop);
    m_serialPort->setFlowControl(QSerialPort::NoFlowControl);
    
    if (m_serialPort->open(QIODevice::ReadWrite)) {
        emit connectionStatusChanged();
        emit serialMessage("已连接到串口：" + m_currentPort);
        
        // 连接后立即获取所有灯的状态
        getAllLightStatus();
        return true;
    } else {
        emit serialError("无法打开串口：" + m_serialPort->errorString());
        return false;
    }
}

bool SerialPortManager::disconnectFromPort()
{
    if (m_serialPort->isOpen()) {
        m_serialPort->close();
        emit connectionStatusChanged();
        emit serialMessage("已断开串口连接");
        return true;
    }
    return false;
}

bool SerialPortManager::toggleLight(int lightIndex, bool state)
{
    if (!m_serialPort->isOpen()) {
        emit serialError("串口未连接");
        return false;
    }
    
    // 检查灯光索引是否有效（1-6）
    if (lightIndex < 1 || lightIndex > 6) {
        emit serialError("无效的灯光索引: " + QString::number(lightIndex));
        return false;
    }
    
    // 创建并发送命令
    QByteArray command = createLightCommand(lightIndex, state);
    enqueueCommand(command, 0);  // 单灯控制不需要延时
    
    // 更新本地状态（实际状态在接收到响应后更新）
    m_lightStatus[lightIndex - 1] = state;
    emit lightStatusChanged();
    
    return true;
}

bool SerialPortManager::toggleLights(const QString &jsonControls)
{
    if (!m_serialPort->isOpen()) {
        emit serialError("串口未连接");
        return false;
    }
    
    // 解析JSON字符串
    QJsonDocument doc = QJsonDocument::fromJson(jsonControls.toUtf8());
    if (doc.isNull() || !doc.isArray()) {
        emit serialError("无效的JSON格式");
        return false;
    }
    
    QJsonArray controls = doc.array();
    if (controls.isEmpty()) {
        emit serialError("灯光控制序列为空");
        return false;
    }
    
    // 验证每个控制命令的有效性
    for (const QJsonValue &value : controls) {
        if (!value.isObject()) {
            emit serialError("无效的控制命令格式");
            return false;
        }
        
        QJsonObject control = value.toObject();
        int lightIndex = control["lightIndex"].toInt();
        bool state = control["state"].toBool();
        int delay = control["delay"].toInt();
        
        if (lightIndex < 1 || lightIndex > 6) {
            emit serialError(QString("无效的灯光索引: %1").arg(lightIndex));
            return false;
        }
        if (delay < 0) {
            emit serialError(QString("无效的延时时间: %1").arg(delay));
            return false;
        }
    }
    
    // 清空现有命令队列
    m_commandQueue.clear();
    
    // 创建命令序列
    for (int i = 0; i < controls.size(); ++i) {
        QJsonObject control = controls[i].toObject();
        int lightIndex = control["lightIndex"].toInt();
        bool state = control["state"].toBool();
        int delay = control["delay"].toInt();
        
        QByteArray command = createLightCommand(lightIndex, state);
        
        // 将命令和延时时间添加到队列
        enqueueCommand(command, delay);
        
        // 输出调试信息
        QString statusStr = QString("添加命令: 灯%1 %2 (延时: %3ms, 序号: %4)")
            .arg(lightIndex)
            .arg(state ? "开" : "关")
            .arg(delay)
            .arg(i + 1);
        emit serialMessage(statusStr);
    }
    
    return true;
}

bool SerialPortManager::getAllLightStatus()
{
    if (!m_serialPort->isOpen()) {
        emit serialError("串口未连接");
        return false;
    }
    
    // 发送FF命令获取所有灯的状态
    QByteArray command;
    command.append(static_cast<char>(0xFF));
    return sendCommand(command);
}

void SerialPortManager::handleReadyRead()
{
    QByteArray data = m_serialPort->readAll();
    emit dataReceived(data);
    
    // 处理接收到的数据
    if (data.size() == 8) {
        // 处理灯光状态返回的8个字节
        parseStatusResponse(data);
    }
}

void SerialPortManager::handleError(QSerialPort::SerialPortError error)
{
    if (error == QSerialPort::NoError) {
        return;
    }
    
    QString errorMsg = "串口错误: ";
    switch (error) {
        case QSerialPort::DeviceNotFoundError:
            errorMsg += "设备未找到";
            break;
        case QSerialPort::PermissionError:
            errorMsg += "权限错误";
            break;
        case QSerialPort::OpenError:
            errorMsg += "打开错误";
            break;
        case QSerialPort::NotOpenError:
            errorMsg += "设备未打开";
            break;
        case QSerialPort::WriteError:
            errorMsg += "写入错误";
            break;
        case QSerialPort::ReadError:
            errorMsg += "读取错误";
            break;
        case QSerialPort::ResourceError:
            errorMsg += "资源错误，串口已断开";
            if (m_serialPort->isOpen()) {
                m_serialPort->close();
                emit connectionStatusChanged();
            }
            break;
        default:
            errorMsg += "未知错误";
            break;
    }
    
    emit serialError(errorMsg);
}

void SerialPortManager::processNextCommand()
{
    if (m_commandQueue.isEmpty() || m_busy) {
        if (m_commandQueue.isEmpty()) {
            m_commandTimer.stop();
        }
        return;
    }
    
    m_busy = true;
    Command cmd = m_commandQueue.takeFirst();
    
    if (sendCommand(cmd.data)) {
        // 命令发送成功后，使用命令中指定的延时时间
        QTimer::singleShot(cmd.delay, this, [this]() {
            m_busy = false;
            // 处理下一个命令
            if (!m_commandQueue.isEmpty()) {
                processNextCommand();
            } else {
                m_commandTimer.stop();
            }
        });
    } else {
        m_busy = false;
        // 如果发送失败，直接处理下一个命令
        if (!m_commandQueue.isEmpty()) {
            QTimer::singleShot(50, this, &SerialPortManager::processNextCommand);
        } else {
            m_commandTimer.stop();
        }
    }
}

bool SerialPortManager::sendCommand(const QByteArray &command)
{
    if (!m_serialPort->isOpen()) {
        emit serialError("串口未连接");
        return false;
    }
    
    qint64 bytesWritten = m_serialPort->write(command);
    if (bytesWritten == -1) {
        emit serialError("发送命令失败: " + m_serialPort->errorString());
        return false;
    } else if (bytesWritten != command.size()) {
        emit serialError("部分命令发送失败");
        return false;
    }
    
    // 输出发送的命令（十六进制格式）
    QString hexString;
    for (char c : command) {
        hexString += QString("%1 ").arg(static_cast<quint8>(c), 2, 16, QChar('0')).toUpper();
    }
    emit serialMessage("发送命令: " + hexString.trimmed());
    
    return m_serialPort->waitForBytesWritten(100);
}

void SerialPortManager::enqueueCommand(const QByteArray &command, int delay)
{
    Command cmd;
    cmd.data = command;
    cmd.delay = delay;
    m_commandQueue.append(cmd);
    
    if (!m_commandTimer.isActive()) {
        m_commandTimer.start();
        
        // 如果当前没有正在处理的命令，立即开始处理
        if (!m_busy) {
            processNextCommand();
        }
    }
}

QByteArray SerialPortManager::createLightCommand(int lightIndex, bool state)
{
    QByteArray command;
    
    // 第一个字节固定为A0
    command.append(static_cast<char>(0xA0));
    
    // 第二个字节为灯的编号(01-08)
    command.append(static_cast<char>(lightIndex));
    
    // 第三个字节为灯的状态(00或01)
    command.append(static_cast<char>(state ? 0x01 : 0x00));
    
    // 第四个字节为校验和(前三个字节的和的低8位)
    quint8 checksum = calculateChecksum(command);
    command.append(static_cast<char>(checksum));
    
    return command;
}

quint8 SerialPortManager::calculateChecksum(const QByteArray &data)
{
    quint8 sum = 0;
    for (int i = 0; i < data.size(); ++i) {
        sum += static_cast<quint8>(data.at(i));
    }
    return sum;
}

void SerialPortManager::parseStatusResponse(const QByteArray &response)
{
    if (response.size() != 8) {
        emit serialError("收到的状态响应长度不正确");
        return;
    }
    
    // 解析8个字节，代表8个灯的状态
    for (int i = 0; i < 8; ++i) {
        m_lightStatus[i] = (response.at(i) != 0);
    }
    
    emit lightStatusChanged();
    
    // 输出状态信息
    QString statusStr = "灯光状态: ";
    for (int i = 0; i < m_lightStatus.size(); ++i) {
        statusStr += QString("灯%1=%2 ").arg(i + 1).arg(m_lightStatus[i] ? "开" : "关");
    }
    emit serialMessage(statusStr);
} 