#ifndef SERIALPORTMANAGER_H
#define SERIALPORTMANAGER_H

#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QVector>
#include <QTimer>
#include <QDebug>

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
    bool isConnected() const;
    QStringList availablePorts() const;
    QString currentPort() const;
    void setCurrentPort(const QString &port);
    QVector<bool> lightStatus() const;

    // Q_INVOKABLE方法 - 可从QML调用
    Q_INVOKABLE bool connectToPort();
    Q_INVOKABLE bool disconnectFromPort();
    Q_INVOKABLE bool refreshPorts();
    Q_INVOKABLE bool toggleLight(int lightIndex, bool state);
    Q_INVOKABLE bool toggleLights(const QVector<bool> &states);
    Q_INVOKABLE bool getAllLightStatus();

signals:
    void connectionStatusChanged();
    void availablePortsChanged();
    void currentPortChanged();
    void lightStatusChanged();
    void serialError(const QString &errorMessage);
    void serialMessage(const QString &message);
    void dataReceived(const QByteArray &data);

private slots:
    void handleReadyRead();
    void handleError(QSerialPort::SerialPortError error);
    void processNextCommand();

private:
    QSerialPort *m_serialPort;
    QString m_currentPort;
    QStringList m_availablePorts;
    QVector<bool> m_lightStatus;
    QVector<QByteArray> m_commandQueue;
    QTimer m_commandTimer;
    bool m_busy;

    // 私有方法
    bool sendCommand(const QByteArray &command);
    void enqueueCommand(const QByteArray &command);
    QByteArray createLightCommand(int lightIndex, bool state);
    quint8 calculateChecksum(const QByteArray &data);
    void parseStatusResponse(const QByteArray &response);
};

#endif // SERIALPORTMANAGER_H 