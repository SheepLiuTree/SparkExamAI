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

    // 启用外键约束
    QSqlQuery pragmaQuery;
    if (!pragmaQuery.exec("PRAGMA foreign_keys = ON")) {
        qDebug() << "Failed to enable foreign keys:" << pragmaQuery.lastError().text();
    } else {
        qDebug() << "Foreign keys enabled successfully";
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
        int questionId = query.value("id").toInt();
        
        question["id"] = questionId;
        question["content"] = query.value("content").toString();
        question["answer"] = query.value("answer").toString();
        question["analysis"] = query.value("analysis").toString();
        
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