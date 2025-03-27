#include "FileManager.h"
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QImage>
#include <QStandardPaths>
#include <QCoreApplication>
FileManager::FileManager(QObject *parent) : QObject(parent) {}

bool FileManager::copyFile(const QString &sourcePath, const QString &destinationPath)
{
    QFile sourceFile(sourcePath);
    if (!sourceFile.exists())
    {
        qDebug() << "源文件不存在:" << sourcePath;
        return false;
    }

    // 确保目标目录存在
    QDir dir;
    dir.mkpath(QFileInfo(destinationPath).path());

    // 如果目标文件已存在，先删除
    QFile destFile(destinationPath);
    if (destFile.exists())
    {
        destFile.remove();
    }

    // 复制文件
    return sourceFile.copy(destinationPath);
}

bool FileManager::moveFile(const QString &sourcePath, const QString &destinationPath)
{
    QFile sourceFile(sourcePath);
    if (!sourceFile.exists())
    {
        qDebug() << "源文件不存在:" << sourcePath;
        return false;
    }

    // 确保目标目录存在
    QDir dir;
    dir.mkpath(QFileInfo(destinationPath).path());

    // 如果目标文件已存在，先删除
    QFile destFile(destinationPath);
    if (destFile.exists())
    {
        destFile.remove();
    }

    // 移动文件
    return sourceFile.rename(destinationPath);
}

QString FileManager::getApplicationDir()
{
    return QCoreApplication::applicationDirPath();
}

bool FileManager::createDirectory(const QString &dirPath)
{
    QDir dir;
    if (!dir.exists(dirPath)) {
        return dir.mkpath(dirPath);
    }
    return true; // Directory already exists
}

bool FileManager::directoryExists(const QString &dirPath)
{
    QDir dir(dirPath);
    return dir.exists();
}