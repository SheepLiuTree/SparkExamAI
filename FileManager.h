#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QString>

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
    Q_INVOKABLE QString getApplicationDir() ;

private:
  
};

#endif // FILEMANAGER_H 
