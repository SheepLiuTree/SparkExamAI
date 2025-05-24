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
#include <QUrl>

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
    if (QSqlDatabase::contains(QSqlDatabase::defaultConnection)) {
        m_database = QSqlDatabase::database(QSqlDatabase::defaultConnection);
    } else {
        m_database = QSqlDatabase::addDatabase("QSQLITE");
    }
    
    // 检查数据库目录是否存在
    QFileInfo dbPathInfo(m_dbPath);
    QDir dbDir = dbPathInfo.dir();
    
    // 详细记录数据库路径信息
    qDebug() << "数据库文件路径: " << m_dbPath;
    qDebug() << "数据库目录: " << dbDir.absolutePath();
    qDebug() << "数据库目录存在: " << (dbDir.exists() ? "是" : "否");
    
    // 如果数据库目录不存在，尝试创建
    if (!dbDir.exists()) {
        qDebug() << "数据库目录不存在，尝试创建...";
        if (!dbDir.mkpath(dbDir.absolutePath())) {
            qDebug() << "创建数据库目录失败";
            return false;
        } else {
            qDebug() << "成功创建数据库目录";
        }
    }
    
    // 检查目录权限
    QFileInfo dirInfo(dbDir.absolutePath());
    qDebug() << "数据库目录权限: " 
             << (dirInfo.isReadable() ? "可读 " : "不可读 ")
             << (dirInfo.isWritable() ? "可写 " : "不可写 ")
             << (dirInfo.isExecutable() ? "可执行" : "不可执行");
    
    // 如果数据库文件已存在，检查其权限
    if (dbPathInfo.exists()) {
        qDebug() << "数据库文件已存在，大小: " << dbPathInfo.size() << " 字节";
        qDebug() << "数据库文件权限: " 
                << (dbPathInfo.isReadable() ? "可读 " : "不可读 ")
                << (dbPathInfo.isWritable() ? "可写" : "不可写");
    } else {
        qDebug() << "数据库文件不存在，将在首次访问时创建";
    }
    
    // 设置数据库文件路径
    m_database.setDatabaseName(m_dbPath);
    
    if (!m_database.open()) {
        qDebug() << "无法打开数据库:" << m_database.lastError().text();
        
        // 如果是因为目录不存在或权限问题，输出更多信息
        QSqlError error = m_database.lastError();
        qDebug() << "错误类型:" << error.type() << " 错误码:" << error.nativeErrorCode();
        qDebug() << "驱动错误:" << error.driverText();
        qDebug() << "数据库错误:" << error.databaseText();
        
        return false;
    }
    
    qDebug() << "数据库连接成功打开";
    
    // 创建表
    if (!createTables()) {
        qDebug() << "创建数据库表失败";
        return false;
    }
    
    // 更新数据库架构（添加新字段）
    if (!updateDatabaseSchema()) {
        qDebug() << "更新数据库架构失败";
        // 继续执行，不因此中断程序
    }
    
    // 初始化默认设置
    initDefaultSettings();
    
    qDebug() << "数据库初始化完成";
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
        "score_percentage REAL DEFAULT 0, "  // 添加score_percentage字段
        "question_bank_info TEXT, "
        "pentagon_type TEXT, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"  // 使用created_at而不是submission_time
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create user_answer_records table:" << query.lastError().text();
        return false;
    }
    
    // 创建用户题库进度表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS user_bank_progress ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "work_id TEXT NOT NULL, "
        "bank_id INTEGER NOT NULL, "
        "current_question_index INTEGER DEFAULT 0, "
        "user_answers TEXT NOT NULL, "
        "last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "UNIQUE(work_id, bank_id), "
        "FOREIGN KEY (work_id) REFERENCES users(work_id), "
        "FOREIGN KEY (bank_id) REFERENCES question_banks(id) ON DELETE CASCADE"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create user_bank_progress table:" << query.lastError().text();
        return false;
    }
    
    // 创建用户错题集表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS user_wrong_questions ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "work_id TEXT NOT NULL, "
        "bank_id INTEGER NOT NULL, "
        "question_id INTEGER NOT NULL, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "UNIQUE(work_id, question_id), "
        "FOREIGN KEY (work_id) REFERENCES users(work_id), "
        "FOREIGN KEY (bank_id) REFERENCES question_banks(id) ON DELETE CASCADE, "
        "FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create user_wrong_questions table:" << query.lastError().text();
        return false;
    }

    // 创建账户信息表
    success = query.exec(
        "CREATE TABLE IF NOT EXISTS accounts ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "username TEXT NOT NULL, "
        "work_id TEXT NOT NULL UNIQUE, "
        "password TEXT NOT NULL, "
        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "last_login TIMESTAMP, "
        "is_active BOOLEAN DEFAULT 1"
        ")"
    );

    if (!success) {
        qDebug() << "Failed to create accounts table:" << query.lastError().text();
        return false;
    }

    return true;
}

