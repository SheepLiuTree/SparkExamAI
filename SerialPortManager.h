#ifndef SERIALPORTMANAGER_H
#define SERIALPORTMANAGER_H

#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QVector>
#include <QTimer>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

// 灯光控制结构体
struct LightControl {
    int lightIndex;    // 灯编号(1-6)
    bool state;        // 灯状态(true=开, false=关)
    int delay;         // 延时时间(毫秒)
};

// 命令结构体
struct Command {
    QByteArray data;   // 命令数据
    int delay;         // 延时时间
};

class SerialPortManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionStatusChanged)
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
    Q_PROPERTY(QString currentPort READ currentPort WRITE setCurrentPort NOTIFY currentPortChanged)
    Q_PROPERTY(QVector<bool> lightStatus READ lightStatus NOTIFY lightStatusChanged)

public:
    explicit SerialPortManager(QObject *parent = nullptr);
    ~SerialPortManager();

    // 属性访问函数
    bool isConnected() const;                    // 获取串口连接状态
    QStringList availablePorts() const;          // 获取可用串口列表
    QString currentPort() const;                 // 获取当前选择的串口
    void setCurrentPort(const QString &port);    // 设置当前串口
    QVector<bool> lightStatus() const;           // 获取灯光状态数组

    // Q_INVOKABLE方法 - 可从QML调用
    Q_INVOKABLE bool connectToPort();            // 连接到当前选择的串口
    Q_INVOKABLE bool disconnectFromPort();       // 断开串口连接
    Q_INVOKABLE bool refreshPorts();             // 刷新可用串口列表
    Q_INVOKABLE bool toggleLight(int lightIndex, bool state);  // 控制单个灯光开关
    Q_INVOKABLE bool toggleLights(const QString &jsonControls); // 按序列控制多个灯光
    Q_INVOKABLE bool getAllLightStatus();        // 获取所有灯光状态

signals:
    void connectionStatusChanged();              // 串口连接状态改变信号
    void availablePortsChanged();                // 可用串口列表改变信号
    void currentPortChanged();                   // 当前串口改变信号
    void lightStatusChanged();                   // 灯光状态改变信号
    void serialError(const QString &errorMessage); // 串口错误信号
    void serialMessage(const QString &message);    // 串口消息信号
    void dataReceived(const QByteArray &data);     // 接收到数据信号

private slots:
    void handleReadyRead();                      // 处理串口数据接收
    void handleError(QSerialPort::SerialPortError error); // 处理串口错误
    void processNextCommand();                   // 处理命令队列中的下一个命令

private:
    QSerialPort *m_serialPort;                   // 串口对象
    QString m_currentPort;                       // 当前选择的串口
    QStringList m_availablePorts;                // 可用串口列表
    QVector<bool> m_lightStatus;                 // 灯光状态数组
    QVector<Command> m_commandQueue;             // 命令队列
    QTimer m_commandTimer;                       // 命令处理定时器
    bool m_busy;                                 // 命令处理忙标志

    // 私有方法
    bool sendCommand(const QByteArray &command); // 发送命令到串口
    void enqueueCommand(const QByteArray &command, int delay); // 将命令加入队列
    QByteArray createLightCommand(int lightIndex, bool state); // 创建灯光控制命令
    quint8 calculateChecksum(const QByteArray &data); // 计算校验和
    void parseStatusResponse(const QByteArray &response); // 解析状态响应
};

#endif // SERIALPORTMANAGER_H 