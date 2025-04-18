#include "DatabaseManager.h"
#include <QDir>
#include <QStandardPaths>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QCoreApplication>
#include <QDebug>
#include "FaceRecognizer.h"
#include <QFile>
#include <QVariantMap>

// Forward declaration of helper functions
QString getFieldValue(const QVariantMap &map, const QStringList &possibleKeys);

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
    // 打开数据库连接
    m_database = QSqlDatabase::addDatabase("QSQLITE");
    m_database.setDatabaseName(m_dbPath);
    
    if (!m_database.open()) {
        qDebug() << "无法打开数据库:" << m_database.lastError().text();
        return false;
    }
    
    // 创建表
    if (!createTables()) {
        return false;
    }
    
    // 更新数据库架构（添加新字段）
    if (!updateDatabaseSchema()) {
        qDebug() << "更新数据库架构失败";
        // 继续执行，不因此中断程序
    }
    
    // 初始化默认设置
    initDefaultSettings();
    
    return true;
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
    
    // 创建题库表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS question_banks ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "name TEXT NOT NULL, "
        "question_count INTEGER DEFAULT 0, "
        "import_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create question_banks table:" << query.lastError().text();
        return false;
    }
    
    // 创建题目表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS questions ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "bank_id INTEGER NOT NULL, "
        "content TEXT NOT NULL, "
        "answer TEXT NOT NULL, "
        "analysis TEXT, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "FOREIGN KEY (bank_id) REFERENCES question_banks(id) ON DELETE CASCADE"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create questions table:" << query.lastError().text();
        return false;
    }
    
    // 创建选项表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS question_options ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "question_id INTEGER NOT NULL, "
        "option_text TEXT NOT NULL, "
        "option_index INTEGER NOT NULL, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create question_options table:" << query.lastError().text();
        return false;
    }

    // 创建智点表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS knowledge_points ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "title TEXT NOT NULL, "
        "content TEXT NOT NULL, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create knowledge_points table:" << query.lastError().text();
        return false;
    }
    
    // 创建用户答题记录表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS user_answer_records ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "work_id TEXT NOT NULL, "
        "user_name TEXT NOT NULL, "
        "exam_type TEXT NOT NULL, "
        "total_questions INTEGER NOT NULL, "
        "correct_count INTEGER NOT NULL, "
        "answer_data TEXT NOT NULL, "
        "score_percentage REAL NOT NULL, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "FOREIGN KEY (work_id) REFERENCES users(work_id)"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create user_answer_records table:" << query.lastError().text();
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
    qDebug() << "Verifying face for work ID:" << workId << "using image:" << faceImagePath;
    
    // 检查图像文件是否存在
    QFileInfo imageFile(faceImagePath);
    if (!imageFile.exists() || !imageFile.isFile()) {
        qDebug() << "Face image file does not exist or is not a file:" << faceImagePath;
        return false;
    }
    
    // 记录验证结果
    QSqlQuery logQuery;
    logQuery.prepare(
        "INSERT INTO access_logs (work_id, access_result) "
        "VALUES (:work_id, :access_result)"
    );
    
    // 检查用户是否存在
    QVariantMap userData = getFaceDataByWorkId(workId);
    if (userData.isEmpty()) {
        qDebug() << "User with work ID" << workId << "not found in database";
        // 用户不存在，记录失败
        logQuery.bindValue(":work_id", workId);
        logQuery.bindValue(":access_result", 0);
        logQuery.exec();
        return false;
    }
    
    // 获取用户注册的人脸图像
    QString registeredFaceImage = userData["faceImage"].toString();
    qDebug() << "Registered face image path:" << registeredFaceImage;
    
    // 检查注册的人脸图像是否存在
    QFileInfo registeredImageFile(registeredFaceImage);
    if (!registeredImageFile.exists() || !registeredImageFile.isFile()) {
        qDebug() << "Registered face image file does not exist or is not a file:" << registeredFaceImage;
        logQuery.bindValue(":work_id", workId);
        logQuery.bindValue(":access_result", 0);
        logQuery.exec();
        return false;
    }
    
    // 创建人脸识别器
    static FaceRecognizer faceRecognizer;
    
    // 初始化人脸识别器
    if (!faceRecognizer.initialize()) {
        qDebug() << "Failed to initialize face recognizer.";
        logQuery.bindValue(":work_id", workId);
        logQuery.bindValue(":access_result", 0);
        logQuery.exec();
        return false;
    }
    
    // 比较两张人脸图像
    float similarity = faceRecognizer.compareFaces(registeredFaceImage, faceImagePath);
    
    // 获取相似度阈值
    float threshold = getSetting("face_recognition_threshold", "0.6").toFloat();
    
    // 判断是否通过验证
    bool result = similarity >= threshold;
    
    // 记录验证结果
    logQuery.bindValue(":work_id", workId);
    logQuery.bindValue(":access_result", result ? 1 : 0);
    logQuery.exec();
    
    qDebug() << "Face verification result:" << result << "Similarity:" << similarity << "Threshold:" << threshold;
    
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
        setSetting("face_recognition_threshold", "0.6");
        
        // 默认管理员工号
        setSetting("default_admin_id", "admin001");
        
        // 设置默认管理员密码
        setSetting("admin_password", "123456");
        
        // 其他可能的默认设置
        setSetting("enable_logs", "true");
        setSetting("max_log_days", "30");
        
        // 默认摄像头设置 - 使用特殊值"auto"表示自动检测
        setSetting("camera_device", "auto");
        
        // 五芒图默认标题设置
        setSetting("pentagon_title_1", "基础认知");
        setSetting("pentagon_title_2", "原理理解");
        setSetting("pentagon_title_3", "操作应用");
        setSetting("pentagon_title_4", "诊断分析");
        setSetting("pentagon_title_5", "安全规范");
        
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

// 根据工号获取用户头像路径
QString DatabaseManager::getUserAvatarPath(const QString &workId)
{
    QSqlQuery query(m_database);
    query.prepare("SELECT avatar_path FROM users WHERE work_id = :work_id");
    query.bindValue(":work_id", workId);
    
    if (!query.exec()) {
        qDebug() << "获取用户头像路径失败: " << query.lastError().text();
        return "";
    }
    
    if (query.next()) {
        QString avatarPath = query.value(0).toString();
        qDebug() << "成功获取用户头像路径: " << avatarPath;
        return avatarPath;
    }
    
    qDebug() << "未找到用户头像路径, 工号: " << workId;
    return "";
}

// 题库管理相关方法实现

bool DatabaseManager::addQuestionBank(const QString &name, int questionCount)
{
    // 检查是否存在同名题库
    QSqlQuery checkQuery(m_database);
    checkQuery.prepare("SELECT COUNT(*) FROM question_banks WHERE name = :name");
    checkQuery.bindValue(":name", name);
    
    if (!checkQuery.exec()) {
        qDebug() << "检查同名题库失败:" << checkQuery.lastError().text();
        return false;
    }
    
    if (checkQuery.next() && checkQuery.value(0).toInt() > 0) {
        qDebug() << "已存在同名题库:" << name;
        return false;
    }
    
    QSqlQuery query(m_database);
    query.prepare(
        "INSERT INTO question_banks (name, question_count, import_time) "
        "VALUES (:name, :question_count, :import_time)"
    );
    
    // 使用自定义格式存储时间，避免使用ISO 8601格式中的字母T
    QString currentTime = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
    
    query.bindValue(":name", name);
    query.bindValue(":question_count", questionCount);
    query.bindValue(":import_time", currentTime);
    
    if (!query.exec()) {
        qDebug() << "Failed to add question bank:" << query.lastError().text();
        return false;
    }
    
    return true;
}

