#include "FaceRecognizer.h"
#include <opencv2/imgproc.hpp>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QApplication>
#include <QUrl>
#include <QTimer>
#include <QCoreApplication>

FaceRecognizer::FaceRecognizer(QObject *parent) : QObject(parent),
    m_faceDetector(nullptr),
    m_faceLandmarker(nullptr),
    m_faceRecognizer(nullptr),
    m_initialized(false),
    m_rotationAngle(0.0f),
    m_rotationSpeed(2.0f),
    m_rotationTimer(nullptr)
{
    // 设置模型路径为当前应用程序目录下的model文件夹
    m_modelPath = QApplication::applicationDirPath() + "/model";
    qDebug() << "SeetaFace2 model path:" << m_modelPath;
    
    // 初始化旋转定时器
    m_rotationTimer = new QTimer(this);
    connect(m_rotationTimer, &QTimer::timeout, this, &FaceRecognizer::updateRotation);
}

FaceRecognizer::~FaceRecognizer()
{
    // 释放资源
    if (m_faceDetector) {
        delete m_faceDetector;
        m_faceDetector = nullptr;
    }
    
    if (m_faceLandmarker) {
        delete m_faceLandmarker;
        m_faceLandmarker = nullptr;
    }
    
    if (m_faceRecognizer) {
        delete m_faceRecognizer;
        m_faceRecognizer = nullptr;
    }
    
    // 停止并清理定时器
    if (m_rotationTimer) {
        m_rotationTimer->stop();
    }
}

