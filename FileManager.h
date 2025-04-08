#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QList>

class FileManager : public QObject
{
    Q_OBJECT

public:
    explicit FileManager(QObject *parent = nullptr);
    
    // 复制文件
    Q_INVOKABLE bool copyFile(const QString &sourcePath, const QString &destinationPath);
    
    // 移动文件
    Q_INVOKABLE bool moveFile(const QString &sourcePath, const QString &destinationPath);
    
    // 获取应用程序目录
    Q_INVOKABLE QString getApplicationDir();
    
    // 创建目录
    Q_INVOKABLE bool createDirectory(const QString &dirPath);
    
    // 检查目录是否存在
    Q_INVOKABLE bool directoryExists(const QString &dirPath);
    
    // 打开文件夹选择对话框
    Q_INVOKABLE QString getFolderPath(const QString &title = "选择文件夹");
    
    // 读取Excel文件内容
    Q_INVOKABLE QVariantList readExcelFile(const QString &filePath);
    
    // 获取Excel文件中的表头
    Q_INVOKABLE QStringList getExcelHeaders(const QString &filePath);
    
    // 检查Excel文件结构是否符合题库导入格式
    Q_INVOKABLE bool validateExcelStructure(const QString &filePath);
    
    // 检查Excel文件结构是否符合智点导入格式
    Q_INVOKABLE bool validateKnowledgePointExcelStructure(const QString &filePath);
    
    // 打开文件选择对话框
    Q_INVOKABLE QString getOpenFilePath(const QString &title = "选择文件", const QString &filter = "所有文件 (*.*)");

private:
  
};

#endif // FILEMANAGER_H 
