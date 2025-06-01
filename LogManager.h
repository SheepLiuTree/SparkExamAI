#ifndef LOGMANAGER_H
#define LOGMANAGER_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QDir>

class LogManager : public QObject
{
    Q_OBJECT

public:
    static LogManager& getInstance();
    
    // 初始化日志系统
    void init(const QString& logDir = "logs");
    
    // 安装消息处理器
    void installMessageHandler();
    
    // 卸载消息处理器
    void uninstallMessageHandler();

private:
    explicit LogManager(QObject *parent = nullptr);
    ~LogManager();
    
    // 消息处理函数
    static void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg);
    
    // 获取日志文件路径
    QString getLogFilePath() const;
    
    // 创建日志目录
    void createLogDirectory(const QString& path);
    
    // 单例实例
    static LogManager* instance;
    
    // 日志文件
    QFile logFile;
    QTextStream logStream;
    
    // 日志目录
    QString logDirectory;
};

#endif // LOGMANAGER_H 