bool FaceRecognizer::initialize()
{
    if (m_initialized) {
        return true; // 已经初始化过了
    }

    try {
        qDebug() << "\n\n========== 人脸识别初始化 ==========";
        qDebug() << "应用程序目录:" << QApplication::applicationDirPath();
        qDebug() << "当前工作目录:" << QDir::currentPath();
        qDebug() << "当前设置的模型路径:" << m_modelPath;
        
        // 显式列出所有可能的模型路径
        QStringList possiblePaths;
        possiblePaths << m_modelPath; // 默认路径 (applicationDirPath + "/model")
        possiblePaths << QApplication::applicationDirPath(); // 应用程序根目录
        possiblePaths << QDir::currentPath(); // 当前工作目录
        possiblePaths << QDir::currentPath() + "/model"; // 当前工作目录的model子目录
        possiblePaths << QApplication::applicationDirPath() + "/../model"; // 上一级目录
        possiblePaths << QApplication::applicationDirPath() + "/../../model"; // 上两级目录
        possiblePaths << QApplication::applicationDirPath() + "/../../../model"; // 上三级目录
        possiblePaths << "model"; // 相对路径model
        possiblePaths << "../model"; // 相对上级目录
        possiblePaths << QCoreApplication::applicationDirPath() + "/data/model"; // data子目录
        possiblePaths << QCoreApplication::applicationDirPath() + "/assets/model"; // assets子目录
        possiblePaths << "E:/SparkExamAI/SparkExamAI/SparkExamAI/model"; // 固定开发路径
        possiblePaths << "C:/Program Files/SparkExamAI/model"; // 可能的安装路径
        possiblePaths << "C:/Program Files (x86)/SparkExamAI/model"; // 可能的安装路径
        
        // 检查每个可能的路径
        qDebug() << "检查所有可能的模型路径:";
        QString modelPathFound;
        
        for (const QString &path : possiblePaths) {
            QDir dir(path);
            if (dir.exists()) {
                // 检查是否有模型文件
                QFileInfo detectorFile(path + "/fd_2_00.dat");
                QFileInfo landmarkerFile(path + "/pd_2_00_pts5.dat");
                QFileInfo recognizerFile(path + "/fr_2_10.dat");
                
                bool hasDetector = detectorFile.exists();
                bool hasLandmarker = landmarkerFile.exists();
                bool hasRecognizer = recognizerFile.exists();
                
                qDebug() << "路径:" << path 
                         << "\n  - 目录存在:" << dir.exists()
                         << "\n  - 检测器模型:" << (hasDetector ? "存在" : "不存在")
                         << "\n  - 特征点模型:" << (hasLandmarker ? "存在" : "不存在")
                         << "\n  - 识别模型:" << (hasRecognizer ? "存在" : "不存在");
                
                if (hasDetector && hasLandmarker && hasRecognizer) {
                    modelPathFound = path;
                    qDebug() << "找到完整的模型文件目录:" << modelPathFound;
                    break;
                }
            } else {
                qDebug() << "路径不存在:" << path;
            }
        }
        
        // 如果找到有效的模型路径，使用它
        if (!modelPathFound.isEmpty()) {
            m_modelPath = modelPathFound;
            qDebug() << "将使用模型路径:" << m_modelPath;
        } else {
            // 如果找不到预定义路径中的模型，尝试搜索整个应用程序目录树
            qDebug() << "在预定义路径中未找到模型文件，尝试搜索整个应用程序目录...";
            QDir appDir(QApplication::applicationDirPath());
            QStringList modelFiles = findModelFiles(appDir);
            
            if (!modelFiles.isEmpty()) {
                // 找到模型文件，获取其路径
                QString detectorFilePath;
                QString landmarkerFilePath;
                QString recognizerFilePath;
                
                for (const QString &file : modelFiles) {
                    if (file.endsWith("fd_2_00.dat")) detectorFilePath = file;
                    else if (file.endsWith("pd_2_00_pts5.dat")) landmarkerFilePath = file;
                    else if (file.endsWith("fr_2_10.dat")) recognizerFilePath = file;
                }
                
                if (!detectorFilePath.isEmpty() && !landmarkerFilePath.isEmpty() && !recognizerFilePath.isEmpty()) {
                    // 确保所有模型文件都在同一目录
                    QFileInfo detectorInfo(detectorFilePath);
                    QFileInfo landmarkerInfo(landmarkerFilePath);
                    QFileInfo recognizerInfo(recognizerFilePath);
                    
                    if (detectorInfo.absolutePath() == landmarkerInfo.absolutePath() && 
                        landmarkerInfo.absolutePath() == recognizerInfo.absolutePath()) {
                        m_modelPath = detectorInfo.absolutePath();
                        qDebug() << "通过搜索找到模型目录:" << m_modelPath;
                    } else {
                        qDebug() << "模型文件存在但不在同一目录中:";
                        qDebug() << " - 检测器:" << detectorFilePath;
                        qDebug() << " - 特征点:" << landmarkerFilePath;
                        qDebug() << " - 识别器:" << recognizerFilePath;
                        
                        // 使用检测器的目录作为模型路径
                        m_modelPath = detectorInfo.absolutePath();
                        qDebug() << "将使用检测器所在目录:" << m_modelPath;
                    }
                } else {
                    qDebug() << "搜索中找到的模型文件不完整:";
                    qDebug() << " - 检测器:" << (detectorFilePath.isEmpty() ? "未找到" : detectorFilePath);
                    qDebug() << " - 特征点:" << (landmarkerFilePath.isEmpty() ? "未找到" : landmarkerFilePath);
                    qDebug() << " - 识别器:" << (recognizerFilePath.isEmpty() ? "未找到" : recognizerFilePath);
                    
                    // 尝试紧急初始化
                    qDebug() << "尝试紧急初始化...";
                    return emergency_initialize();
                }
            } else {
                qDebug() << "在应用程序目录中未找到任何模型文件";
                // 尝试紧急初始化
                qDebug() << "尝试紧急初始化...";
                return emergency_initialize();
            }
        }
        
        // 到这里，我们应该已经设置了正确的m_modelPath
        qDebug() << "最终使用的模型路径:" << m_modelPath;
        
        // 再次检查模型文件是否存在
        QFileInfo detectorFile(m_modelPath + "/fd_2_00.dat");
        QFileInfo landmarkerFile(m_modelPath + "/pd_2_00_pts5.dat");
        QFileInfo recognizerFile(m_modelPath + "/fr_2_10.dat");
        
        qDebug() << "模型文件最终检查:";
        qDebug() << " - 检测器 (" << detectorFile.absoluteFilePath() << "): " << (detectorFile.exists() ? "存在" : "不存在");
        qDebug() << " - 特征点 (" << landmarkerFile.absoluteFilePath() << "): " << (landmarkerFile.exists() ? "存在" : "不存在");
        qDebug() << " - 识别器 (" << recognizerFile.absoluteFilePath() << "): " << (recognizerFile.exists() ? "存在" : "不存在");
        
        if (!detectorFile.exists() || !landmarkerFile.exists() || !recognizerFile.exists()) {
            qDebug() << "最终路径中缺少必需的模型文件";
            // 尝试紧急初始化
            qDebug() << "尝试紧急初始化...";
            return emergency_initialize();
        }
        
        // 配置人脸检测器
        seeta::ModelSetting::Device device = seeta::ModelSetting::CPU;
        int id = 0;
        
        qDebug() << "创建人脸检测器...";
        QString detectorPath = m_modelPath + "/fd_2_00.dat";
        qDebug() << "检测器路径:" << detectorPath << "存在:" << QFileInfo(detectorPath).exists();
        
        try {
            seeta::ModelSetting FD_model(detectorPath.toStdString(), device, id);
            m_faceDetector = new seeta::FaceDetector(FD_model);
            // 使用正确的方法设置参数
            m_faceDetector->set(seeta::FaceDetector::PROPERTY_MIN_FACE_SIZE, 80);
            qDebug() << "人脸检测器创建成功";
        } catch (const std::exception &e) {
            qDebug() << "创建人脸检测器失败:" << e.what();
            // 尝试紧急初始化
            qDebug() << "尝试紧急初始化...";
            return emergency_initialize();
        }
        
        // 配置人脸特征点定位器
        qDebug() << "创建人脸特征点定位器...";
        QString landmarkerPath = m_modelPath + "/pd_2_00_pts5.dat";
        qDebug() << "特征点定位器路径:" << landmarkerPath << "存在:" << QFileInfo(landmarkerPath).exists();
        
        try {
            seeta::ModelSetting PD_model(landmarkerPath.toStdString(), device, id);
            m_faceLandmarker = new seeta::FaceLandmarker(PD_model);
            qDebug() << "人脸特征点定位器创建成功";
        } catch (const std::exception &e) {
            qDebug() << "创建人脸特征点定位器失败:" << e.what();
            // 清理资源
            if (m_faceDetector) {
                delete m_faceDetector;
                m_faceDetector = nullptr;
            }
            // 尝试紧急初始化
            qDebug() << "尝试紧急初始化...";
            return emergency_initialize();
        }
        
        // 配置人脸特征提取器
        qDebug() << "创建人脸特征提取器...";
        QString recognizerPath = m_modelPath + "/fr_2_10.dat";
        qDebug() << "特征提取器路径:" << recognizerPath << "存在:" << QFileInfo(recognizerPath).exists();
        
        try {
            seeta::ModelSetting FR_model(recognizerPath.toStdString(), device, id);
            m_faceRecognizer = new seeta::FaceRecognizer(FR_model);
            qDebug() << "人脸特征提取器创建成功";
        } catch (const std::exception &e) {
            qDebug() << "创建人脸特征提取器失败:" << e.what();
            // 清理资源
            if (m_faceDetector) {
                delete m_faceDetector;
                m_faceDetector = nullptr;
            }
            if (m_faceLandmarker) {
                delete m_faceLandmarker;
                m_faceLandmarker = nullptr;
            }
            // 尝试紧急初始化
            qDebug() << "尝试紧急初始化...";
            return emergency_initialize();
        }
        
        m_initialized = true;
        qDebug() << "人脸识别模型初始化成功";
        qDebug() << "========== 人脸识别初始化完成 ==========\n";
        return true;
    }
    catch (const std::exception &e) {
        qDebug() << "初始化人脸识别模型时发生错误: " << e.what();
        qDebug() << "尝试紧急初始化...";
        return emergency_initialize();
    }
}