bool DatabaseManager::addFaceData(const QString &name, const QString &gender, 
                                 const QString &workId, const QString &faceImagePath, 
                                 const QString &avatarPath, bool isAdmin)
{
    QSqlQuery query;
    
    // 将绝对路径转换为相对路径
    QString appDir = QCoreApplication::applicationDirPath();
    QString relativeFaceImagePath = faceImagePath;
    QString relativeAvatarPath = avatarPath;
    
    // 移除应用程序目录前缀，转换为相对路径
    if (relativeFaceImagePath.startsWith(appDir)) {
        relativeFaceImagePath = relativeFaceImagePath.mid(appDir.length());
        // 确保路径以/开头
        if (!relativeFaceImagePath.startsWith("/")) {
            relativeFaceImagePath = "/" + relativeFaceImagePath;
        }
    }
    
    if (relativeAvatarPath.startsWith(appDir)) {
        relativeAvatarPath = relativeAvatarPath.mid(appDir.length());
        // 确保路径以/开头
        if (!relativeAvatarPath.startsWith("/")) {
            relativeAvatarPath = "/" + relativeAvatarPath;
        }
    }
    
    query.prepare(
        "INSERT INTO users (name, gender, work_id, face_image_path, avatar_path, is_admin) "
        "VALUES (:name, :gender, :work_id, :face_image_path, :avatar_path, :is_admin)"
    );
    
    query.bindValue(":name", name);
    query.bindValue(":gender", gender);
    query.bindValue(":work_id", workId);
    query.bindValue(":face_image_path", relativeFaceImagePath);
    query.bindValue(":avatar_path", relativeAvatarPath);
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
    QString appDir = QCoreApplication::applicationDirPath();
    
    while (query.next()) {
        QVariantMap row;
        row["id"] = query.value("id").toInt();
        row["name"] = query.value("name").toString();
        row["gender"] = query.value("gender").toString();
        row["workId"] = query.value("work_id").toString();
        
        // 获取图像路径
        QString faceImagePath = query.value("face_image_path").toString();
        QString avatarPath = query.value("avatar_path").toString();
        
        // 转换相对路径为绝对路径并进行URL编码
        if (!faceImagePath.isEmpty() && !faceImagePath.startsWith("file:///")) {
            if (faceImagePath.startsWith("/")) {
                faceImagePath = appDir + faceImagePath;
            } else {
                faceImagePath = appDir + "/" + faceImagePath;
            }
            
            // 将路径编码为URL格式以处理中文和特殊字符
            QUrl fileUrl = QUrl::fromLocalFile(faceImagePath);
            faceImagePath = fileUrl.toString();
        }
        
        if (!avatarPath.isEmpty() && !avatarPath.startsWith("file:///")) {
            if (avatarPath.startsWith("/")) {
                avatarPath = appDir + avatarPath;
            } else {
                avatarPath = appDir + "/" + avatarPath;
            }
            
            // 将路径编码为URL格式以处理中文和特殊字符
            QUrl fileUrl = QUrl::fromLocalFile(avatarPath);
            avatarPath = fileUrl.toString();
        }
        
        row["faceImage"] = faceImagePath;
        row["avatarPath"] = avatarPath;
        
        row["isAdmin"] = query.value("is_admin").toBool();
        row["createdAt"] = query.value("created_at").toString();
        
        result.append(row);
    }
    
    return result;
}

