#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>
#include <QString>
#include <QDateTime>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    // 初始化数据库连接
    Q_INVOKABLE bool initDatabase();

    // 添加人脸数据
    Q_INVOKABLE bool addFaceData(const QString &name, 
                                const QString &gender, 
                                const QString &workId, 
                                const QString &faceImagePath, 
                                const QString &avatarPath, 
                                bool isAdmin = false);

    // 删除人脸数据
    Q_INVOKABLE bool deleteFaceData(const QString &workId);

    // 获取所有人脸数据
    Q_INVOKABLE QVariantList getAllFaceData();

    // 根据工号查询人脸数据
    Q_INVOKABLE QVariantMap getFaceDataByWorkId(const QString &workId);

    // 验证人脸（根据工号和人脸图像路径）
    Q_INVOKABLE bool verifyFace(const QString &workId, const QString &faceImagePath);

    // 检查用户是否存在
    Q_INVOKABLE bool userExists(const QString &workId);

    // 更新人脸数据
    Q_INVOKABLE bool updateFaceData(const QString &workId, 
                                   const QString &name, 
                                   const QString &gender, 
                                   const QString &faceImagePath, 
                                   const QString &avatarPath, 
                                   bool isAdmin = false);

private:
    QSqlDatabase m_database;
    QString m_dbPath;

    // 创建表结构
    bool createTables();
};

#endif // DATABASEMANAGER_H 