// 紧急初始化方法 - 使用硬编码的路径尝试加载模型文件
bool FaceRecognizer::emergency_initialize() {
    qDebug() << "\n===== 紧急初始化 - 使用硬编码路径 =====";
    
    // 清理任何可能已经分配的资源
    if (m_faceDetector) {
        delete m_faceDetector;
        m_faceDetector = nullptr;
    }
    
    if (m_faceLandmarker) {
        delete m_faceLandmarker;
        m_faceLandmarker = nullptr;
    }
    
    if (m_faceRecognizer) {
        delete m_faceRecognizer;
        m_faceRecognizer = nullptr;
    }
    
    try {
        // 设备类型和ID
        seeta::ModelSetting::Device device = seeta::ModelSetting::CPU;
        int id = 0;
        
        // 尝试一系列硬编码的绝对路径
        const QString appDir = QApplication::applicationDirPath();
        
        // 使用应用程序目录下的model目录
        QString detectorPath = appDir + "/model/fd_2_00.dat";
        QString landmarkerPath = appDir + "/model/pd_2_00_pts5.dat";
        QString recognizerPath = appDir + "/model/fr_2_10.dat";
        
        // 检查路径是否存在
        bool detectorExists = QFileInfo(detectorPath).exists();
        bool landmarkerExists = QFileInfo(landmarkerPath).exists();
        bool recognizerExists = QFileInfo(recognizerPath).exists();
        
        qDebug() << "检查应用程序目录下的model文件夹:";
        qDebug() << " - 检测器:" << detectorPath << (detectorExists ? "存在" : "不存在");
        qDebug() << " - 特征点:" << landmarkerPath << (landmarkerExists ? "存在" : "不存在");
        qDebug() << " - 识别器:" << recognizerPath << (recognizerExists ? "存在" : "不存在");
        
        // 如果应用程序目录的model子目录中找不到文件，尝试根目录
        if (!detectorExists || !landmarkerExists || !recognizerExists) {
            qDebug() << "尝试从应用程序根目录加载...";
            detectorPath = appDir + "/fd_2_00.dat";
            landmarkerPath = appDir + "/pd_2_00_pts5.dat";
            recognizerPath = appDir + "/fr_2_10.dat";
            
            detectorExists = QFileInfo(detectorPath).exists();
            landmarkerExists = QFileInfo(landmarkerPath).exists();
            recognizerExists = QFileInfo(recognizerPath).exists();
            
            qDebug() << " - 检测器:" << detectorPath << (detectorExists ? "存在" : "不存在");
            qDebug() << " - 特征点:" << landmarkerPath << (landmarkerExists ? "存在" : "不存在");
            qDebug() << " - 识别器:" << recognizerPath << (recognizerExists ? "存在" : "不存在");
        }
        
        // 如果还是找不到，尝试固定的开发路径
        if (!detectorExists || !landmarkerExists || !recognizerExists) {
            qDebug() << "尝试从固定开发路径加载...";
            detectorPath = "E:/SparkExamAI/SparkExamAI/SparkExamAI/model/fd_2_00.dat";
            landmarkerPath = "E:/SparkExamAI/SparkExamAI/SparkExamAI/model/pd_2_00_pts5.dat";
            recognizerPath = "E:/SparkExamAI/SparkExamAI/SparkExamAI/model/fr_2_10.dat";
            
            detectorExists = QFileInfo(detectorPath).exists();
            landmarkerExists = QFileInfo(landmarkerPath).exists();
            recognizerExists = QFileInfo(recognizerPath).exists();
            
            qDebug() << " - 检测器:" << detectorPath << (detectorExists ? "存在" : "不存在");
            qDebug() << " - 特征点:" << landmarkerPath << (landmarkerExists ? "存在" : "不存在");
            qDebug() << " - 识别器:" << recognizerPath << (recognizerExists ? "存在" : "不存在");
        }
        
        // 如果所有尝试都失败，返回失败
        if (!detectorExists || !landmarkerExists || !recognizerExists) {
            qDebug() << "紧急初始化失败：无法找到所有必需的模型文件";
            qDebug() << "===== 紧急初始化失败 =====\n";
            return false;
        }
        
        // 创建模型
        qDebug() << "使用找到的模型文件创建模型...";
        
        // 人脸检测器
        try {
            qDebug() << "创建人脸检测器...";
            seeta::ModelSetting FD_model(detectorPath.toStdString(), device, id);
            m_faceDetector = new seeta::FaceDetector(FD_model);
            m_faceDetector->set(seeta::FaceDetector::PROPERTY_MIN_FACE_SIZE, 80);
            qDebug() << "人脸检测器创建成功";
        } catch (const std::exception &e) {
            qDebug() << "创建人脸检测器失败:" << e.what();
            qDebug() << "===== 紧急初始化失败 =====\n";
            return false;
        }
        
        // 人脸特征点定位器
        try {
            qDebug() << "创建人脸特征点定位器...";
            seeta::ModelSetting PD_model(landmarkerPath.toStdString(), device, id);
            m_faceLandmarker = new seeta::FaceLandmarker(PD_model);
            qDebug() << "人脸特征点定位器创建成功";
        } catch (const std::exception &e) {
            qDebug() << "创建人脸特征点定位器失败:" << e.what();
            if (m_faceDetector) {
                delete m_faceDetector;
                m_faceDetector = nullptr;
            }
            qDebug() << "===== 紧急初始化失败 =====\n";
            return false;
        }
        
        // 人脸特征提取器
        try {
            qDebug() << "创建人脸特征提取器...";
            seeta::ModelSetting FR_model(recognizerPath.toStdString(), device, id);
            m_faceRecognizer = new seeta::FaceRecognizer(FR_model);
            qDebug() << "人脸特征提取器创建成功";
        } catch (const std::exception &e) {
            qDebug() << "创建人脸特征提取器失败:" << e.what();
            if (m_faceDetector) {
                delete m_faceDetector;
                m_faceDetector = nullptr;
            }
            if (m_faceLandmarker) {
                delete m_faceLandmarker;
                m_faceLandmarker = nullptr;
            }
            qDebug() << "===== 紧急初始化失败 =====\n";
            return false;
        }
        
        // 保存成功的模型路径
        QFileInfo info(detectorPath);
        m_modelPath = info.absolutePath();
        
        m_initialized = true;
        qDebug() << "紧急初始化成功，使用路径:" << m_modelPath;
        qDebug() << "===== 紧急初始化完成 =====\n";
        return true;
    } catch (const std::exception &e) {
        qDebug() << "紧急初始化时发生异常:" << e.what();
        qDebug() << "===== 紧急初始化失败 =====\n";
        return false;
    }
}