bool DatabaseManager::deleteQuestionBank(int bankId)
{
    qDebug() << "开始删除题库，ID:" << bankId;
    
    // 检查数据库连接
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return false;
        }
    }
    
    // 首先检查题库是否存在
    QSqlQuery checkQuery(m_database);
    checkQuery.prepare("SELECT COUNT(*) FROM question_banks WHERE id = :id");
    checkQuery.bindValue(":id", bankId);
    
    if (!checkQuery.exec()) {
        qDebug() << "检查题库是否存在失败:" << checkQuery.lastError().text();
        return false;
    }
    
    if (checkQuery.next() && checkQuery.value(0).toInt() == 0) {
        qDebug() << "题库不存在，ID:" << bankId;
        return false;
    }
    
    // 开始事务
    m_database.transaction();
    
    // 先验证是否存在相关题目
    QSqlQuery countQuery(m_database);
    countQuery.prepare("SELECT COUNT(*) FROM questions WHERE bank_id = :bank_id");
    countQuery.bindValue(":bank_id", bankId);
    
    if (!countQuery.exec()) {
        qDebug() << "检查题目数量失败:" << countQuery.lastError().text();
        m_database.rollback();
        return false;
    }
    
    if (countQuery.next()) {
        int questionCount = countQuery.value(0).toInt();
        qDebug() << "要删除的题库包含" << questionCount << "道题目";
    }
    
    // 先尝试删除所有相关题目
    QSqlQuery deleteQuestionsQuery(m_database);
    deleteQuestionsQuery.prepare("DELETE FROM questions WHERE bank_id = :bank_id");
    deleteQuestionsQuery.bindValue(":bank_id", bankId);
    
    if (!deleteQuestionsQuery.exec()) {
        qDebug() << "删除题目失败:" << deleteQuestionsQuery.lastError().text();
        m_database.rollback();
        return false;
    }
    
    int questionsDeleted = deleteQuestionsQuery.numRowsAffected();
    qDebug() << "删除题目影响的行数:" << questionsDeleted;
    
    // 删除题库
    QSqlQuery query(m_database);
    query.prepare("DELETE FROM question_banks WHERE id = :id");
    query.bindValue(":id", bankId);
    
    if (!query.exec()) {
        qDebug() << "删除题库失败:" << query.lastError().text();
        m_database.rollback();
        return false;
    }
    
    int rowsAffected = query.numRowsAffected();
    qDebug() << "删除题库影响的行数:" << rowsAffected;
    
    // 提交事务
    if (!m_database.commit()) {
        qDebug() << "提交事务失败:" << m_database.lastError().text();
        m_database.rollback();
        return false;
    }
    
    qDebug() << "成功删除题库，ID:" << bankId;
    return true;
}

QVariantList DatabaseManager::getAllQuestionBanks()
{
    QVariantList result;
    QSqlQuery query(m_database);
    query.prepare("SELECT * FROM question_banks ORDER BY import_time DESC");
    
    if (!query.exec()) {
        qDebug() << "Failed to get question banks:" << query.lastError().text();
        return result;
    }
    
    while (query.next()) {
        QVariantMap row;
        row["id"] = query.value("id").toInt();
        row["name"] = query.value("name").toString();
        row["count"] = query.value("question_count").toInt();
        
        // 获取导入时间并格式化
        QString importTime = query.value("import_time").toString();
        // 如果时间格式中包含T，则替换为空格
        if (importTime.contains("T")) {
            importTime.replace("T", " ");
        }
        row["importTime"] = importTime;
        
        result.append(row);
    }
    
    return result;
}

QVariantMap DatabaseManager::getQuestionBankById(int bankId)
{
    QVariantMap result;
    QSqlQuery query(m_database);
    
    qDebug() << "获取题库信息，ID:" << bankId;
    
    query.prepare("SELECT * FROM question_banks WHERE id = :id");
    query.bindValue(":id", bankId);
    
    if (query.exec() && query.next()) {
        result["id"] = query.value("id").toInt();
        result["name"] = query.value("name").toString();
        result["count"] = query.value("question_count").toInt();
        
        // 获取导入时间并格式化
        QString importTime = query.value("import_time").toString();
        // 如果时间格式中包含T，则替换为空格
        if (importTime.contains("T")) {
            importTime.replace("T", " ");
        }
        result["importTime"] = importTime;
        
        qDebug() << "题库信息获取成功，名称:" << result["name"].toString() << "题目数量:" << result["count"].toInt();
    } else {
        qDebug() << "题库不存在或查询失败，ID:" << bankId << "错误:" << query.lastError().text();
    }
    
    return result;
}

bool DatabaseManager::updateQuestionBank(int bankId, const QString &name)
{
    QSqlQuery query;
    query.prepare("UPDATE question_banks SET name = :name WHERE id = :id");
    query.bindValue(":name", name);
    query.bindValue(":id", bankId);
    
    if (!query.exec()) {
        qDebug() << "Failed to update question bank:" << query.lastError().text();
        return false;
    }
    
    return true;
}

bool DatabaseManager::addQuestion(int bankId, 
                                const QString &content, 
                                const QString &answer, 
                                const QString &analysis,
                                const QStringList &options)
{
    QSqlQuery query(m_database);
    query.prepare(
        "INSERT INTO questions (bank_id, content, answer, analysis) "
        "VALUES (:bank_id, :content, :answer, :analysis)"
    );
    
    query.bindValue(":bank_id", bankId);
    query.bindValue(":content", content);
    query.bindValue(":answer", answer);
    query.bindValue(":analysis", analysis);
    
    if (!query.exec()) {
        qDebug() << "Failed to add question:" << query.lastError().text();
        return false;
    }
    
    int questionId = query.lastInsertId().toInt();
    
    // 添加选项
    if (!options.isEmpty()) {
        for (int i = 0; i < options.size(); ++i) {
            query.prepare(
                "INSERT INTO question_options (question_id, option_text, option_index) "
                "VALUES (:question_id, :option_text, :option_index)"
            );
            
            query.bindValue(":question_id", questionId);
            query.bindValue(":option_text", options[i]);
            query.bindValue(":option_index", i);
            
            if (!query.exec()) {
                qDebug() << "Failed to add question option:" << query.lastError().text();
                return false;
            }
        }
    }
    
    // 更新题库题目数量
    query.prepare("UPDATE question_banks SET question_count = question_count + 1 WHERE id = :id");
    query.bindValue(":id", bankId);
    
    if (!query.exec()) {
        qDebug() << "Failed to update question bank count:" << query.lastError().text();
        return false;
    }
    
    return true;
}

bool DatabaseManager::deleteQuestion(int questionId)
{
    // 获取题目所属的题库ID
    QSqlQuery query(m_database);
    query.prepare("SELECT bank_id FROM questions WHERE id = :id");
    query.bindValue(":id", questionId);
    
    if (!query.exec() || !query.next()) {
        qDebug() << "Failed to get question bank_id:" << query.lastError().text();
        return false;
    }
    
    int bankId = query.value("bank_id").toInt();
    
    // 删除题目（选项会通过外键级联删除）
    query.prepare("DELETE FROM questions WHERE id = :id");
    query.bindValue(":id", questionId);
    
    if (!query.exec()) {
        qDebug() << "Failed to delete question:" << query.lastError().text();
        return false;
    }
    
    // 更新题库题目数量
    query.prepare("UPDATE question_banks SET question_count = question_count - 1 WHERE id = :id");
    query.bindValue(":id", bankId);
    
    if (!query.exec()) {
        qDebug() << "Failed to update question bank count:" << query.lastError().text();
        return false;
    }
    
    return true;
}

