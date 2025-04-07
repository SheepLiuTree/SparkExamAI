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
#include <QVariantList>

/**
 * @brief 数据库管理类
 * 
 * 管理SparkExam应用的SQLite数据库，包括用户数据、访问日志和应用设置。
 */
class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    // 初始化数据库连接
    Q_INVOKABLE bool initDatabase();

    // 用户管理相关方法
    
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
                                   
    // 设置相关方法
    
    // 设置值
    Q_INVOKABLE bool setSetting(const QString &key, const QString &value);
    
    // 获取设置值
    Q_INVOKABLE QString getSetting(const QString &key, const QString &defaultValue = "");
    
    // 删除设置
    Q_INVOKABLE bool deleteSetting(const QString &key);
    
    // 获取所有设置
    Q_INVOKABLE QVariantMap getAllSettings();

    // 访问日志相关方法
    
    // 获取访问日志
    Q_INVOKABLE QVariantList getAccessLogs(int limit = 100, int offset = 0);
    
    // 获取特定用户的访问日志
    Q_INVOKABLE QVariantList getAccessLogsByUser(const QString &workId, int limit = 100, int offset = 0);
    
    // 清除旧的访问日志（保留最近N天）
    Q_INVOKABLE bool cleanupOldLogs(int daysToKeep = 30);

    Q_INVOKABLE QString getUserAvatarPath(const QString &workId);
    
    // 题库管理相关方法
    
    // 添加题库
    Q_INVOKABLE bool addQuestionBank(const QString &name, int questionCount);
    
    // 删除题库
    Q_INVOKABLE bool deleteQuestionBank(int bankId);
    
    // 获取所有题库
    Q_INVOKABLE QVariantList getAllQuestionBanks();
    
    // 根据ID获取题库
    Q_INVOKABLE QVariantMap getQuestionBankById(int bankId);
    
    // 更新题库信息
    Q_INVOKABLE bool updateQuestionBank(int bankId, const QString &name);
    
    // 添加题目到题库
    Q_INVOKABLE bool addQuestion(int bankId, 
                                const QString &content, 
                                const QString &answer, 
                                const QString &analysis,
                                const QStringList &options = QStringList());
    
    // 删除题目
    Q_INVOKABLE bool deleteQuestion(int questionId);
    
    // 更新题目
    Q_INVOKABLE bool updateQuestion(int questionId,
                                   const QString &content, 
                                   const QString &answer, 
                                   const QString &analysis,
                                   const QStringList &options = QStringList());
    
    // 获取题库中的所有题目
    Q_INVOKABLE QVariantList getQuestionsByBankId(int bankId);
    
    // 获取题目详情
    Q_INVOKABLE QVariantMap getQuestionById(int questionId);
    
    // 批量导入题目
    Q_INVOKABLE bool importQuestions(int bankId, const QVariantList &questions);

private:
    QSqlDatabase m_database;
    QString m_dbPath;

    // 创建表结构
    bool createTables();
    
    // 初始化默认设置
    void initDefaultSettings();
};

#endif // DATABASEMANAGER_H 