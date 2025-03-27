#include "DatabaseManager.h"
#include <QDir>
#include <QStandardPaths>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QCoreApplication>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
    // 设置数据库文件路径到工程目录下
    QString applicationDir = QCoreApplication::applicationDirPath();
    QDir dir(applicationDir);
    
    // 如果没有数据库目录，创建一个
    if (!dir.exists("database")) {
        dir.mkdir("database");
    }
    
    m_dbPath = applicationDir + "/database/sparkexam.db";
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
    bool success = createTables();
    
    // 如果表创建成功，初始化默认设置
    if (success) {
        initDefaultSettings();
    }
    
    return success;
}

bool DatabaseManager::createTables()
{
    QSqlQuery query;
    
    // 创建人脸数据表
    bool success = query.exec(
        "CREATE TABLE IF NOT EXISTS users ("
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
        qDebug() << "Failed to create users table:" << query.lastError().text();
        return false;
    }

    // 创建日志表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS access_logs ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "work_id TEXT NOT NULL, "
        "access_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "access_result BOOLEAN NOT NULL, "
        "FOREIGN KEY (work_id) REFERENCES users(work_id)"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create access_logs table:" << query.lastError().text();
        return false;
    }
    
    // 创建设置表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS settings ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "key TEXT UNIQUE NOT NULL, "
        "value TEXT, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create settings table:" << query.lastError().text();
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
        "INSERT INTO users (name, gender, work_id, face_image_path, avatar_path, is_admin) "
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
    query.prepare("DELETE FROM users WHERE work_id = :work_id");
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
    QSqlQuery query("SELECT * FROM users ORDER BY name");
    
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
    query.prepare("SELECT * FROM users WHERE work_id = :work_id");
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
        "INSERT INTO access_logs (work_id, access_result) "
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
    query.prepare("SELECT COUNT(*) FROM users WHERE work_id = :work_id");
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
        "UPDATE users SET "
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

bool DatabaseManager::setSetting(const QString &key, const QString &value)
{
    // 检查是否已有此设置，有则更新，无则插入
    QSqlQuery checkQuery;
    checkQuery.prepare("SELECT COUNT(*) FROM settings WHERE key = :key");
    checkQuery.bindValue(":key", key);
    
    if (checkQuery.exec() && checkQuery.next()) {
        int count = checkQuery.value(0).toInt();
        
        if (count > 0) {
            // 更新现有设置
            QSqlQuery updateQuery;
            updateQuery.prepare(
                "UPDATE settings SET value = :value, updated_at = CURRENT_TIMESTAMP "
                "WHERE key = :key"
            );
            updateQuery.bindValue(":key", key);
            updateQuery.bindValue(":value", value);
            
            if (!updateQuery.exec()) {
                qDebug() << "Failed to update setting:" << updateQuery.lastError().text();
                return false;
            }
        } else {
            // 插入新设置
            QSqlQuery insertQuery;
            insertQuery.prepare(
                "INSERT INTO settings (key, value) "
                "VALUES (:key, :value)"
            );
            insertQuery.bindValue(":key", key);
            insertQuery.bindValue(":value", value);
            
            if (!insertQuery.exec()) {
                qDebug() << "Failed to insert setting:" << insertQuery.lastError().text();
                return false;
            }
        }
        
        return true;
    }
    
    qDebug() << "Failed to check setting existence:" << checkQuery.lastError().text();
    return false;
}

QString DatabaseManager::getSetting(const QString &key, const QString &defaultValue)
{
    QSqlQuery query;
    query.prepare("SELECT value FROM settings WHERE key = :key");
    query.bindValue(":key", key);
    
    if (query.exec() && query.next()) {
        return query.value("value").toString();
    }
    
    // 如果查询失败或未找到结果，返回默认值
    return defaultValue;
}

bool DatabaseManager::deleteSetting(const QString &key)
{
    QSqlQuery query;
    query.prepare("DELETE FROM settings WHERE key = :key");
    query.bindValue(":key", key);
    
    if (!query.exec()) {
        qDebug() << "Failed to delete setting:" << query.lastError().text();
        return false;
    }
    
    return true;
}