bool DatabaseManager::updateQuestion(int questionId,
                                   const QString &content, 
                                   const QString &answer, 
                                   const QString &analysis,
                                   const QStringList &options)
{
    QSqlQuery query(m_database);
    query.prepare(
        "UPDATE questions SET content = :content, answer = :answer, analysis = :analysis "
        "WHERE id = :id"
    );
    
    query.bindValue(":content", content);
    query.bindValue(":answer", answer);
    query.bindValue(":analysis", analysis);
    query.bindValue(":id", questionId);
    
    if (!query.exec()) {
        qDebug() << "Failed to update question:" << query.lastError().text();
        return false;
    }
    
    // 更新选项
    if (!options.isEmpty()) {
        // 先删除旧选项
        query.prepare("DELETE FROM question_options WHERE question_id = :question_id");
        query.bindValue(":question_id", questionId);
        
        if (!query.exec()) {
            qDebug() << "Failed to delete old options:" << query.lastError().text();
            return false;
        }
        
        // 添加新选项
        for (int i = 0; i < options.size(); ++i) {
            query.prepare(
                "INSERT INTO question_options (question_id, option_text, option_index) "
                "VALUES (:question_id, :option_text, :option_index)"
            );
            
            query.bindValue(":question_id", questionId);
            query.bindValue(":option_text", options[i]);
            query.bindValue(":option_index", i);
            
            if (!query.exec()) {
                qDebug() << "Failed to add question option:" << query.lastError().text();
                return false;
            }
        }
    }
    
    return true;
}

QVariantList DatabaseManager::getQuestionsByBankId(int bankId)
{
    QVariantList result;
    QSqlQuery query(m_database);
    query.prepare("SELECT * FROM questions WHERE bank_id = :bank_id ORDER BY id");
    query.bindValue(":bank_id", bankId);
    
    if (!query.exec()) {
        qDebug() << "Failed to get questions:" << query.lastError().text();
        return result;
    }
    
    while (query.next()) {
        QVariantMap question;
        question["id"] = query.value("id").toInt();
        question["content"] = query.value("content").toString();
        question["answer"] = query.value("answer").toString();
        question["analysis"] = query.value("analysis").toString();
        question["bankId"] = query.value("bank_id").toInt();  // 添加题库ID信息
        
        // 获取选项
        QSqlQuery optionQuery(m_database);
        optionQuery.prepare("SELECT * FROM question_options WHERE question_id = :question_id ORDER BY option_index");
        optionQuery.bindValue(":question_id", question["id"].toInt());
        
        QStringList options;
        if (optionQuery.exec()) {
            while (optionQuery.next()) {
                options.append(optionQuery.value("option_text").toString());
            }
        }
        
        question["options"] = options;
        result.append(question);
    }
    
    return result;
}

QVariantMap DatabaseManager::getQuestionById(int questionId)
{
    QVariantMap result;
    QSqlQuery query(m_database);
    query.prepare("SELECT * FROM questions WHERE id = :id");
    query.bindValue(":id", questionId);
    
    if (query.exec() && query.next()) {
        result["id"] = query.value("id").toInt();
        result["bankId"] = query.value("bank_id").toInt();
        result["content"] = query.value("content").toString();
        result["answer"] = query.value("answer").toString();
        result["analysis"] = query.value("analysis").toString();
        
        // 获取选项
        QSqlQuery optionQuery(m_database);
        optionQuery.prepare("SELECT * FROM question_options WHERE question_id = :question_id ORDER BY option_index");
        optionQuery.bindValue(":question_id", questionId);
        
        QStringList options;
        if (optionQuery.exec()) {
            while (optionQuery.next()) {
                options.append(optionQuery.value("option_text").toString());
            }
        }
        
        result["options"] = options;
    }
    
    return result;
}

QVariantList DatabaseManager::getRandomQuestions(int bankId, int count)
{
    QVariantList result;
    QSqlQuery query(m_database);
    
    // 首先获取题库中的总题目数
    query.prepare("SELECT COUNT(*) FROM questions WHERE bank_id = :bank_id");
    query.bindValue(":bank_id", bankId);
    
    if (!query.exec() || !query.next()) {
        qDebug() << "获取题目总数失败:" << query.lastError().text();
        return result;
    }
    
    int totalQuestions = query.value(0).toInt();
    if (totalQuestions == 0) {
        qDebug() << "题库为空，无法抽取题目";
        return result;
    }
    
    // 确保不超过题库中的题目总数
    count = qMin(count, totalQuestions);
    
    // 使用ORDER BY RANDOM()随机抽取题目
    query.prepare(
        "SELECT q.*, GROUP_CONCAT(o.option_text, '|') as options, "
        "GROUP_CONCAT(o.option_index, '|') as option_indices "
        "FROM questions q "
        "LEFT JOIN question_options o ON q.id = o.question_id "
        "WHERE q.bank_id = :bank_id "
        "GROUP BY q.id "
        "ORDER BY RANDOM() "
        "LIMIT :count"
    );
    
    query.bindValue(":bank_id", bankId);
    query.bindValue(":count", count);
    
    if (!query.exec()) {
        qDebug() << "随机抽取题目失败:" << query.lastError().text();
        return result;
    }
    
    while (query.next()) {
        QVariantMap question;
        question["id"] = query.value("id").toInt();
        question["content"] = query.value("content").toString();
        question["answer"] = query.value("answer").toString();
        question["analysis"] = query.value("analysis").toString();
        
        // 使用传入的bankId而不是从数据库获取，因为在某些查询中可能不返回bank_id字段
        question["bankId"] = bankId;
        
        qDebug() << "随机抽取题目 ID:" << question["id"].toInt() << "题库ID:" << bankId;
        
        // 处理选项
        QString optionsStr = query.value("options").toString();
        QString indicesStr = query.value("option_indices").toString();
        
        if (!optionsStr.isEmpty() && !indicesStr.isEmpty()) {
            QStringList options = optionsStr.split("|");
            QStringList indices = indicesStr.split("|");
            
            QVariantList optionsList;
            for (int i = 0; i < options.length(); i++) {
                QVariantMap option;
                option["text"] = options[i];
                option["index"] = indices[i].toInt();
                optionsList.append(option);
            }
            question["options"] = optionsList;
        } else {
            question["options"] = QVariantList();
        }
        
        result.append(question);
    }
    
    return result;
}

bool DatabaseManager::importQuestions(int bankId, const QVariantList &questions)
{
    if (questions.isEmpty()) {
        qDebug() << "没有题目需要导入";
        return false;
    }
    
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return false;
        }
    }
    
    // 开始事务
    m_database.transaction();
    
    int successCount = 0;
    int failCount = 0;
    
    for (const QVariant &questionVar : questions) {
        QVariantMap questionMap = questionVar.toMap();
        
        // 获取必要字段，支持多种可能的字段名
        QString content = getFieldValue(questionMap, {"题干", "题目", "题目内容", "题目描述", "内容"});
        QString answer = getFieldValue(questionMap, {"答案", "正确答案", "标准答案"});
        QString analysis = getFieldValue(questionMap, {"解析", "题目解析", "答案解析", "分析"});
        
        // 检查必要字段是否存在
        if (content.isEmpty() || answer.isEmpty()) {
            qDebug() << "题目缺少必要字段，跳过导入";
            failCount++;
            continue;
        }
        
        // 收集选项
        QStringList options;
        for (int i = 0; i < 7; ++i) {
            QString optionKey = QString("选项%1").arg(QChar('A' + i));
            QString optionValue = questionMap.value(optionKey).toString();
            if (!optionValue.isEmpty()) {
                options.append(optionValue);
            }
        }
        
        // 添加题目
        if (!addQuestion(bankId, content, answer, analysis, options)) {
            qDebug() << "添加题目失败";
            failCount++;
            continue;
        }
        
        successCount++;
    }
    
    // 更新题库的题目数量
    QSqlQuery query(m_database);
    query.prepare("UPDATE question_banks SET question_count = (SELECT COUNT(*) FROM questions WHERE bank_id = :bank_id) WHERE id = :bank_id");
    query.bindValue(":bank_id", bankId);
    
    if (!query.exec()) {
        qDebug() << "更新题库题目数量失败:" << query.lastError().text();
        m_database.rollback();
        return false;
    }
    
    // 提交事务
    if (!m_database.commit()) {
        qDebug() << "提交事务失败:" << m_database.lastError().text();
        m_database.rollback();
        return false;
    }
    
    qDebug() << "成功导入" << successCount << "道题目，失败" << failCount << "道题目";
    return successCount > 0;
}

