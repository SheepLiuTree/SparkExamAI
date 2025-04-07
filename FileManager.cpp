#include "FileManager.h"
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QImage>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QFileDialog>
#include "QXlsx/header/xlsxdocument.h"
#include "QXlsx/header/xlsxworksheet.h"
#include "QXlsx/header/xlsxcellrange.h"

using namespace QXlsx;

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

QString FileManager::getFolderPath(const QString &title)
{
    QString dir = QFileDialog::getExistingDirectory(
        nullptr, 
        title,
        QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation),
        QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks
    );
    
    if (dir.isEmpty()) {
        qDebug() << "用户取消了文件夹选择";
        return "";
    }
    
    return dir;
}

QVariantList FileManager::readExcelFile(const QString &filePath)
{
    QVariantList result;
    
    // 检查文件是否存在
    if (!QFile::exists(filePath)) {
        qDebug() << "Excel文件不存在:" << filePath;
        return result;
    }
    
    // 创建Document对象并加载Excel文件
    Document xlsx(filePath);
    if (!xlsx.isLoadPackage()) {
        qDebug() << "无法打开Excel文件:" << filePath;
        return result;
    }
    
    // 使用当前工作表
    Worksheet *worksheet = xlsx.currentWorksheet();
    if (!worksheet) {
        qDebug() << "无法获取工作表";
        return result;
    }
    
    // 获取数据范围
    CellRange range = worksheet->dimension();
    int rowCount = range.rowCount();
    int colCount = range.columnCount();
    
    // 读取表头，以确定字段位置
    QStringList headers;
    QMap<QString, int> headerIndices;
    for (int col = 1; col <= colCount; ++col) {
        Cell *cell = worksheet->cellAt(1, col);
        QString header = cell ? cell->value().toString() : QString("Column%1").arg(col);
        headers.append(header);
        headerIndices.insert(header, col);
    }
    
    // 定义必要的字段
    QStringList requiredFields = {"题干", "答案", "解析"};
    
    // 检查是否包含所有必要字段
    for (const QString &field : requiredFields) {
        bool found = false;
        for (const QString &header : headers) {
            if (header.contains(field, Qt::CaseInsensitive)) {
                found = true;
                break;
            }
        }
        
        if (!found) {
            qDebug() << "Excel文件缺少必要字段:" << field;
            return result;
        }
    }
    
    // 从第二行开始读取数据（跳过表头）
    for (int row = 2; row <= rowCount; ++row) {
        QVariantMap rowData;
        bool hasData = false;
        
        // 读取每一列
        for (int col = 1; col <= colCount; ++col) {
            Cell *cell = worksheet->cellAt(row, col);
            QVariant value;
            
            if (cell) {
                value = cell->value();
                if (!value.isNull() && value.toString().trimmed() != "") {
                    hasData = true;
                }
            }
            
            // 获取对应的列头
            QString headerText = (col <= headers.size()) ? headers[col-1] : QString("Column%1").arg(col);
            
            rowData.insert(headerText, value);
        }
        
        // 只添加非空行
        if (hasData) {
            result.append(rowData);
        }
    }
    
    return result;
}

QStringList FileManager::getExcelHeaders(const QString &filePath)
{
    QStringList headers;
    
    // 检查文件是否存在
    if (!QFile::exists(filePath)) {
        qDebug() << "Excel文件不存在:" << filePath;
        return headers;
    }
    
    // 创建Document对象并加载Excel文件
    Document xlsx(filePath);
    if (!xlsx.isLoadPackage()) {
        qDebug() << "无法打开Excel文件:" << filePath;
        return headers;
    }
    
    // 使用当前工作表
    Worksheet *worksheet = xlsx.currentWorksheet();
    if (!worksheet) {
        qDebug() << "无法获取工作表";
        return headers;
    }
    
    // 获取数据范围
    CellRange range = worksheet->dimension();
    int colCount = range.columnCount();
    
    // 获取第一行作为表头
    for (int col = 1; col <= colCount; ++col) {
        Cell *cell = worksheet->cellAt(1, col);
        QString header = cell ? cell->value().toString() : QString("Column%1").arg(col);
        headers.append(header);
    }
    
    return headers;
}

bool FileManager::validateExcelStructure(const QString &filePath)
{
    // 获取表头
    QStringList headers = getExcelHeaders(filePath);
    
    // 题库导入需要的必要字段列表
    QStringList requiredHeaders = {"题干", "答案", "解析"};
    // 可选的选项字段
    QStringList optionHeaders = {"选项A", "选项B", "选项C", "选项D", "选项E", "选项F", "选项G"};
    
    // 检查是否包含必要字段
    for (const QString &required : requiredHeaders) {
        bool found = false;
        for (const QString &header : headers) {
            if (header.contains(required, Qt::CaseInsensitive)) {
                found = true;
                break;
            }
        }
        
        if (!found) {
            qDebug() << "Excel文件缺少必要字段:" << required;
            return false;
        }
    }
    
    // 检查选项字段顺序是否正确
    int lastOptionIndex = -1;
    for (int i = 0; i < optionHeaders.size(); i++) {
        int currentIndex = -1;
        for (int j = 0; j < headers.size(); j++) {
            if (headers[j].contains(optionHeaders[i], Qt::CaseInsensitive)) {
                currentIndex = j;
                break;
            }
        }
        
        // 如果找到了这个选项
        if (currentIndex != -1) {
            // 如果之前没找到过选项，或者当前选项在之前选项之后
            if (lastOptionIndex == -1 || currentIndex > lastOptionIndex) {
                lastOptionIndex = currentIndex;
            } else {
                qDebug() << "Excel文件选项顺序不正确:" << optionHeaders[i];
                return false;
            }
        }
    }
    
    return true;
}