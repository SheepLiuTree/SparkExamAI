#include "LogManager.h"
#include <QCoreApplication>
#include <QDebug>
#include <QStringConverter>

// 初始化静态成员
LogManager* LogManager::instance = nullptr;

LogManager::LogManager(QObject *parent) : QObject(parent)
{
}

LogManager::~LogManager()
{
    if (logFile.isOpen()) {
        logStream.flush();
        logFile.close();
    }
}

LogManager& LogManager::getInstance()
{
    if (instance == nullptr) {
        instance = new LogManager();
    }
    return *instance;
}

void LogManager::init(const QString& logDir)
{
    logDirectory = logDir;
    createLogDirectory(logDirectory);
    
    // 打开日志文件
    QString logPath = getLogFilePath();
    logFile.setFileName(logPath);
    if (logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        logStream.setDevice(&logFile);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        logStream.setCodec("UTF-8");
#else
        logStream.setEncoding(QStringConverter::Utf8);
#endif
    } else {
        qWarning() << "无法打开日志文件:" << logPath;
    }
}

void LogManager::installMessageHandler()
{
    qInstallMessageHandler(messageHandler);
}

void LogManager::uninstallMessageHandler()
{
    qInstallMessageHandler(nullptr);
}

void LogManager::messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QString txt;
    switch (type) {
    case QtDebugMsg:
        txt = QString("Debug: %1").arg(msg);
        break;
    case QtWarningMsg:
        txt = QString("Warning: %1").arg(msg);
        break;
    case QtCriticalMsg:
        txt = QString("Critical: %1").arg(msg);
        break;
    case QtFatalMsg:
        txt = QString("Fatal: %1").arg(msg);
        break;
    case QtInfoMsg:
        txt = QString("Info: %1").arg(msg);
        break;
    }

    // 添加时间戳和上下文信息
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz");
    QString logMessage = QString("[%1] %2 (%3:%4, %5)\n")
                            .arg(timestamp)
                            .arg(txt)
                            .arg(context.file)
                            .arg(context.line)
                            .arg(context.function);

    // 写入日志文件
    if (instance && instance->logFile.isOpen()) {
        instance->logStream << logMessage;
        instance->logStream.flush();
    }

    // 同时输出到控制台
    fprintf(stderr, "%s", logMessage.toLocal8Bit().constData());
}

QString LogManager::getLogFilePath() const
{
    QString dateStr = QDateTime::currentDateTime().toString("yyyy-MM-dd");
    return QString("%1/%2.log").arg(logDirectory).arg(dateStr);
}

void LogManager::createLogDirectory(const QString& path)
{
    QDir dir;
    if (!dir.exists(path)) {
        dir.mkpath(path);
    }
} 