// 获取所有智点
QVariantList DatabaseManager::getAllKnowledgePoints()
{
    QVariantList points;
    
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return points;
        }
    }
    
    QSqlQuery query(m_database);
    query.prepare("SELECT id, title, content FROM knowledge_points ORDER BY id DESC");
    
    if (!query.exec()) {
        qDebug() << "获取智点失败:" << query.lastError().text();
        return points;
    }
    
    while (query.next()) {
        QVariantMap point;
        point["id"] = query.value("id").toInt();
        point["title"] = query.value("title").toString();
        point["content"] = query.value("content").toString();
        points.append(point);
    }
    
    return points;
}

// 添加单个智点
bool DatabaseManager::addKnowledgePoint(const QString &title, const QString &content)
{
    if (title.isEmpty() || content.isEmpty()) {
        qDebug() << "智点标题或内容不能为空";
        return false;
    }
    
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return false;
        }
    }
    
    QSqlQuery query(m_database);
    query.prepare("INSERT INTO knowledge_points (title, content) VALUES (:title, :content)");
    query.bindValue(":title", title);
    query.bindValue(":content", content);
    
    if (!query.exec()) {
        qDebug() << "添加智点失败:" << query.lastError().text();
        return false;
    }
    
    return true;
}

// 删除智点
bool DatabaseManager::deleteKnowledgePoint(int pointId)
{
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return false;
        }
    }
    
    QSqlQuery query(m_database);
    query.prepare("DELETE FROM knowledge_points WHERE id = :id");
    query.bindValue(":id", pointId);
    
    if (!query.exec()) {
        qDebug() << "删除智点失败:" << query.lastError().text();
        return false;
    }
    
    return true;
}

// 批量导入智点
bool DatabaseManager::importKnowledgePoints(const QVariantList &points)
{
    if (points.isEmpty()) {
        qDebug() << "没有智点需要导入";
        return false;
    }
    
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return false;
        }
    }
    
    // 开始事务
    m_database.transaction();
    
    int successCount = 0;
    int failCount = 0;
    
    for (const QVariant &pointVar : points) {
        QVariantMap pointMap = pointVar.toMap();
        
        // 支持两种可能的表头名称：标题和内容
        QString title = pointMap.value("标题").toString();
        // 检查智点内容列
        QString content = pointMap.value("智点内容").toString();
        if (content.isEmpty()) {
            content = pointMap.value("内容").toString();
        }
        
        // 检查必要字段是否存在
        if (title.isEmpty() || content.isEmpty()) {
            qDebug() << "智点缺少必要字段，跳过导入";
            failCount++;
            continue;
        }
        
        // 添加智点
        if (!addKnowledgePoint(title, content)) {
            qDebug() << "添加智点失败";
            failCount++;
            continue;
        }
        
        successCount++;
    }
    
    // 提交或回滚事务
    if (successCount > 0) {
        if (!m_database.commit()) {
            qDebug() << "提交事务失败:" << m_database.lastError().text();
            m_database.rollback();
            return false;
        }
        qDebug() << "成功导入" << successCount << "条智点数据，失败" << failCount << "条";
        return true;
    } else {
        m_database.rollback();
        qDebug() << "所有智点导入失败，已回滚事务";
        return false;
    }
}

// 清空所有智点
bool DatabaseManager::clearAllKnowledgePoints()
{
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return false;
        }
    }
    
    QSqlQuery query(m_database);
    query.prepare("DELETE FROM knowledge_points");
    
    if (!query.exec()) {
        qDebug() << "清空智点列表失败:" << query.lastError().text();
        return false;
    }
    
    qDebug() << "成功清空所有智点";
    return true;
}

QString getFieldValue(const QVariantMap &map, const QStringList &possibleKeys)
{
    for (const QString &key : possibleKeys) {
        if (map.contains(key)) {
            QString value = map.value(key).toString();
            if (!value.isEmpty()) {
                return value;
            }
        }
    }
    return QString();
}

bool DatabaseManager::saveUserAnswerRecord(const QString &workId, 
                                       const QString &userName,
                                       const QString &examType,
                                       int totalQuestions,
                                       int correctCount,
                                       const QString &answerData,
                                       const QString &questionBankInfo,
                                       const QString &pentagonType)
{
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return false;
        }
    }
    
    QSqlQuery query(m_database);
    query.prepare(
        "INSERT INTO user_answer_records "
        "(work_id, user_name, exam_type, total_questions, correct_count, answer_data, score_percentage, question_bank_info, pentagon_type) "
        "VALUES (:work_id, :user_name, :exam_type, :total_questions, :correct_count, :answer_data, :score_percentage, :question_bank_info, :pentagon_type)"
    );
    
    query.bindValue(":work_id", workId);
    query.bindValue(":user_name", userName);
    query.bindValue(":exam_type", examType);
    query.bindValue(":total_questions", totalQuestions);
    query.bindValue(":correct_count", correctCount);
    query.bindValue(":answer_data", answerData);
    query.bindValue(":question_bank_info", questionBankInfo);
    query.bindValue(":pentagon_type", pentagonType);
    
    // 计算得分百分比
    float scorePercentage = 0;
    if (totalQuestions > 0) {
        scorePercentage = (float)correctCount / totalQuestions * 100.0;
    }
    query.bindValue(":score_percentage", scorePercentage);
    
    if (!query.exec()) {
        qDebug() << "保存用户答题记录失败:" << query.lastError().text();
        return false;
    }
    
    qDebug() << "用户" << userName << "答题记录保存成功, 得分: " << correctCount << "/" << totalQuestions;
    return true;
}

QVariantList DatabaseManager::getUserAnswerRecords(const QString &workId, int limit, int offset)
{
    QVariantList result;
    
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return result;
        }
    }
    
    QSqlQuery query(m_database);
    query.prepare(
        "SELECT * FROM user_answer_records "
        "WHERE work_id = :work_id "
        "ORDER BY created_at DESC "
        "LIMIT :limit OFFSET :offset"
    );
    
    query.bindValue(":work_id", workId);
    query.bindValue(":limit", limit);
    query.bindValue(":offset", offset);
    
    if (!query.exec()) {
        qDebug() << "获取用户答题记录失败:" << query.lastError().text();
        return result;
    }
    
    while (query.next()) {
        QVariantMap record;
        record["id"] = query.value("id").toInt();
        record["workId"] = query.value("work_id").toString();
        record["userName"] = query.value("user_name").toString();
        record["examType"] = query.value("exam_type").toString();
        record["totalQuestions"] = query.value("total_questions").toInt();
        record["correctCount"] = query.value("correct_count").toInt();
        record["answerData"] = query.value("answer_data").toString();
        record["scorePercentage"] = query.value("score_percentage").toFloat();
        record["createdAt"] = query.value("created_at").toString();
        record["questionBankInfo"] = query.value("question_bank_info").toString();
        record["pentagonType"] = query.value("pentagon_type").toString();
        
        result.append(record);
    }
    
    return result;
}