QVariantList DatabaseManager::getAllFaceDataSorted()
{
    QVariantList result;
    QString appDir = QCoreApplication::applicationDirPath();
    
    // 从设置中获取排序方式
    QString sortOption = getSetting("home_sort_option", "1");
    // 添加更多调试信息，检查排序选项的实际值并清除可能的空白
    QString trimmedOption = sortOption.trimmed();
    qDebug() << "排序选项原始值: [" << sortOption << "], 长度: " << sortOption.length() 
             << ", 清除空白后: [" << trimmedOption << "], 长度: " << trimmedOption.length();
    
    // 确保将字符串转换为整数进行比较，只有明确为"0"的值才视为刷题数排序
    bool byAbility = (trimmedOption != "0");
    
    qDebug() << "排序方式最终决定: " << (byAbility ? "按个人能力排序" : "按本月刷题数排序") << " (home_sort_option=" << sortOption << ")";
    
    // 获取所有用户的基本信息
    QSqlQuery query("SELECT * FROM users");
    QList<QVariantMap> users;
    
    while (query.next()) {
        QVariantMap row;
        row["id"] = query.value("id").toInt();
        row["name"] = query.value("name").toString();
        row["gender"] = query.value("gender").toString();
        row["workId"] = query.value("work_id").toString();
        
        // 获取图像路径
        QString faceImagePath = query.value("face_image_path").toString();
        QString avatarPath = query.value("avatar_path").toString();
        
        // 转换相对路径为绝对路径并进行URL编码
        if (!faceImagePath.isEmpty() && !faceImagePath.startsWith("file:///")) {
            if (faceImagePath.startsWith("/")) {
                faceImagePath = appDir + faceImagePath;
            } else {
                faceImagePath = appDir + "/" + faceImagePath;
            }
            
            // 将路径编码为URL格式以处理中文和特殊字符
            QUrl fileUrl = QUrl::fromLocalFile(faceImagePath);
            faceImagePath = fileUrl.toString();
        }
        
        if (!avatarPath.isEmpty() && !avatarPath.startsWith("file:///")) {
            if (avatarPath.startsWith("/")) {
                avatarPath = appDir + avatarPath;
            } else {
                avatarPath = appDir + "/" + avatarPath;
            }
            
            // 将路径编码为URL格式以处理中文和特殊字符
            QUrl fileUrl = QUrl::fromLocalFile(avatarPath);
            avatarPath = fileUrl.toString();
        }
        
        row["faceImage"] = faceImagePath;
        row["avatarPath"] = avatarPath;
        
        row["isAdmin"] = query.value("is_admin").toBool();
        row["createdAt"] = query.value("created_at").toString();
        
        users.append(row);
    }
    
    qDebug() << "从数据库获取到 " << users.size() << " 个用户";
    
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
    
    qDebug() << "当前日期: " << currentDate.toString("yyyy-MM-dd") 
             << ", 本月日期范围: " << startDate << " 至 " << endDate;
    
    // 为每个用户计算排序值
    QList<QPair<QVariantMap, double>> sortedUsers;
    
    for (const QVariantMap &user : users) {
        QString workId = user["workId"].toString();
        QString name = user["name"].toString();
        double sortValue = 0;
        
        if (byAbility) {
            // 按个人能力五芒图中的正确率之和排序
            QVariantMap pentagonData = getUserPentagonData(workId);
            
            qDebug() << "===== 用户 " << name << " (工号: " << workId << ") 的五芒图数据 =====";
            
            if (pentagonData.contains("currentMonth")) {
                QVariantMap currentMonthData = pentagonData["currentMonth"].toMap();
                double totalAccuracy = 0;
                int count = 0;
                
                // 遍历五芒图各项能力数据，计算正确率总和
                QStringList types = currentMonthData.keys();
                for (const QString &type : types) {
                    QVariantMap typeData = currentMonthData[type].toMap();
                    if (typeData.contains("accuracy")) {
                        double accuracy = typeData["accuracy"].toDouble();
                        totalAccuracy += accuracy;
                        count++;
                        
                        qDebug() << "  " << type << ": 总题数=" << typeData["totalQuestions"].toInt() 
                                 << ", 正确=" << typeData["correctCount"].toInt()
                                 << ", 正确率=" << (accuracy * 100) << "%";
                    }
                }
                
                if (count > 0) {
                    sortValue = totalAccuracy;
                    qDebug() << "  五芒图正确率总和: " << totalAccuracy << " (平均: " << (totalAccuracy/count*100) << "%)";
                } else {
                    qDebug() << "  没有五芒图数据，默认排序值为0";
                }
            } else {
                qDebug() << "  没有当月数据，默认排序值为0";
            }
        } else {
            // 按本月刷题数排序
            sortValue = getUserCurrentMonthQuestionCount(workId);
            qDebug() << "用户 " << name << " (工号: " << workId << ") 本月刷题数: " << sortValue;
        }
        
        sortedUsers.append(qMakePair(user, sortValue));
    }
    
    // 根据计算的值进行排序（降序）
    std::sort(sortedUsers.begin(), sortedUsers.end(), 
              [](const QPair<QVariantMap, double> &a, const QPair<QVariantMap, double> &b) {
                  return a.second > b.second;
              });
    
    // 转换排序后的结果为QVariantList
    qDebug() << "===== 排序后的用户列表 =====";
    for (const auto &pair : sortedUsers) {
        result.append(pair.first);
        qDebug() << "  " << pair.first["name"].toString() 
                 << " (工号: " << pair.first["workId"].toString() << ")"
                 << " - 排序值: " << pair.second;
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
        
        // 获取图像路径
        QString faceImagePath = query.value("face_image_path").toString();
        QString avatarPath = query.value("avatar_path").toString();
        
        // 转换相对路径为绝对路径并进行URL编码
        if (!faceImagePath.isEmpty() && !faceImagePath.startsWith("file:///")) {
            // 添加应用程序目录前缀
            QString appDir = QCoreApplication::applicationDirPath();
            
            if (faceImagePath.startsWith("/")) {
                faceImagePath = appDir + faceImagePath;
            } else {
                faceImagePath = appDir + "/" + faceImagePath;
            }
            
            // 将路径编码为URL格式以处理中文和特殊字符
            QUrl fileUrl = QUrl::fromLocalFile(faceImagePath);
            faceImagePath = fileUrl.toString();
            qDebug() << "人脸图像路径转换为URL: " << faceImagePath;
        }
        
        if (!avatarPath.isEmpty() && !avatarPath.startsWith("file:///")) {
            // 添加应用程序目录前缀
            QString appDir = QCoreApplication::applicationDirPath();
            
            if (avatarPath.startsWith("/")) {
                avatarPath = appDir + avatarPath;
            } else {
                avatarPath = appDir + "/" + avatarPath;
            }
            
            // 将路径编码为URL格式以处理中文和特殊字符
            QUrl fileUrl = QUrl::fromLocalFile(avatarPath);
            avatarPath = fileUrl.toString();
            qDebug() << "头像路径转换为URL: " << avatarPath;
        }
        
        result["faceImage"] = faceImagePath;
        result["avatarPath"] = avatarPath;
        
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
    
    // 检查用户是否存在，getFaceDataByWorkId已经处理了路径转换
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
    
    // 如果路径是URL格式，转换为本地路径
    if (registeredFaceImage.startsWith("file:///")) {
        QUrl url(registeredFaceImage);
        registeredFaceImage = url.toLocalFile();
        qDebug() << "转换URL为本地路径:" << registeredFaceImage;
    }
    
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

QVariantMap DatabaseManager::recognizeFace(const QString &faceImagePath)
{
    qDebug() << "Recognizing face using image:" << faceImagePath;
    
    QVariantMap result;
    result["recognized"] = false;
    
    // 检查图像文件是否存在
    QFileInfo imageFile(faceImagePath);
    if (!imageFile.exists() || !imageFile.isFile()) {
        qDebug() << "Face image file does not exist or is not a file:" << faceImagePath;
        return result;
    }
    
    // 创建人脸识别器
    static FaceRecognizer faceRecognizer;
    
    // 初始化人脸识别器
    if (!faceRecognizer.initialize()) {
        qDebug() << "Failed to initialize face recognizer.";
        return result;
    }
    
    // 获取相似度阈值
    float threshold = getSetting("face_recognition_threshold", "0.6").toFloat();
    qDebug() << "Face recognition threshold:" << threshold;
    
    // 获取最近识别过的用户 - 优先比较这些用户
    static QStringList recentUsers;
    
    // 最大比较用户数量，避免对所有用户进行比较
    int maxUsersToCompare = 10;
    
    float highestSimilarity = 0.0f;
    QVariantMap bestMatch;
    
    // 先检查人脸位置，确保有人脸再进行比对
    QVariantMap facePosition = faceRecognizer.detectFacePosition(faceImagePath);
    if (!facePosition["faceDetected"].toBool()) {
        qDebug() << "No face detected in the recognition image";
        return result;
    }
    
    // 获取所有用户
    QVariantList allUsers = getAllFaceData();
    if (allUsers.isEmpty()) {
        qDebug() << "No users found in database";
        return result;
    }
    
    // 重新排序用户列表，将最近识别过的用户放在前面
    QVariantList sortedUsers;
    
    // 先添加最近识别过的用户
    for (const QString &recentUserId : recentUsers) {
        for (int i = 0; i < allUsers.size(); ++i) {
            QVariantMap user = allUsers[i].toMap();
            if (user["workId"].toString() == recentUserId) {
                sortedUsers.append(user);
                allUsers.removeAt(i);
                break;
            }
        }
    }
    
    // 然后添加其他用户
    sortedUsers.append(allUsers);
    
    // 限制比较的用户数量
    int usersToCompare = qMin(maxUsersToCompare, sortedUsers.size());
    
    // 遍历用户进行人脸比对
    for (int i = 0; i < usersToCompare; ++i) {
        QVariantMap user = sortedUsers[i].toMap();
        
        // 获取用户注册的人脸图像
        QString registeredFaceImage = user["faceImage"].toString();
        
        // 如果路径是URL格式，转换为本地路径
        if (registeredFaceImage.startsWith("file:///")) {
            QUrl url(registeredFaceImage);
            registeredFaceImage = url.toLocalFile();
        }
        
        // 检查注册的人脸图像是否存在
        QFileInfo registeredImageFile(registeredFaceImage);
        if (!registeredImageFile.exists() || !registeredImageFile.isFile()) {
            qDebug() << "Registered face image file does not exist or is not a file:" << registeredFaceImage;
            continue;
        }
        
        // 比较两张人脸图像
        float similarity = faceRecognizer.compareFaces(registeredFaceImage, faceImagePath);
        qDebug() << "User:" << user["name"].toString() << "Similarity:" << similarity;
        
        // 记录最高相似度的用户
        if (similarity > highestSimilarity) {
            highestSimilarity = similarity;
            bestMatch = user;
            
            // 如果相似度已经很高，直接返回结果
            if (similarity > 0.85) {
                break;
            }
        }
    }
    
    // 判断是否找到匹配的用户
    if (highestSimilarity >= threshold && !bestMatch.isEmpty()) {
        qDebug() << "Face recognized as user:" << bestMatch["name"].toString() 
                 << "with similarity:" << highestSimilarity;
        
        // 更新最近识别的用户列表
        QString recognizedUserId = bestMatch["workId"].toString();
        recentUsers.removeAll(recognizedUserId);
        recentUsers.prepend(recognizedUserId);
        
        // 最多保留5个最近用户
        while (recentUsers.size() > 5) {
            recentUsers.removeLast();
        }
        
        // 记录访问日志
        QSqlQuery logQuery;
        logQuery.prepare(
            "INSERT INTO access_logs (work_id, access_result) "
            "VALUES (:work_id, :access_result)"
        );
        logQuery.bindValue(":work_id", bestMatch["workId"].toString());
        logQuery.bindValue(":access_result", 1);
        logQuery.exec();
        
        // 返回识别结果
        result["recognized"] = true;
        result["name"] = bestMatch["name"];
        result["workId"] = bestMatch["workId"];
        result["similarity"] = highestSimilarity;
    } else {
        qDebug() << "No matching face found. Highest similarity:" << highestSimilarity;
    }
    
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
    
    // 将绝对路径转换为相对路径
    QString appDir = QCoreApplication::applicationDirPath();
    QString relativeFaceImagePath = faceImagePath;
    QString relativeAvatarPath = avatarPath;
    
    // 移除应用程序目录前缀，转换为相对路径
    if (relativeFaceImagePath.startsWith(appDir)) {
        relativeFaceImagePath = relativeFaceImagePath.mid(appDir.length());
        // 确保路径以/开头
        if (!relativeFaceImagePath.startsWith("/")) {
            relativeFaceImagePath = "/" + relativeFaceImagePath;
        }
    }
    
    if (relativeAvatarPath.startsWith(appDir)) {
        relativeAvatarPath = relativeAvatarPath.mid(appDir.length());
        // 确保路径以/开头
        if (!relativeAvatarPath.startsWith("/")) {
            relativeAvatarPath = "/" + relativeAvatarPath;
        }
    }
    
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
    query.bindValue(":face_image_path", relativeFaceImagePath);
    query.bindValue(":avatar_path", relativeAvatarPath);
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
        
        // 首页排序设置 - 默认为"本月个人能力排序"(1)
        setSetting("home_sort_option", "1");
        
        // AI智能体地址设置
        setSetting("ai_agent_address", "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true");
        
        // 五芒图默认标题设置
        setSetting("pentagon_title_1", "基础认知");
        setSetting("pentagon_title_2", "原理理解");
        setSetting("pentagon_title_3", "操作应用");
        setSetting("pentagon_title_4", "诊断分析");
        setSetting("pentagon_title_5", "安全规范");
        
        // 虚拟键盘设置 - 默认启用
        setSetting("enable_virtual_keyboard", "true");
        
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
        qDebug() << "数据库中的头像路径: " << avatarPath;
        
        // 如果是相对路径，转换为绝对路径
        if (!avatarPath.isEmpty() && !avatarPath.startsWith("file:///")) {
            // 添加应用程序目录前缀
            QString appDir = QCoreApplication::applicationDirPath();
            
            // 确保路径连接正确
            if (avatarPath.startsWith("/")) {
                avatarPath = appDir + avatarPath;
            } else {
                avatarPath = appDir + "/" + avatarPath;
            }
            
            // 将路径编码为URL格式以处理中文和特殊字符
            QUrl fileUrl = QUrl::fromLocalFile(avatarPath);
            QString urlString = fileUrl.toString();
            
            qDebug() << "转换为URL路径: " << urlString;
            return urlString;
        }
        
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
            
            // 创建选项与索引的映射
            QList<QPair<int, QString>> optionPairs;
            for (int i = 0; i < options.length() && i < indices.length(); ++i) {
                optionPairs.append(qMakePair(indices[i].toInt(), options[i]));
            }
            
            // 根据选项索引排序
            std::sort(optionPairs.begin(), optionPairs.end(), 
                     [](const QPair<int, QString> &a, const QPair<int, QString> &b) {
                         return a.first < b.first;
                     });
            
            // 创建排序后的选项列表
            QVariantList optionsList;
            for (int i = 0; i < optionPairs.size(); ++i) {
                QVariantMap option;
                option["text"] = optionPairs[i].second;
                option["index"] = i;  // 重新分配连续的索引
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
            qDebug() << "尝试重新初始化数据库...";
            
            // 检查数据库文件是否存在
            QFileInfo dbFileInfo(m_dbPath);
            if (dbFileInfo.exists()) {
                qDebug() << "数据库文件存在，大小:" << dbFileInfo.size() << "字节";
                qDebug() << "权限:" << (dbFileInfo.isReadable() ? "可读 " : "不可读 ") 
                         << (dbFileInfo.isWritable() ? "可写" : "不可写");
            } else {
                qDebug() << "数据库文件不存在，可能需要创建";
            }
            
            // 尝试重新初始化
            if (!initDatabase()) {
                qDebug() << "重新初始化数据库失败，无法保存答题记录";
                return false;
            }
        }
    }
    
    // 在继续前确保表结构是最新的
    updateDatabaseSchema();
    
    QSqlQuery query(m_database);
    
    // 准备SQL语句，使用参数化查询防止SQL注入
    QString sqlStatement = 
        "INSERT INTO user_answer_records "
        "(work_id, user_name, exam_type, total_questions, correct_count, answer_data, score_percentage, question_bank_info, pentagon_type, created_at) "
        "VALUES (:work_id, :user_name, :exam_type, :total_questions, :correct_count, :answer_data, :score_percentage, :question_bank_info, :pentagon_type, CURRENT_TIMESTAMP)";
    
    qDebug() << "执行SQL:" << sqlStatement;
    query.prepare(sqlStatement);
    
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
        QSqlError error = query.lastError();
        qDebug() << "保存用户答题记录失败:" << error.text();
        qDebug() << "错误类型:" << error.type() << " 错误码:" << error.nativeErrorCode();
        qDebug() << "驱动错误:" << error.driverText();
        qDebug() << "数据库错误:" << error.databaseText();
        
        // 尝试检查表结构
        QSqlQuery checkQuery(m_database);
        if (checkQuery.exec("PRAGMA table_info(user_answer_records)")) {
            qDebug() << "user_answer_records表结构:";
            while (checkQuery.next()) {
                qDebug() << "  " << checkQuery.value(1).toString() << " " << checkQuery.value(2).toString();
            }
        }
        
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
    
    // 查询当月完成的题目总数
    query.prepare("SELECT SUM(total_questions) "
                 "FROM user_answer_records "
                 "WHERE work_id = :workId "
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
    
    // 查询本年度每月的题目总数
    query.prepare("SELECT strftime('%m', created_at) as month, "
                 "SUM(total_questions) as questionCount "
                 "FROM user_answer_records "
                 "WHERE work_id = :workId "
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
    
    // 查询过去12个月的题目总数，使用精确的年月格式
    query.prepare("SELECT strftime('%Y-%m', created_at) as yearMonth, "
                 "SUM(total_questions) as questionCount "
                 "FROM user_answer_records "
                 "WHERE work_id = :workId "
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
    
    // 查询当月每个用户的题目总数，并获取最大值
    query.prepare("SELECT work_id, SUM(total_questions) as total "
                 "FROM user_answer_records "
                 "WHERE date(created_at) >= date(:startDate) "
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
    
    // 检查user_answer_records表中的列
    query.prepare("PRAGMA table_info(user_answer_records)");
    if (!query.exec()) {
        qDebug() << "检查表结构失败:" << query.lastError().text();
        return false;
    }
    
    bool hasQuestionBankInfo = false;
    bool hasPentagonType = false;
    bool hasScorePercentage = false;
    bool hasSubmissionTime = false;
    bool hasCreatedAt = false;
    
    while (query.next()) {
        QString columnName = query.value(1).toString();
        if (columnName == "question_bank_info") {
            hasQuestionBankInfo = true;
        } else if (columnName == "pentagon_type") {
            hasPentagonType = true;
        } else if (columnName == "score_percentage") {
            hasScorePercentage = true;
        } else if (columnName == "submission_time") {
            hasSubmissionTime = true;
        } else if (columnName == "created_at") {
            hasCreatedAt = true;
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
            // 继续执行，尝试添加下一列
        }
    }
    
    // 添加score_percentage列（如果不存在）
    if (!hasScorePercentage) {
        qDebug() << "添加score_percentage列到user_answer_records表";
        if (!query.exec("ALTER TABLE user_answer_records ADD COLUMN score_percentage REAL DEFAULT 0")) {
            qDebug() << "添加score_percentage列失败:" << query.lastError().text();
            // 继续执行，尝试添加下一列
        }
    }
    
    // 处理字段名不一致的情况：submission_time 和 created_at
    if (hasSubmissionTime && !hasCreatedAt) {
        qDebug() << "添加created_at列到user_answer_records表并从submission_time复制数据";
        
        // 首先添加created_at列
        if (!query.exec("ALTER TABLE user_answer_records ADD COLUMN created_at TIMESTAMP")) {
            qDebug() << "添加created_at列失败:" << query.lastError().text();
            // 继续执行
        } else {
            // 将submission_time的数据复制到created_at
            if (!query.exec("UPDATE user_answer_records SET created_at = submission_time")) {
                qDebug() << "从submission_time复制数据到created_at失败:" << query.lastError().text();
                // 继续执行
            }
        }
    } else if (!hasSubmissionTime && !hasCreatedAt) {
        // 如果两个字段都不存在，添加created_at
        qDebug() << "添加created_at列到user_answer_records表";
        if (!query.exec("ALTER TABLE user_answer_records ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP")) {
            qDebug() << "添加created_at列失败:" << query.lastError().text();
            // 继续执行
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

// 保存用户题库进度
bool DatabaseManager::saveUserBankProgress(const QString &workId, int bankId, 
                                         int currentQuestionIndex, 
                                         const QString &userAnswersJson)
{
    if (!m_database.isOpen()) {
        qDebug() << "保存用户题库进度失败: 数据库未打开";
        return false;
    }
    
    if (workId.isEmpty()) {
        qDebug() << "保存用户题库进度失败: 用户ID为空";
        return false;
    }
    
    QSqlQuery query(m_database);
    
    // 使用 INSERT OR REPLACE 语法进行 UPSERT 操作
    query.prepare(
        "INSERT OR REPLACE INTO user_bank_progress "
        "(work_id, bank_id, current_question_index, user_answers, last_updated) "
        "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)"
    );
    
    query.bindValue(0, workId);
    query.bindValue(1, bankId);
    query.bindValue(2, currentQuestionIndex);
    query.bindValue(3, userAnswersJson);
    
    bool success = query.exec();
    
    if (!success) {
        qDebug() << "保存用户题库进度失败:" << query.lastError().text();
    } else {
        qDebug() << "成功保存用户" << workId << "题库" << bankId << "的进度";
    }
    
    return success;
}

// 获取用户题库进度
QVariantMap DatabaseManager::getUserBankProgress(const QString &workId, int bankId)
{
    QVariantMap result;
    
    if (!m_database.isOpen()) {
        qDebug() << "获取用户题库进度失败: 数据库未打开";
        return result;
    }
    
    QSqlQuery query(m_database);
    
    query.prepare(
        "SELECT current_question_index, user_answers "
        "FROM user_bank_progress "
        "WHERE work_id = ? AND bank_id = ?"
    );
    
    query.bindValue(0, workId);
    query.bindValue(1, bankId);
    
    bool success = query.exec();
    
    if (!success) {
        qDebug() << "查询用户题库进度失败:" << query.lastError().text();
        return result;
    }
    
    if (query.next()) {
        result["currentQuestionIndex"] = query.value(0).toInt();
        result["userAnswers"] = query.value(1).toString();
        result["hasProgress"] = true;
    } else {
        // 没有找到进度记录
        result["hasProgress"] = false;
    }
    
    return result;
}

// 更新用户错题集
bool DatabaseManager::updateUserWrongQuestions(const QString &workId, int bankId, 
                                             const QVariantList &wrongQuestionIds)
{
    if (!m_database.isOpen()) {
        qDebug() << "更新用户错题集失败: 数据库未打开";
        return false;
    }
    
    if (workId.isEmpty()) {
        qDebug() << "更新用户错题集失败: 用户ID为空";
        return false;
    }
    
    // 开始事务
    m_database.transaction();
    
    QSqlQuery query(m_database);
    
    // 先删除该用户在该题库的所有错题记录
    query.prepare(
        "DELETE FROM user_wrong_questions "
        "WHERE work_id = ? AND bank_id = ?"
    );
    
    query.bindValue(0, workId);
    query.bindValue(1, bankId);
    
    bool success = query.exec();
    
    if (!success) {
        qDebug() << "删除旧错题记录失败:" << query.lastError().text();
        m_database.rollback();
        return false;
    }
    
    // 如果有新的错题记录，则插入
    if (!wrongQuestionIds.isEmpty()) {
        // 插入新的错题记录
        query.prepare(
            "INSERT INTO user_wrong_questions "
            "(work_id, bank_id, question_id) "
            "VALUES (?, ?, ?)"
        );
        
        for (const QVariant &questionIdVar : wrongQuestionIds) {
            int questionId = questionIdVar.toInt();
            
            query.bindValue(0, workId);
            query.bindValue(1, bankId);
            query.bindValue(2, questionId);
            
            success = query.exec();
            
            if (!success) {
                qDebug() << "插入错题记录失败:" << query.lastError().text();
                m_database.rollback();
                return false;
            }
        }
        
        qDebug() << "成功更新用户" << workId << "题库" << bankId << "的错题集，共" << wrongQuestionIds.size() << "道题";
    } else {
        // 如果没有错题记录，表示清空错题集
        qDebug() << "成功清空用户" << workId << "题库" << bankId << "的错题集";
    }
    
    // 提交事务
    if (!m_database.commit()) {
        qDebug() << "提交事务失败:" << m_database.lastError().text();
        m_database.rollback();
        return false;
    }
    
    return true;
}

// 获取用户错题ID列表
QVariantList DatabaseManager::getUserWrongQuestionIds(const QString &workId, int bankId)
{
    QVariantList result;
    
    if (!m_database.isOpen()) {
        qDebug() << "获取用户错题集失败: 数据库未打开";
        return result;
    }
    
    QSqlQuery query(m_database);
    
    query.prepare(
        "SELECT question_id "
        "FROM user_wrong_questions "
        "WHERE work_id = ? AND bank_id = ?"
    );
    
    query.bindValue(0, workId);
    query.bindValue(1, bankId);
    
    bool success = query.exec();
    
    if (!success) {
        qDebug() << "查询用户错题集失败:" << query.lastError().text();
        return result;
    }
    
    while (query.next()) {
        result.append(query.value(0).toInt());
    }
    
    return result;
}

// 删除用户题库进度
bool DatabaseManager::deleteUserBankProgress(const QString &workId, int bankId)
{
    if (!m_database.isOpen()) {
        qDebug() << "删除用户题库进度失败: 数据库未打开";
        return false;
    }
    
    QSqlQuery query(m_database);
    
    query.prepare(
        "DELETE FROM user_bank_progress "
        "WHERE work_id = ? AND bank_id = ?"
    );
    
    query.bindValue(0, workId);
    query.bindValue(1, bankId);
    
    bool success = query.exec();
    
    if (!success) {
        qDebug() << "删除用户题库进度失败:" << query.lastError().text();
    } else {
        qDebug() << "成功删除用户" << workId << "题库" << bankId << "的进度";
    }
    
    return success;
}

// 添加新账户
bool DatabaseManager::addAccount(const QString &username, const QString &workId, const QString &password)
{
    QSqlQuery query(m_database);
    
    // 检查工号是否已存在
    query.prepare("SELECT work_id FROM accounts WHERE work_id = ?");
    query.addBindValue(workId);
    
    if (!query.exec()) {
        qDebug() << "Failed to check existing work_id:" << query.lastError().text();
        return false;
    }
    
    if (query.next()) {
        qDebug() << "Work ID already exists";
        return false;
    }
    
    // 插入新账户
    query.prepare("INSERT INTO accounts (username, work_id, password) VALUES (?, ?, ?)");
    query.addBindValue(username);
    query.addBindValue(workId);
    query.addBindValue(password);
    
    if (!query.exec()) {
        qDebug() << "Failed to add account:" << query.lastError().text();
        return false;
    }
    
    return true;
}

// 获取所有账户
QVariantList DatabaseManager::getAllAccounts()
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
        "SELECT id, username, work_id, created_at, last_login, is_active "
        "FROM accounts "
        "ORDER BY created_at DESC"
    );
    
    if (!query.exec()) {
        qDebug() << "获取账户列表失败:" << query.lastError().text();
        return result;
    }
    
    while (query.next()) {
        QVariantMap account;
        account["id"] = query.value("id").toInt();
        account["username"] = query.value("username").toString();
        account["workId"] = query.value("work_id").toString();
        account["createdAt"] = query.value("created_at").toString();
        account["lastLogin"] = query.value("last_login").toString();
        account["isActive"] = query.value("is_active").toBool();
        
        result.append(account);
    }
    
    return result;
}

// 删除账户
bool DatabaseManager::deleteAccount(const QString &workId)
{
    if (!m_database.isOpen()) {
        qDebug() << "数据库未打开，尝试重新打开";
        if (!m_database.open()) {
            qDebug() << "无法打开数据库:" << m_database.lastError().text();
            return false;
        }
    }
    
    QSqlQuery query(m_database);
    query.prepare("DELETE FROM accounts WHERE work_id = ?");
    query.addBindValue(workId);
    
    if (!query.exec()) {
        qDebug() << "删除账户失败:" << query.lastError().text();
        return false;
    }
    
    return true;
}