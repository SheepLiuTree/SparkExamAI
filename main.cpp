#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include "FileManager.h"
#include "DatabaseManager.h"
#include "FaceRecognizer.h"

// 检查文件是否存在并输出信息的辅助函数
void checkFileExists(const QString &filePath) {
    QFileInfo fileInfo(filePath);
    qDebug() << "检查文件:" << filePath;
    qDebug() << "  - 存在:" << (fileInfo.exists() ? "是" : "否");
    if (fileInfo.exists()) {
        qDebug() << "  - 大小:" << fileInfo.size() << "字节";
        qDebug() << "  - 权限:" << (fileInfo.isReadable() ? "可读 " : "不可读 ")
                 << (fileInfo.isWritable() ? "可写 " : "不可写 ")
                 << (fileInfo.isExecutable() ? "可执行" : "不可执行");
    }
}

// 检查目录并列出内容的辅助函数
void listDirectoryContents(const QString &dirPath) {
    QDir dir(dirPath);
    if (dir.exists()) {
        qDebug() << "目录内容:" << dirPath;
        QStringList entries = dir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot);
        for (const QString &entry : entries) {
            QFileInfo info(dir.absoluteFilePath(entry));
            qDebug() << "  - " << entry
                     << (info.isDir() ? " [目录]" : "")
                     << (info.isFile() ? " [文件]" : "")
                     << (info.isSymLink() ? " [链接]" : "");
        }
    } else {
        qDebug() << "目录不存在:" << dirPath;
    }
}

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    
    // 详细的启动日志
    qDebug() << "\n\n====================== 应用程序启动 ======================";
    qDebug() << "应用程序路径:" << QCoreApplication::applicationFilePath();
    qDebug() << "应用程序目录:" << QCoreApplication::applicationDirPath();
    qDebug() << "当前工作目录:" << QDir::currentPath();
    
    // 检查环境变量
    qDebug() << "\n----- 环境变量 -----";
    QStringList envVars = QProcess::systemEnvironment();
    for (const QString &var : envVars) {
        if (var.startsWith("PATH=") || var.startsWith("Path=")) {
            qDebug() << var;
        }
    }
    
    // 检查应用程序目录中的模型文件
    qDebug() << "\n----- 模型文件检查 -----";
    QString appDir = QCoreApplication::applicationDirPath();
    // 检查model子目录
    listDirectoryContents(appDir + "/model");
    
    // 检查具体的模型文件
    checkFileExists(appDir + "/model/fd_2_00.dat");
    checkFileExists(appDir + "/model/pd_2_00_pts5.dat");
    checkFileExists(appDir + "/model/fr_2_10.dat");
    
    // 检查根目录中的模型文件（也可能放在这里）
    checkFileExists(appDir + "/fd_2_00.dat");
    checkFileExists(appDir + "/pd_2_00_pts5.dat");
    checkFileExists(appDir + "/fr_2_10.dat");
    
    // 检查DLL文件
    qDebug() << "\n----- DLL文件检查 -----";
    checkFileExists(appDir + "/SeetaFaceDetector.dll");
    checkFileExists(appDir + "/SeetaFaceLandmarker.dll");
    checkFileExists(appDir + "/SeetaFaceRecognizer.dll");
    checkFileExists(appDir + "/SeetaNet.dll");
    
    // 设置应用程序图标
    app.setWindowIcon(QIcon(":/images/SparkExamAI.ico"));
    
    QQmlApplicationEngine engine;
    
    // 创建FileManager实例并注册到QML上下文
    FileManager fileManager;
    engine.rootContext()->setContextProperty("fileManager", &fileManager);
    
    // 创建DatabaseManager实例并注册到QML上下文
    DatabaseManager dbManager;
    if (!dbManager.initDatabase()) {
        qDebug() << "数据库初始化失败";
    }
    engine.rootContext()->setContextProperty("dbManager", &dbManager);
    
    qDebug() << "\n----- 开始初始化人脸识别器 -----";
    // 创建FaceRecognizer实例并注册到QML上下文
    FaceRecognizer faceRecognizer;
    if (!faceRecognizer.initialize()) {
        qDebug() << "人脸识别器初始化失败 - 但仍继续运行";
    } else {
        qDebug() << "人脸识别器初始化成功";
    }
    engine.rootContext()->setContextProperty("faceRecognizer", &faceRecognizer);
    
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);
    
    qDebug() << "====================== 应用程序初始化完成 ======================\n";

    return app.exec();
}
