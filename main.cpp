#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "FileManager.h"
#include "DatabaseManager.h"
#include "FaceRecognizer.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

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
    
    // 创建FaceRecognizer实例并注册到QML上下文
    FaceRecognizer faceRecognizer;
    if (!faceRecognizer.initialize()) {
        qDebug() << "人脸识别器初始化失败";
    }
    engine.rootContext()->setContextProperty("faceRecognizer", &faceRecognizer);
    
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