// 递归搜索模型文件
QStringList FaceRecognizer::findModelFiles(const QDir &dir) {
    QStringList results;
    QStringList modelFileNames;
    modelFileNames << "fd_2_00.dat" << "pd_2_00_pts5.dat" << "fr_2_10.dat";
    
    // 检查目录中的所有文件
    QStringList files = dir.entryList(QDir::Files);
    for (const QString &file : files) {
        if (modelFileNames.contains(file)) {
            results.append(dir.absoluteFilePath(file));
        }
    }
    
    // 递归搜索所有子目录
    QStringList subdirs = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QString &subdir : subdirs) {
        QDir subdirObj(dir.absoluteFilePath(subdir));
        results.append(findModelFiles(subdirObj));
    }
    
    return results;
}

bool FaceRecognizer::detectFace(const QString &imagePath)
{
    if (!m_initialized && !initialize()) {
        qDebug() << "Face detection models not initialized.";
        return false;
    }
    
    try {
        // 加载图像
        QImage image = loadImage(imagePath);
        if (image.isNull()) {
            qDebug() << "Failed to load image for face detection.";
            return false;
        }
        
        // 将QImage转换为OpenCV Mat
        cv::Mat mat = qImageToMat(image);
        if (mat.empty()) {
            qDebug() << "Failed to convert QImage to Mat";
            return false;
        }
        
        // 直接使用原始图像，不再调用cvtColor
        cv::Mat gray = mat.clone();
        
        // 创建SeetaFace的图像对象
        seeta::ImageData imageData(gray.cols, gray.rows, gray.channels());
        imageData.data = gray.data;
        
        // 检测人脸
        auto faces = m_faceDetector->detect(imageData);
        
        // 如果检测到人脸，返回true
        return faces.size > 0;
    }
    catch (const std::exception &e) {
        qDebug() << "Error detecting face: " << e.what();
        return false;
    }
}