QVariantList DatabaseManager::getAllAnswerRecords(int limit, int offset)
{
    QVariantList result;
    
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return result;
        }
    }
    
    QSqlQuery query(m_database);
    query.prepare(
        "SELECT r.*, u.name as user_name "
        "FROM user_answer_records r "
        "LEFT JOIN users u ON r.work_id = u.work_id "
        "ORDER BY r.created_at DESC "
        "LIMIT :limit OFFSET :offset"
    );
    
    query.bindValue(":limit", limit);
    query.bindValue(":offset", offset);
    
    if (!query.exec()) {
        qDebug() << "获取所有答题记录失败:" << query.lastError().text();
        return result;
    }
    
    while (query.next()) {
        QVariantMap record;
        record["id"] = query.value("id").toInt();
        record["workId"] = query.value("work_id").toString();
        record["userName"] = query.value("user_name").toString();
        record["examType"] = query.value("exam_type").toString();
        record["totalQuestions"] = query.value("total_questions").toInt();
        record["correctCount"] = query.value("correct_count").toInt();
        record["answerData"] = query.value("answer_data").toString();
        record["scorePercentage"] = query.value("score_percentage").toFloat();
        record["createdAt"] = query.value("created_at").toString();
        record["questionBankInfo"] = query.value("question_bank_info").toString();
        record["pentagonType"] = query.value("pentagon_type").toString();
        
        result.append(record);
    }
    
    return result;
}

/**
 * 获取用户练习数据统计
 * @param workId 用户工号
 * @return 包含用户练习数据统计的Map
 */
QVariantMap DatabaseManager::getUserPracticeData(const QString &workId)
{
    QVariantMap result;
    
    // 获取基本用户信息
    QVariantMap userInfo = getFaceDataByWorkId(workId);
    if (userInfo.isEmpty()) {
        qWarning() << "无法获取用户信息，工号：" << workId;
        return result;
    }
    
    result["name"] = userInfo["name"];
    result["workId"] = workId;
    
    QSqlQuery query(m_database);
    
    // 统计总做题数
    query.prepare("SELECT COUNT(*) FROM user_answer_records WHERE workId = :workId");
    query.bindValue(":workId", workId);
    
    if (query.exec() && query.next()) {
        result["totalQuestions"] = query.value(0).toInt();
    } else {
        result["totalQuestions"] = 0;
        qWarning() << "获取总做题数失败：" << query.lastError().text();
    }
    
    // 统计正确题数和正确率
    query.prepare("SELECT SUM(correctCount), SUM(totalQuestions) FROM user_answer_records WHERE workId = :workId");
    query.bindValue(":workId", workId);
    
    if (query.exec() && query.next()) {
        int correctCount = query.value(0).toInt();
        int totalCount = query.value(1).toInt();
        
        result["correctCount"] = correctCount;
        
        // 计算正确率
        double accuracy = 0;
        if (totalCount > 0) {
            accuracy = (double)correctCount / totalCount * 100.0;
        }
        result["accuracy"] = QString::number(accuracy, 'f', 1) + "%";
    } else {
        result["correctCount"] = 0;
        result["accuracy"] = "0%";
        qWarning() << "获取正确题数失败：" << query.lastError().text();
    }
    
    // 获取平均用时（假设有duration字段，单位为秒）
    query.prepare("SELECT AVG(duration) FROM user_answer_records WHERE workId = :workId");
    query.bindValue(":workId", workId);
    
    if (query.exec() && query.next() && !query.value(0).isNull()) {
        double avgDuration = query.value(0).toDouble();
        result["averageDuration"] = QString::number(avgDuration, 'f', 1) + "秒";
    } else {
        result["averageDuration"] = "暂无";
        qWarning() << "获取平均用时失败：" << query.lastError().text();
    }
    
    // 获取最近一次做题时间
    query.prepare("SELECT MAX(createdAt) FROM user_answer_records WHERE workId = :workId");
    query.bindValue(":workId", workId);
    
    if (query.exec() && query.next() && !query.value(0).isNull()) {
        QDateTime lastTime = query.value(0).toDateTime();
        result["lastPracticeTime"] = lastTime.toString("yyyy-MM-dd hh:mm:ss");
    } else {
        result["lastPracticeTime"] = "暂无";
        qWarning() << "获取最近做题时间失败：" << query.lastError().text();
    }
    
    return result;
}

/**
 * 获取用户按月练习数据统计
 * @param workId 用户工号
 * @param monthCount 需要获取的月份数量
 * @return 包含用户每月练习数据统计的列表
 */
QVariantList DatabaseManager::getUserMonthlyPracticeData(const QString &workId, int monthCount)
{
    QVariantList result;
    
    // 检查用户是否存在
    if (!userExists(workId)) {
        qWarning() << "用户不存在，工号：" << workId;
        return result;
    }
    
    // 获取当前日期
    QDate currentDate = QDate::currentDate();
    
    // 循环处理每个月的数据
    for (int i = 0; i < monthCount; ++i) {
        QVariantMap monthData;
        
        // 计算月份，从当前月份往前推
        QDate targetDate = currentDate.addMonths(-i);
        int year = targetDate.year();
        int month = targetDate.month();
        
        // 设置月份信息
        monthData["year"] = year;
        monthData["month"] = month;
        monthData["monthName"] = QString("%1年%2月").arg(year).arg(month);
        
        // 获取月份第一天和最后一天
        QDate firstDay(year, month, 1);
        QDate lastDay = firstDay.addMonths(1).addDays(-1);
        
        // 转换为ISO格式的字符串，适用于SQLite日期比较
        QString startDate = firstDay.toString(Qt::ISODate);
        QString endDate = lastDay.toString(Qt::ISODate);
        
        QSqlQuery query(m_database);
        
        // 查询该月完成的题目数量
        query.prepare("SELECT COUNT(*), SUM(correctCount), SUM(totalQuestions) "
                     "FROM user_answer_records "
                     "WHERE workId = :workId "
                     "AND date(createdAt) >= date(:startDate) "
                     "AND date(createdAt) <= date(:endDate)");
        query.bindValue(":workId", workId);
        query.bindValue(":startDate", startDate);
        query.bindValue(":endDate", endDate);
        
        if (query.exec() && query.next()) {
            int recordCount = query.value(0).toInt();
            int correctCount = query.value(1).isNull() ? 0 : query.value(1).toInt();
            int totalCount = query.value(2).isNull() ? 0 : query.value(2).toInt();
            
            // 设置月度数据
            monthData["recordCount"] = recordCount;
            monthData["totalQuestions"] = totalCount;
            monthData["correctCount"] = correctCount;
            
            // 计算正确率
            double accuracy = 0;
            if (totalCount > 0) {
                accuracy = (double)correctCount / totalCount * 100.0;
            }
            monthData["accuracy"] = QString::number(accuracy, 'f', 1) + "%";
            
            // 设置没有数据的标志
            monthData["hasData"] = (recordCount > 0);
        } else {
            // 查询出错或没有数据
            monthData["recordCount"] = 0;
            monthData["totalQuestions"] = 0;
            monthData["correctCount"] = 0;
            monthData["accuracy"] = "0%";
            monthData["hasData"] = false;
            qWarning() << "获取月度数据失败：" << query.lastError().text();
        }
        
        // 获取平均用时
        query.prepare("SELECT AVG(duration) "
                     "FROM user_answer_records "
                     "WHERE workId = :workId "
                     "AND date(createdAt) >= date(:startDate) "
                     "AND date(createdAt) <= date(:endDate)");
        query.bindValue(":workId", workId);
        query.bindValue(":startDate", startDate);
        query.bindValue(":endDate", endDate);
        
        if (query.exec() && query.next() && !query.value(0).isNull()) {
            double avgDuration = query.value(0).toDouble();
            monthData["averageDuration"] = QString::number(avgDuration, 'f', 1) + "秒";
        } else {
            monthData["averageDuration"] = "暂无";
        }
        
        result.append(monthData);
    }
    
    return result;
}

/**
 * 获取用户每日刷题数据
 * @param workId 用户工号
 * @param year 年份
 * @param month 月份
 * @return 包含用户每日刷题数据的列表
 */