QVariantMap DatabaseManager::getAllSettings()
{
    QVariantMap result;
    QSqlQuery query("SELECT key, value FROM settings");
    
    while (query.next()) {
        QString key = query.value("key").toString();
        QString value = query.value("value").toString();
        result[key] = value;
    }
    
    return result;
}

// 初始化默认设置
void DatabaseManager::initDefaultSettings()
{
    // 检查是否已有设置，如果为空才初始化
    QSqlQuery query("SELECT COUNT(*) FROM settings");
    if (query.exec() && query.next() && query.value(0).toInt() == 0) {
        // 数据库版本
        setSetting("db_version", "1.0");
        
        // 应用名称
        setSetting("app_name", "SparkExam AI");
        
        // 人脸识别阈值
        setSetting("face_recognition_threshold", "0.8");
        
        // 默认管理员工号
        setSetting("default_admin_id", "admin001");
        
        // 其他可能的默认设置
        setSetting("enable_logs", "true");
        setSetting("max_log_days", "30");
        
        qDebug() << "初始化默认设置完成";
    }
}

QVariantList DatabaseManager::getAccessLogs(int limit, int offset)
{
    QVariantList result;
    QSqlQuery query;
    
    // 查询最近的访问日志，按时间倒序排列
    query.prepare(
        "SELECT al.*, u.name "
        "FROM access_logs al "
        "LEFT JOIN users u ON al.work_id = u.work_id "
        "ORDER BY al.access_time DESC "
        "LIMIT :limit OFFSET :offset"
    );
    
    query.bindValue(":limit", limit);
    query.bindValue(":offset", offset);
    
    if (query.exec()) {
        while (query.next()) {
            QVariantMap row;
            row["id"] = query.value("id").toInt();
            row["workId"] = query.value("work_id").toString();
            row["name"] = query.value("name").toString();
            row["accessTime"] = query.value("access_time").toString();
            row["accessResult"] = query.value("access_result").toBool();
            
            result.append(row);
        }
    } else {
        qDebug() << "Failed to get access logs:" << query.lastError().text();
    }
    
    return result;
}

QVariantList DatabaseManager::getAccessLogsByUser(const QString &workId, int limit, int offset)
{
    QVariantList result;
    QSqlQuery query;
    
    // 查询特定用户的访问日志，按时间倒序排列
    query.prepare(
        "SELECT al.*, u.name "
        "FROM access_logs al "
        "LEFT JOIN users u ON al.work_id = u.work_id "
        "WHERE al.work_id = :work_id "
        "ORDER BY al.access_time DESC "
        "LIMIT :limit OFFSET :offset"
    );
    
    query.bindValue(":work_id", workId);
    query.bindValue(":limit", limit);
    query.bindValue(":offset", offset);
    
    if (query.exec()) {
        while (query.next()) {
            QVariantMap row;
            row["id"] = query.value("id").toInt();
            row["workId"] = query.value("work_id").toString();
            row["name"] = query.value("name").toString();
            row["accessTime"] = query.value("access_time").toString();
            row["accessResult"] = query.value("access_result").toBool();
            
            result.append(row);
        }
    } else {
        qDebug() << "Failed to get user access logs:" << query.lastError().text();
    }
    
    return result;
}

bool DatabaseManager::cleanupOldLogs(int daysToKeep)
{
    QSqlQuery query;
    
    // 计算截止日期，删除此日期之前的所有日志
    QString cutoffDate = QDateTime::currentDateTime().addDays(-daysToKeep).toString("yyyy-MM-dd");
    
    query.prepare(
        "DELETE FROM access_logs "
        "WHERE date(access_time) < date(:cutoff_date)"
    );
    
    query.bindValue(":cutoff_date", cutoffDate);
    
    if (!query.exec()) {
        qDebug() << "Failed to clean up old logs:" << query.lastError().text();
        return false;
    }
    
    int affectedRows = query.numRowsAffected();
    qDebug() << "Cleaned up" << affectedRows << "old access logs";
    
    return true;
} 