bool FaceRecognizer::extractFeature(const QImage &image)
{
    if (!m_initialized && !initialize()) {
        qDebug() << "Face recognition models not initialized.";
        return false;
    }
    
    try {
        // 将QImage转换为OpenCV Mat
        cv::Mat mat = qImageToMat(image);
        if (mat.empty()) {
            qDebug() << "Failed to convert QImage to Mat";
            return false;
        }
        
        // 创建SeetaFace的图像对象
        seeta::ImageData imageData(mat.cols, mat.rows, mat.channels());
        imageData.data = mat.data;
        
        // 检测人脸
        auto faces = m_faceDetector->detect(imageData);
        if (faces.size == 0) {
            qDebug() << "No face detected in the image.";
            return false;
        }
        
        // 获取第一个人脸
        auto &face = faces.data[0];
        
        // 提取特征点
        auto points = m_faceLandmarker->mark(imageData, face.pos);
        
        // 检查特征点是否有效
        return points.size() > 0;
    }
    catch (const std::exception &e) {
        qDebug() << "Error extracting face features: " << e.what();
        return false;
    }
}

float FaceRecognizer::compareFaces(const QString &image1Path, const QString &image2Path)
{
    qDebug() << "Comparing faces:" << image1Path << "and" << image2Path;
    
    if (!m_initialized && !initialize()) {
        qDebug() << "Face recognition models not initialized.";
        return 0.0f;
    }
    
    try {
        // 加载两张图像
        QImage image1 = loadImage(image1Path);
        QImage image2 = loadImage(image2Path);
        
        if (image1.isNull() || image2.isNull()) {
            qDebug() << "Failed to load images.";
            return 0.0f;
        }
        
        qDebug() << "Images loaded successfully. Image1 size:" << image1.size() << "Image2 size:" << image2.size();
        
        // 转换为OpenCV Mat
        cv::Mat mat1 = qImageToMat(image1);
        cv::Mat mat2 = qImageToMat(image2);
        
        if (mat1.empty() || mat2.empty()) {
            qDebug() << "Failed to convert images to Mat";
            return 0.0f;
        }
        
        qDebug() << "Images converted to Mat. Mat1 size: width=" << mat1.cols << ", height=" << mat1.rows 
                 << ", channels=" << mat1.channels()
                 << ". Mat2 size: width=" << mat2.cols << ", height=" << mat2.rows  
                 << ", channels=" << mat2.channels();
        
        // 创建SeetaFace的图像对象
        seeta::ImageData imageData1(mat1.cols, mat1.rows, mat1.channels());
        imageData1.data = mat1.data;
        
        seeta::ImageData imageData2(mat2.cols, mat2.rows, mat2.channels());
        imageData2.data = mat2.data;
        
        // 检测人脸
        auto faces1 = m_faceDetector->detect(imageData1);
        auto faces2 = m_faceDetector->detect(imageData2);
        
        qDebug() << "Face detection results - Image1:" << faces1.size << "faces, Image2:" << faces2.size << "faces";
        
        if (faces1.size == 0 || faces2.size == 0) {
            qDebug() << "No face detected in one or both images.";
            return 0.0f;
        }
        
        // 获取第一个人脸
        auto &face1 = faces1.data[0];
        auto &face2 = faces2.data[0];
        
        // 提取特征点
        auto points1 = m_faceLandmarker->mark(imageData1, face1.pos);
        auto points2 = m_faceLandmarker->mark(imageData2, face2.pos);
        
        qDebug() << "Landmarks extracted - Image1:" << points1.size() << "points, Image2:" << points2.size() << "points";
        
        // 准备特征向量存储空间
        float feature1[1024] = {0};
        float feature2[1024] = {0};
        
        // 提取人脸特征
        #ifdef _WIN64
        // 64位系统上，保持原样
        m_faceRecognizer->Extract(imageData1, static_cast<const SeetaPointF*>(points1.data()), feature1);
        m_faceRecognizer->Extract(imageData2, static_cast<const SeetaPointF*>(points2.data()), feature2);
        #else
        // 32位系统上，先使用static_cast确保指针类型转换安全
        m_faceRecognizer->Extract(imageData1, reinterpret_cast<const SeetaPointF*>(points1.data()), feature1);
        m_faceRecognizer->Extract(imageData2, reinterpret_cast<const SeetaPointF*>(points2.data()), feature2);
        #endif
        
        // 计算相似度
        float similarity = m_faceRecognizer->CalculateSimilarity(feature1, feature2);
        
        qDebug() << "Face similarity score:" << similarity;
        return similarity;
    }
    catch (const std::exception &e) {
        qDebug() << "Error comparing faces: " << e.what();
        return 0.0f;
    }
}