QVariantList DatabaseManager::getUserDailyPracticeData(const QString &workId, int year, int month)
{
    QVariantList result;
    
    // 检查用户是否存在
    if (!userExists(workId)) {
        qWarning() << "用户不存在，工号：" << workId;
        return result;
    }
    
    // 获取月份的第一天和最后一天
    QDate firstDay(year, month, 1);
    QDate lastDay = firstDay.addMonths(1).addDays(-1);
    
    // 转换为ISO格式的字符串，适用于SQLite日期比较
    QString startDate = firstDay.toString(Qt::ISODate);
    QString endDate = lastDay.toString(Qt::ISODate);
    
    QSqlQuery query(m_database);
    
    // 查询该用户在指定月份每天的做题数量
    query.prepare("SELECT strftime('%d', createdAt) as day, "
                 "SUM(totalQuestions) as questionCount "
                 "FROM user_answer_records "
                 "WHERE workId = :workId "
                 "AND date(createdAt) >= date(:startDate) "
                 "AND date(createdAt) <= date(:endDate) "
                 "GROUP BY strftime('%d', createdAt) "
                 "ORDER BY day");
    
    query.bindValue(":workId", workId);
    query.bindValue(":startDate", startDate);
    query.bindValue(":endDate", endDate);
    
    if (query.exec()) {
        while (query.next()) {
            QVariantMap dayData;
            // 注意：day 可能有前导零，需要转换为整数
            dayData["day"] = query.value("day").toString().toInt();
            dayData["questionCount"] = query.value("questionCount").toInt();
            result.append(dayData);
        }
    } else {
        qWarning() << "获取每日刷题数据失败：" << query.lastError().text();
    }
    
    return result;
}

/**
 * 获取用户当月刷题数量
 * @param workId 用户工号
 * @return 当月刷题总数
 */
int DatabaseManager::getUserCurrentMonthQuestionCount(const QString &workId)
{
    // 检查用户是否存在
    if (!userExists(workId)) {
        qWarning() << "用户不存在，工号：" << workId;
        return 0;
    }
    
    // 获取当前日期
    QDate currentDate = QDate::currentDate();
    int year = currentDate.year();
    int month = currentDate.month();
    
    // 获取当月第一天和最后一天
    QDate firstDay(year, month, 1);
    QDate lastDay = firstDay.addMonths(1).addDays(-1);
    
    // 转换为ISO格式的字符串，适用于SQLite日期比较
    QString startDate = firstDay.toString(Qt::ISODate);
    QString endDate = lastDay.toString(Qt::ISODate);
    
    QSqlQuery query(m_database);
    
    // 查询当月完成的星火日课题目总数
    query.prepare("SELECT SUM(total_questions) "
                 "FROM user_answer_records "
                 "WHERE work_id = :workId "
                 "AND exam_type = '星火日课' "  // 限定为星火日课
                 "AND date(created_at) >= date(:startDate) "
                 "AND date(created_at) <= date(:endDate)");
    query.bindValue(":workId", workId);
    query.bindValue(":startDate", startDate);
    query.bindValue(":endDate", endDate);
    
    if (query.exec() && query.next()) {
        // 如果结果为NULL，返回0
        return query.value(0).isNull() ? 0 : query.value(0).toInt();
    } else {
        qWarning() << "获取当月刷题数量失败：" << query.lastError().text();
        return 0;
    }
}

/**
 * 获取用户年度刷题数据（按月统计）
 * @param workId 用户工号
 * @return 包含12个月刷题数量的列表
 */
QVariantList DatabaseManager::getUserYearlyQuestionData(const QString &workId)
{
    QVariantList result;
    
    // 检查用户是否存在
    if (!userExists(workId)) {
        qWarning() << "用户不存在，工号：" << workId;
        // 返回12个月的空数据
        for (int i = 0; i < 12; ++i) {
            result.append(0);
        }
        return result;
    }
    
    // 获取当前日期
    QDate currentDate = QDate::currentDate();
    int currentYear = currentDate.year();
    
    // 为每个月初始化数据为0
    for (int i = 0; i < 12; ++i) {
        result.append(0);
    }
    
    QSqlQuery query(m_database);
    
    // 查询本年度每月的星火日课题目总数
    query.prepare("SELECT strftime('%m', created_at) as month, "
                 "SUM(total_questions) as questionCount "
                 "FROM user_answer_records "
                 "WHERE work_id = :workId "
                 "AND exam_type = '星火日课' "  // 限定为星火日课
                 "AND strftime('%Y', created_at) = :year "
                 "GROUP BY strftime('%m', created_at) "
                 "ORDER BY month");
    
    query.bindValue(":workId", workId);
    query.bindValue(":year", QString::number(currentYear));
    
    if (query.exec()) {
        while (query.next()) {
            // 月份从1开始，所以需要减1作为索引
            int monthIndex = query.value("month").toString().toInt() - 1;
            int questionCount = query.value("questionCount").toInt();
            
            if (monthIndex >= 0 && monthIndex < 12) {
                result[monthIndex] = questionCount;
            }
        }
    } else {
        qWarning() << "获取年度刷题数据失败：" << query.lastError().text();
    }
    
    return result;
}

/**
 * 获取用户滚动年度刷题数据（从当前月份向前12个月）
 * @param workId 用户工号
 * @return 包含过去12个月刷题数量的列表，按照时间顺序（最早的月份在前）
 */
QVariantList DatabaseManager::getUserRollingYearQuestionData(const QString &workId)
{
    QVariantList result;
    
    // 检查用户是否存在
    if (!userExists(workId)) {
        qWarning() << "用户不存在，工号：" << workId;
        // 返回12个月的空数据
        for (int i = 0; i < 12; ++i) {
            result.append(0);
        }
        return result;
    }
    
    // 获取当前日期
    QDate currentDate = QDate::currentDate();
    
    // 计算12个月前的日期
    QDate startDate = currentDate.addMonths(-11);
    startDate.setDate(startDate.year(), startDate.month(), 1); // 设置为月初
    
    // 设置当前月的月末（这样才能包含当月数据）
    int lastDay = QDate(currentDate.year(), currentDate.month(), 1).daysInMonth();
    QDate endDate = QDate(currentDate.year(), currentDate.month(), lastDay);
    
    qDebug() << "获取从" << startDate.toString(Qt::ISODate) 
             << "到" << endDate.toString(Qt::ISODate) << "的滚动年度数据";
    
    // 为12个月初始化数组
    QMap<QString, int> monthData;
    
    // 生成过去12个月的年月键，从11个月前到当前月
    for (int i = 0; i < 12; ++i) {
        QDate month = startDate.addMonths(i);
        // 格式必须与SQLite的strftime('%Y-%m')格式一致
        QString yearStr = QString::number(month.year());
        QString monthStr = QString("%1").arg(month.month(), 2, 10, QChar('0'));
        QString key = yearStr + "-" + monthStr;
        
        monthData[key] = 0;
        qDebug() << "初始化月份数据:" << key;
    }
    
    QSqlQuery query(m_database);
    
    // 查询过去12个月的星火日课题目总数，使用精确的年月格式
    query.prepare("SELECT strftime('%Y-%m', created_at) as yearMonth, "
                 "SUM(total_questions) as questionCount "
                 "FROM user_answer_records "
                 "WHERE work_id = :workId "
                 "AND exam_type = '星火日课' "
                 "AND date(created_at) >= date(:startDate) "
                 "AND date(created_at) <= date(:endDate) "
                 "GROUP BY yearMonth "
                 "ORDER BY yearMonth");
    
    query.bindValue(":workId", workId);
    query.bindValue(":startDate", startDate.toString(Qt::ISODate));
    query.bindValue(":endDate", endDate.toString(Qt::ISODate));
    
    if (query.exec()) {
        while (query.next()) {
            QString yearMonth = query.value("yearMonth").toString();
            int questionCount = query.value("questionCount").toInt();
            
            qDebug() << "查询到月份数据:" << yearMonth << "题目数:" << questionCount;
            
            // 如果在我们的映射中存在该月，则更新数据
            if (monthData.contains(yearMonth)) {
                monthData[yearMonth] = questionCount;
            }
        }
    } else {
        qWarning() << "获取滚动年度刷题数据失败：" << query.lastError().text();
    }
    
    // 按时间顺序将数据添加到结果列表（从最早的月份开始）
    for (int i = 0; i < 12; ++i) {
        QDate month = startDate.addMonths(i);
        // 使用与前面相同的格式构建键
        QString yearStr = QString::number(month.year());
        QString monthStr = QString("%1").arg(month.month(), 2, 10, QChar('0'));
        QString key = yearStr + "-" + monthStr;
        
        result.append(monthData[key]);
        qDebug() << "添加到结果数组:" << key << "值:" << monthData[key] << "，索引:" << i;
    }
    
    return result;
}

