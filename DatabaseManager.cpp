#include "DatabaseManager.h"
#include <QDir>
#include <QStandardPaths>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
    // 设置数据库文件路径
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dataPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    m_dbPath = dataPath + "/facedata.db";
    qDebug() << "Database path:" << m_dbPath;

    // 初始化数据库
    initDatabase();
}

DatabaseManager::~DatabaseManager()
{
    if (m_database.isOpen()) {
        m_database.close();
    }
}

bool DatabaseManager::initDatabase()
{
    // 如果数据库连接已经存在，先关闭
    if (m_database.isOpen()) {
        m_database.close();
    }

    // 创建并打开数据库连接
    m_database = QSqlDatabase::addDatabase("QSQLITE");
    m_database.setDatabaseName(m_dbPath);

    if (!m_database.open()) {
        qDebug() << "Failed to open database:" << m_database.lastError().text();
        return false;
    }

    // 创建数据表
    return createTables();
}

bool DatabaseManager::createTables()
{
    QSqlQuery query;
    
    // 创建人脸数据表
    bool success = query.exec(
        "CREATE TABLE IF NOT EXISTS face_data ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "name TEXT NOT NULL, "
        "gender TEXT NOT NULL, "
        "work_id TEXT UNIQUE NOT NULL, "
        "face_image_path TEXT NOT NULL, "
        "avatar_path TEXT NOT NULL, "
        "is_admin BOOLEAN DEFAULT 0, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create face_data table:" << query.lastError().text();
        return false;
    }

    // 创建日志表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS access_log ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "work_id TEXT NOT NULL, "
        "access_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "access_result BOOLEAN NOT NULL, "
        "FOREIGN KEY (work_id) REFERENCES face_data(work_id)"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create access_log table:" << query.lastError().text();
        return false;
    }

    return true;
}

bool DatabaseManager::addFaceData(const QString &name, const QString &gender, 
                                 const QString &workId, const QString &faceImagePath, 
                                 const QString &avatarPath, bool isAdmin)
{
    QSqlQuery query;
    query.prepare(
        "INSERT INTO face_data (name, gender, work_id, face_image_path, avatar_path, is_admin) "
        "VALUES (:name, :gender, :work_id, :face_image_path, :avatar_path, :is_admin)"
    );
    
    query.bindValue(":name", name);
    query.bindValue(":gender", gender);
    query.bindValue(":work_id", workId);
    query.bindValue(":face_image_path", faceImagePath);
    query.bindValue(":avatar_path", avatarPath);
    query.bindValue(":is_admin", isAdmin ? 1 : 0);
    
    if (!query.exec()) {
        qDebug() << "Failed to add face data:" << query.lastError().text();
        return false;
    }
    
    return true;
}

bool DatabaseManager::deleteFaceData(const QString &workId)
{
    QSqlQuery query;
    query.prepare("DELETE FROM face_data WHERE work_id = :work_id");
    query.bindValue(":work_id", workId);
    
    if (!query.exec()) {
        qDebug() << "Failed to delete face data:" << query.lastError().text();
        return false;
    }
    
    return true;
}

QVariantList DatabaseManager::getAllFaceData()
{
    QVariantList result;
    QSqlQuery query("SELECT * FROM face_data ORDER BY name");
    
    while (query.next()) {
        QVariantMap row;
        row["id"] = query.value("id").toInt();
        row["name"] = query.value("name").toString();
        row["gender"] = query.value("gender").toString();
        row["workId"] = query.value("work_id").toString();
        row["faceImage"] = query.value("face_image_path").toString();
        row["avatarPath"] = query.value("avatar_path").toString();
        row["isAdmin"] = query.value("is_admin").toBool();
        row["createdAt"] = query.value("created_at").toString();
        
        result.append(row);
    }
    
    return result;
}

QVariantMap DatabaseManager::getFaceDataByWorkId(const QString &workId)
{
    QVariantMap result;
    QSqlQuery query;
    query.prepare("SELECT * FROM face_data WHERE work_id = :work_id");
    query.bindValue(":work_id", workId);
    
    if (query.exec() && query.next()) {
        result["id"] = query.value("id").toInt();
        result["name"] = query.value("name").toString();
        result["gender"] = query.value("gender").toString();
        result["workId"] = query.value("work_id").toString();
        result["faceImage"] = query.value("face_image_path").toString();
        result["avatarPath"] = query.value("avatar_path").toString();
        result["isAdmin"] = query.value("is_admin").toBool();
        result["createdAt"] = query.value("created_at").toString();
    }
    
    return result;
}

bool DatabaseManager::verifyFace(const QString &workId, const QString &faceImagePath)
{
    // 记录验证结果
    QSqlQuery logQuery;
    logQuery.prepare(
        "INSERT INTO access_log (work_id, access_result) "
        "VALUES (:work_id, :access_result)"
    );
    
    // 检查用户是否存在
    QVariantMap userData = getFaceDataByWorkId(workId);
    if (userData.isEmpty()) {
        // 用户不存在，记录失败
        logQuery.bindValue(":work_id", workId);
        logQuery.bindValue(":access_result", 0);
        logQuery.exec();
        return false;
    }
    
    // 在实际应用中，这里应该进行人脸比对
    // 这里简化处理，仅检查用户是否存在
    bool result = !userData.isEmpty();
    
    // 记录验证结果
    logQuery.bindValue(":work_id", workId);
    logQuery.bindValue(":access_result", result ? 1 : 0);
    logQuery.exec();
    
    return result;
}

bool DatabaseManager::userExists(const QString &workId)
{
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM face_data WHERE work_id = :work_id");
    query.bindValue(":work_id", workId);
    
    if (query.exec() && query.next()) {
        return query.value(0).toInt() > 0;
    }
    
    return false;
}

bool DatabaseManager::updateFaceData(const QString &workId, const QString &name, 
                                    const QString &gender, const QString &faceImagePath, 
                                    const QString &avatarPath, bool isAdmin)
{
    QSqlQuery query;
    query.prepare(
        "UPDATE face_data SET "
        "name = :name, "
        "gender = :gender, "
        "face_image_path = :face_image_path, "
        "avatar_path = :avatar_path, "
        "is_admin = :is_admin "
        "WHERE work_id = :work_id"
    );
    
    query.bindValue(":name", name);
    query.bindValue(":gender", gender);
    query.bindValue(":face_image_path", faceImagePath);
    query.bindValue(":avatar_path", avatarPath);
    query.bindValue(":is_admin", isAdmin ? 1 : 0);
    query.bindValue(":work_id", workId);
    
    if (!query.exec()) {
        qDebug() << "Failed to update face data:" << query.lastError().text();
        return false;
    }
    
    return true;
} 