QImage FaceRecognizer::loadImage(const QString &imagePath)
{
    // 处理URL格式的路径（file:///开头）
    QString filePath = imagePath;
    if (filePath.startsWith("file:///")) {
        QUrl url(filePath);
        filePath = url.toLocalFile();
        qDebug() << "转换URL路径到本地文件路径:" << imagePath << " -> " << filePath;
    }
    
    // 检查文件是否存在
    QFileInfo fileInfo(filePath);
    if (!fileInfo.exists() || !fileInfo.isFile()) {
        qDebug() << "文件不存在或不是文件:" << filePath;
        qDebug() << "检查应用程序目录:" << QApplication::applicationDirPath();
        
        // 尝试作为相对路径处理
        QString appDir = QApplication::applicationDirPath();
        QString tryPath = filePath;
        if (!tryPath.startsWith("/") && !tryPath.startsWith(appDir)) {
            tryPath = appDir + "/" + tryPath;
            qDebug() << "尝试作为相对路径处理:" << tryPath;
            QFileInfo tryInfo(tryPath);
            if (tryInfo.exists() && tryInfo.isFile()) {
                filePath = tryPath;
                qDebug() << "找到相对路径文件:" << filePath;
            }
        }
    }
    
    QImage image(filePath);
    if (image.isNull()) {
        qDebug() << "无法加载图像:" << filePath << "原始路径:" << imagePath;
    } else {
        qDebug() << "成功加载图像:" << filePath << "尺寸:" << image.size();
    }
    return image;
}

QImage FaceRecognizer::matToQImage(const cv::Mat &mat)
{
    if (mat.empty()) {
        qDebug() << "Empty Mat cannot be converted to QImage";
        return QImage();
    }
    
    // 8-bit, 3 channel
    if (mat.type() == CV_8UC3) {
        QImage image(mat.data, mat.cols, mat.rows, static_cast<int>(mat.step), QImage::Format_RGB888);
        return image.rgbSwapped(); // Convert BGR to RGB
    }
    // 8-bit, 1 channel
    else if (mat.type() == CV_8UC1) {
        QImage image(mat.data, mat.cols, mat.rows, static_cast<int>(mat.step), QImage::Format_Grayscale8);
        return image;
    }
    // Unsupported format
    else {
        qDebug() << "Unsupported Mat format for conversion to QImage:" << mat.type();
        return QImage();
    }
}