/**
 * 获取用户能力值数据
 * @param workId 用户工号
 * @return 包含用户各时期能力值数据的映射
 */
QVariantMap DatabaseManager::getUserAbilityData(const QString &workId)
{
    QVariantMap result;
    
    // 检查用户是否存在
    if (!userExists(workId)) {
        qWarning() << "用户不存在，工号：" << workId;
        return result;
    }
    
    // 获取当前日期
    QDate currentDate = QDate::currentDate();
    
    // 获取当前月及前两个月的数据
    QList<QVariantList> monthlyAbilityData;
    
    for (int i = 0; i < 3; ++i) {
        QVariantList abilityData;
        // 初始化5个能力维度的数据（初始值为随机数）
        // 实际应用中，这里应该从数据库中查询实际的能力值数据
        
        // 当前月减i个月
        QDate targetDate = currentDate.addMonths(-i);
        int year = targetDate.year();
        int month = targetDate.month();
        
        // 获取月份的第一天和最后一天
        QDate firstDay(year, month, 1);
        QDate lastDay = firstDay.addMonths(1).addDays(-1);
        
        // 转换为ISO格式的字符串
        QString startDate = firstDay.toString(Qt::ISODate);
        QString endDate = lastDay.toString(Qt::ISODate);
        
        // 基于该用户在指定月份的练习数据生成能力值
        // 这里使用一个简单算法生成模拟数据，实际应用中应根据实际需求实现
        QSqlQuery query(m_database);
        query.prepare("SELECT COUNT(*), SUM(correctCount), SUM(totalQuestions) "
                     "FROM user_answer_records "
                     "WHERE workId = :workId "
                     "AND date(createdAt) >= date(:startDate) "
                     "AND date(createdAt) <= date(:endDate)");
        query.bindValue(":workId", workId);
        query.bindValue(":startDate", startDate);
        query.bindValue(":endDate", endDate);
        
        int recordCount = 0;
        double accuracy = 0;
        
        if (query.exec() && query.next()) {
            recordCount = query.value(0).toInt();
            int correctCount = query.value(1).isNull() ? 0 : query.value(1).toInt();
            int totalCount = query.value(2).isNull() ? 0 : query.value(2).toInt();
            
            if (totalCount > 0) {
                accuracy = (double)correctCount / totalCount;
            }
        }
        
        // 使用记录数和正确率生成能力值数据
        // 这里简单地根据做题数量和正确率生成5个维度的能力值
        
        // 1. 理解能力（基于做题正确率）
        double comprehension = 30 + 70 * accuracy;
        abilityData.append(comprehension);
        
        // 2. 记忆力（基于做题数量）
        double memory = recordCount > 0 ? 40 + std::min(60.0, recordCount * 2.0) : 40;
        abilityData.append(memory);
        
        // 3. 推理能力（基于正确率和做题量的综合）
        double reasoning = 30 + 35 * accuracy + std::min(35.0, recordCount * 1.0);
        abilityData.append(reasoning);
        
        // 4. 应用能力（基于正确率）
        double application = 20 + 80 * accuracy;
        abilityData.append(application);
        
        // 5. 创新能力（较难量化，这里基于做题量和正确率给一个保守估计）
        double innovation = 20 + 40 * accuracy + std::min(40.0, recordCount * 1.5);
        abilityData.append(innovation);
        
        // 存储到月度数据列表
        monthlyAbilityData.append(abilityData);
    }
    
    // 将三个月的数据添加到结果映射
    if (monthlyAbilityData.size() >= 3) {
        result["currentMonth"] = monthlyAbilityData[0];
        result["lastMonth"] = monthlyAbilityData[1];
        result["twoMonthsAgo"] = monthlyAbilityData[2];
    }
    
    return result;
}

/**
 * 获取所有用户当月最大刷题量
 * @return 所有用户当月最大刷题量
 */
int DatabaseManager::getMaxMonthlyQuestionCount()
{
    // 获取当前日期
    QDate currentDate = QDate::currentDate();
    int year = currentDate.year();
    int month = currentDate.month();
    
    // 获取当月第一天和最后一天
    QDate firstDay(year, month, 1);
    QDate lastDay = firstDay.addMonths(1).addDays(-1);
    
    // 转换为ISO格式的字符串，适用于SQLite日期比较
    QString startDate = firstDay.toString(Qt::ISODate);
    QString endDate = lastDay.toString(Qt::ISODate);
    
    QSqlQuery query(m_database);
    
    // 查询当月每个用户的星火日课题目总数，并获取最大值
    query.prepare("SELECT work_id, SUM(total_questions) as total "
                 "FROM user_answer_records "
                 "WHERE exam_type = '星火日课' "
                 "AND date(created_at) >= date(:startDate) "
                 "AND date(created_at) <= date(:endDate) "
                 "GROUP BY work_id "
                 "ORDER BY total DESC "
                 "LIMIT 1");
    query.bindValue(":startDate", startDate);
    query.bindValue(":endDate", endDate);
    
    if (query.exec() && query.next()) {
        // 如果结果为NULL，返回默认值20
        int maxCount = query.value("total").isNull() ? 20 : query.value("total").toInt();
        qDebug() << "本月最大刷题量：" << maxCount;
        return maxCount;
    } else {
        qWarning() << "获取最大刷题量失败：" << query.lastError().text();
        // 如果没有记录，返回默认值20
        return 20;
    }
}

/**
 * 更新数据库架构，添加新的列
 * @return 是否成功更新
 */
bool DatabaseManager::updateDatabaseSchema()
{
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return false;
        }
    }
    
    QSqlQuery query(m_database);
    
    // 检查user_answer_records表中是否存在question_bank_info列
    query.prepare("PRAGMA table_info(user_answer_records)");
    if (!query.exec()) {
        qDebug() << "检查表结构失败:" << query.lastError().text();
        return false;
    }
    
    bool hasQuestionBankInfo = false;
    bool hasPentagonType = false;
    
    while (query.next()) {
        QString columnName = query.value(1).toString();
        if (columnName == "question_bank_info") {
            hasQuestionBankInfo = true;
        } else if (columnName == "pentagon_type") {
            hasPentagonType = true;
        }
    }
    
    // 添加question_bank_info列（如果不存在）
    if (!hasQuestionBankInfo) {
        qDebug() << "添加question_bank_info列到user_answer_records表";
        if (!query.exec("ALTER TABLE user_answer_records ADD COLUMN question_bank_info TEXT")) {
            qDebug() << "添加question_bank_info列失败:" << query.lastError().text();
            // 继续执行，尝试添加下一列
        }
    }
    
    // 添加pentagon_type列（如果不存在）
    if (!hasPentagonType) {
        qDebug() << "添加pentagon_type列到user_answer_records表";
        if (!query.exec("ALTER TABLE user_answer_records ADD COLUMN pentagon_type TEXT")) {
            qDebug() << "添加pentagon_type列失败:" << query.lastError().text();
            return false;
        }
    }
    
    return true;
}