cv::Mat FaceRecognizer::qImageToMat(const QImage &image)
{
    if (image.isNull()) {
        qDebug() << "Cannot convert null QImage to Mat";
        return cv::Mat();
    }
    
    switch (image.format()) {
    case QImage::Format_RGB888: {
        // 创建一个BGR格式的Mat，然后手动复制和交换RGB通道
        cv::Mat mat(image.height(), image.width(), CV_8UC3);
        for (int y = 0; y < image.height(); y++) {
            const uchar* scan = image.scanLine(y);
            uchar* data = mat.ptr<uchar>(y);
            for (int x = 0; x < image.width(); x++) {
                // 手动交换RGB到BGR
                data[x*3+0] = scan[x*3+2]; // B = R
                data[x*3+1] = scan[x*3+1]; // G = G
                data[x*3+2] = scan[x*3+0]; // R = B
            }
        }
        return mat;
    }
    case QImage::Format_RGB32:
    case QImage::Format_ARGB32:
    case QImage::Format_ARGB32_Premultiplied: {
        // 创建一个BGR格式的Mat，然后手动复制和交换RGBA通道
        cv::Mat mat(image.height(), image.width(), CV_8UC3);
        for (int y = 0; y < image.height(); y++) {
            const QRgb* scan = reinterpret_cast<const QRgb*>(image.scanLine(y));
            uchar* data = mat.ptr<uchar>(y);
            for (int x = 0; x < image.width(); x++) {
                // 手动获取RGBA值并存储为BGR
                data[x*3+0] = qBlue(scan[x]);  // B
                data[x*3+1] = qGreen(scan[x]); // G
                data[x*3+2] = qRed(scan[x]);   // R
            }
        }
        return mat;
    }
    case QImage::Format_Grayscale8: {
        cv::Mat mat(image.height(), image.width(), CV_8UC1, (void*)image.constBits(), image.bytesPerLine());
        return mat.clone();
    }
    default:
        // 其他格式转为RGB888后再处理
        qDebug() << "Converting QImage format" << image.format() << "to RGB888";
        QImage converted = image.convertToFormat(QImage::Format_RGB888);
        // 重用上面的RGB888处理代码
        cv::Mat mat(converted.height(), converted.width(), CV_8UC3);
        for (int y = 0; y < converted.height(); y++) {
            const uchar* scan = converted.scanLine(y);
            uchar* data = mat.ptr<uchar>(y);
            for (int x = 0; x < converted.width(); x++) {
                // 手动交换RGB到BGR
                data[x*3+0] = scan[x*3+2]; // B = R
                data[x*3+1] = scan[x*3+1]; // G = G
                data[x*3+2] = scan[x*3+0]; // R = B
            }
        }
        return mat;
    }
}