/**
 * 获取用户的五芒图数据（当月、上月、上上月）
 * @param workId 用户工号
 * @return 包含用户五芒图数据的Map
 */
QVariantMap DatabaseManager::getUserPentagonData(const QString &workId)
{
    QVariantMap result;
    
    // 初始化结果结构
    QVariantMap currentMonthData;  // 当月数据
    QVariantMap lastMonthData;     // 上月数据
    QVariantMap twoMonthsAgoData;  // 上上月数据
    
    // 检查用户是否存在
    if (!userExists(workId)) {
        qWarning() << "用户不存在，工号：" << workId;
        return result;
    }
    
    // 获取当前日期
    QDate currentDate = QDate::currentDate();
    
    // 计算当月、上月和上上月的日期范围
    QList<QPair<QDate, QDate>> dateRanges;
    
    for (int i = 0; i < 3; ++i) {
        QDate targetDate = currentDate.addMonths(-i);
        int year = targetDate.year();
        int month = targetDate.month();
        
        // 获取月份的第一天和最后一天
        QDate firstDay(year, month, 1);
        QDate lastDay = firstDay.addMonths(1).addDays(-1);
        
        dateRanges.append(qMakePair(firstDay, lastDay));
    }
    
    // 五芒图的维度类型列表
    QStringList pentagonTypes;
    pentagonTypes << "基础认知" << "原理理解" << "操作应用" << "诊断分析" << "安全规范";
    
    // 存储当月、上月、上上月的数据集
    QList<QVariantMap*> dataSets;
    dataSets << &currentMonthData << &lastMonthData << &twoMonthsAgoData;
    
    // 为每个月初始化五芒图各维度的数据结构
    for (int i = 0; i < dataSets.size(); ++i) {
        for (const QString &type : pentagonTypes) {
            QVariantMap typeData;
            typeData["totalQuestions"] = 0;
            typeData["correctCount"] = 0;
            typeData["accuracy"] = 0.0;
            (*dataSets[i])[type] = typeData;
        }
    }
    
    // 从数据库查询每个月的记录
    for (int i = 0; i < dateRanges.size(); ++i) {
        QDate firstDay = dateRanges[i].first;
        QDate lastDay = dateRanges[i].second;
        
        // 转换为ISO格式的字符串
        QString startDate = firstDay.toString(Qt::ISODate);
        QString endDate = lastDay.toString(Qt::ISODate);
        
        QSqlQuery query(m_database);
        
        // 查询该用户在指定月份的所有答题记录
        query.prepare("SELECT pentagon_type FROM user_answer_records "
                     "WHERE work_id = :workId "
                     "AND date(created_at) >= date(:startDate) "
                     "AND date(created_at) <= date(:endDate)");
        
        query.bindValue(":workId", workId);
        query.bindValue(":startDate", startDate);
        query.bindValue(":endDate", endDate);
        
        if (query.exec()) {
            qDebug() << "查询" << (i == 0 ? "当月" : (i == 1 ? "上月" : "上上月")) << "数据成功，日期范围:" 
                     << startDate << "至" << endDate;
            
            int recordCount = 0;
            while (query.next()) {
                recordCount++;
                QString pentagonTypeStr = query.value("pentagon_type").toString();
                qDebug() << "解析第" << recordCount << "条五芒图数据: " << pentagonTypeStr;
                
                // 解析pentagon_type字段
                // 格式示例: "原理理解：1题，正确1题，正确率100%，基础认知：1题，正确0题，正确率0%，..."
                QStringList typeEntries = pentagonTypeStr.split("，");
                qDebug() << "分割后的条目数量: " << typeEntries.size();
                
                // 测试输出每个分割后的条目
                for (int d = 0; d < typeEntries.size(); d++) {
                    qDebug() << "  条目" << (d+1) << ": " << typeEntries[d];
                }
                
                // 新的解析逻辑：采用更直接的方式解析每个部分
                for (int idx = 0; idx < typeEntries.size(); ++idx) {
                    QString entry = typeEntries[idx];
                    
                    // 跳过空条目
                    if (entry.trimmed().isEmpty()) continue;
                    
                    // 检查条目格式
                    if (!entry.contains("：")) {
                        qDebug() << "  条目格式不正确，跳过: " << entry;
                        continue;
                    }
                    
                    // 拆分类型名称和数据部分
                    QString typeName = entry.section("：", 0, 0);
                    QString dataPart = entry.section("：", 1);
                    
                    qDebug() << "  类型名称: " << typeName << ", 数据部分: " << dataPart;
                    
                    // 如果这个类型不在我们关注的五芒图类型中，跳过
                    if (!pentagonTypes.contains(typeName)) {
                        qDebug() << "  不在关注的类型列表中，跳过";
                        continue;
                    }
                    
                    // 提取题目数量 - "X题"
                    QString totalPart = dataPart;
                    if (totalPart.contains("题"))
                        totalPart = totalPart.left(totalPart.indexOf("题"));
                    
                    int totalQuestions = totalPart.toInt();
                    qDebug() << "  题目总数: " << totalQuestions;
                    
                    // 查找下一个条目获取正确数量
                    int correctCount = 0;
                    QString correctPart;
                    
                    // 寻找包含"正确"的下一个条目
                    if (idx + 1 < typeEntries.size() && typeEntries[idx + 1].startsWith("正确")) {
                        correctPart = typeEntries[idx + 1];
                        idx++; // 跳过这个已经处理的条目
                        
                        // 解析正确题数 - "正确X题"
                        if (correctPart.contains("题"))
                            correctPart = correctPart.left(correctPart.indexOf("题"));
                        
                        correctPart.remove("正确");
                        correctCount = correctPart.toInt();
                        qDebug() << "  正确题数: " << correctCount;
                    } else {
                        qDebug() << "  没有找到正确题数信息，默认为0";
                    }
                    
                    // 更新数据集
                    QVariantMap typeData = (*dataSets[i])[typeName].toMap();
                    typeData["totalQuestions"] = typeData["totalQuestions"].toInt() + totalQuestions;
                    typeData["correctCount"] = typeData["correctCount"].toInt() + correctCount;
                    
                    // 重新计算正确率
                    double accuracy = 0.0;
                    if (typeData["totalQuestions"].toInt() > 0) {
                        accuracy = (double)typeData["correctCount"].toInt() / typeData["totalQuestions"].toInt();
                    }
                    typeData["accuracy"] = accuracy;
                    
                    // 更新数据集
                    (*dataSets[i])[typeName] = typeData;
                    
                    qDebug() << "  更新" << (i == 0 ? "当月" : (i == 1 ? "上月" : "上上月")) 
                             << typeName << "数据: 累计题数=" << typeData["totalQuestions"].toInt() 
                             << ", 累计正确=" << typeData["correctCount"].toInt() 
                             << ", 正确率=" << (accuracy * 100) << "%";
                    
                    // 如果还有"正确率"部分，跳过它
                    if (idx + 1 < typeEntries.size() && typeEntries[idx + 1].startsWith("正确率")) {
                        idx++; // 跳过正确率条目
                    }
                }
            }
            qDebug() << "共处理了" << recordCount << "条记录";
        } else {
            qWarning() << "获取" << (i == 0 ? "当月" : (i == 1 ? "上月" : "上上月")) 
                       << "五芒图数据失败：" << query.lastError().text();
        }
    }
    
    // 构建最终结果
    result["currentMonth"] = currentMonthData;
    result["lastMonth"] = lastMonthData;
    result["twoMonthsAgo"] = twoMonthsAgoData;
    
    return result;
} 