// 人脸位置检测方法，返回人脸位置信息
QVariantMap FaceRecognizer::detectFacePosition(const QString &imagePath)
{
    QVariantMap result;
    result["faceDetected"] = false;
    
    qDebug() << "\n----- 开始检测人脸位置 -----";
    qDebug() << "图像路径:" << imagePath;
    
    // 检查文件是否存在
    QFileInfo fileInfo(imagePath);
    if (!fileInfo.exists() || !fileInfo.isFile()) {
        qDebug() << "人脸跟踪图像文件不存在:" << imagePath;
        qDebug() << "当前工作目录:" << QDir::currentPath();
        qDebug() << "应用程序目录:" << QApplication::applicationDirPath();
        
        // 尝试修复路径
        QString fixedPath = QApplication::applicationDirPath() + "/" + imagePath;
        QFileInfo fixedInfo(fixedPath);
        if (fixedInfo.exists() && fixedInfo.isFile()) {
            qDebug() << "找到图像文件的替代路径:" << fixedPath;
            fileInfo = fixedInfo;
        } else {
            qDebug() << "尝试替代路径仍然找不到图像文件:" << fixedPath;
            qDebug() << "----- 人脸检测失败：图像文件不存在 -----";
            return result;
        }
    }
    
    // 确保模型已初始化
    if (!m_initialized) {
        qDebug() << "人脸检测模型未初始化，尝试初始化...";
        if (!initialize()) {
            qDebug() << "人脸检测模型初始化失败.";
            qDebug() << "----- 人脸检测失败：模型初始化失败 -----";
            return result;
        }
    }
    
    try {
        // 加载图像
        qDebug() << "加载图像:" << fileInfo.absoluteFilePath();
        QImage image = loadImage(fileInfo.absoluteFilePath());
        if (image.isNull()) {
            qDebug() << "无法加载人脸跟踪图像:" << fileInfo.absoluteFilePath();
            qDebug() << "----- 人脸检测失败：无法加载图像 -----";
            return result;
        }
        
        // 记录图像尺寸
        result["imageWidth"] = image.width();
        result["imageHeight"] = image.height();
        qDebug() << "人脸跟踪图像尺寸:" << image.width() << "x" << image.height();
        
        // 将QImage转换为OpenCV Mat
        cv::Mat mat = qImageToMat(image);
        if (mat.empty()) {
            qDebug() << "无法将图像转换为Mat格式";
            qDebug() << "----- 人脸检测失败：图像转换失败 -----";
            return result;
        }
        
        qDebug() << "图像已转换为Mat格式. 尺寸:" << mat.cols << "x" << mat.rows 
                 << ", 通道数:" << mat.channels();
        
        // 创建SeetaFace的图像对象
        if (!m_faceDetector) {
            qDebug() << "人脸检测器为空，重新尝试初始化";
            if (!initialize()) {
                qDebug() << "重新初始化失败";
                qDebug() << "----- 人脸检测失败：检测器初始化失败 -----";
                return result;
            }
            
            if (!m_faceDetector) {
                qDebug() << "即使初始化成功，人脸检测器仍然为空";
                qDebug() << "----- 人脸检测失败：检测器为空 -----";
                return result;
            }
        }
        
        seeta::ImageData imageData(mat.cols, mat.rows, mat.channels());
        imageData.data = mat.data;
        
        // 检测人脸
        qDebug() << "开始SeetaFace人脸检测...";
        
        std::vector<SeetaFaceInfo> faceInfos;
        try {
            auto faces = m_faceDetector->detect(imageData);
            qDebug() << "SeetaFace检测到" << faces.size << "个人脸";
            
            // 如果检测到人脸
            if (faces.size > 0) {
                // 获取第一个人脸
                auto &face = faces.data[0];
                
                // 设置人脸位置信息
                result["faceDetected"] = true;
                result["x"] = face.pos.x;
                result["y"] = face.pos.y;
                result["width"] = face.pos.width;
                result["height"] = face.pos.height;
                result["score"] = face.score;
                
                // 添加旋转角度信息
                result["rotationAngle"] = m_rotationAngle;
                
                qDebug() << "人脸检测成功: 位置(" << face.pos.x << "," << face.pos.y 
                         << ") 尺寸(" << face.pos.width << "x" << face.pos.height
                         << ") 置信度:" << face.score
                         << " 旋转角度:" << m_rotationAngle;
                
                // 如果面部置信度太低，可能是误检，标记为未检测到
                if (face.score < 0.3) {
                    result["faceDetected"] = false;
                    qDebug() << "人脸置信度太低，忽略此次检测.";
                }
            } else {
                qDebug() << "未检测到人脸.";
            }
        } catch (const std::exception &e) {
            qDebug() << "人脸检测过程中发生异常:" << e.what();
            qDebug() << "----- 人脸检测失败：检测过程异常 -----";
            return result;
        }
        
        qDebug() << "----- 人脸检测完成 -----";
        return result;
    }
    catch (const std::exception &e) {
        qDebug() << "人脸位置检测出错: " << e.what();
        qDebug() << "----- 人脸检测失败：捕获异常 -----";
        return result;
    }
}

// 开始人脸追踪框的逆时针旋转
void FaceRecognizer::startRotation(int interval, float speed)
{
    m_rotationSpeed = speed;
    
    // 如果定时器已经运行，先停止
    if (m_rotationTimer->isActive()) {
        m_rotationTimer->stop();
    }
    
    // 设置新的定时器间隔并启动
    m_rotationTimer->setInterval(interval);
    m_rotationTimer->start();
    
    qDebug() << "开始人脸追踪框逆时针旋转, 间隔:" << interval << "毫秒, 速度:" << speed << "度/更新";
}

// 停止人脸追踪框的旋转
void FaceRecognizer::stopRotation()
{
    if (m_rotationTimer->isActive()) {
        m_rotationTimer->stop();
        qDebug() << "停止人脸追踪框旋转";
    }
}

// 更新旋转角度 (逆时针旋转)
void FaceRecognizer::updateRotation()
{
    // 更新角度 (逆时针旋转，即角度增加)
    m_rotationAngle += m_rotationSpeed;
    
    // 保持角度在0-360范围内
    if (m_rotationAngle >= 360.0f) {
        m_rotationAngle -= 360.0f;
    }
    
    // 发出角度变化信号
    emit rotationAngleChanged();
} 