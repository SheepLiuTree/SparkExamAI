#include "FaceRecognizer.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QApplication>

FaceRecognizer::FaceRecognizer(QObject *parent) : QObject(parent),
    m_faceDetector(nullptr),
    m_faceLandmarker(nullptr),
    m_faceRecognizer(nullptr),
    m_initialized(false)
{
    // 设置模型路径为当前应用程序目录下的model文件夹
    m_modelPath = QApplication::applicationDirPath() + "/model";
    qDebug() << "SeetaFace2 model path:" << m_modelPath;
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
}

bool FaceRecognizer::initialize()
{
    if (m_initialized) {
        return true; // 已经初始化过了
    }

    try {
        qDebug() << "Initializing face recognition models...";
        
        // 检查模型目录是否存在
        QDir modelDir(m_modelPath);
        if (!modelDir.exists()) {
            qDebug() << "Model directory does not exist: " << m_modelPath;
            return false;
        }
        
        // 检查模型文件是否存在 - 修改为匹配实际文件名
        QFileInfo detectorFile(m_modelPath + "/fd_2_00.dat");
        QFileInfo landmarkerFile(m_modelPath + "/pd_2_00_pts5.dat");
        QFileInfo recognizerFile(m_modelPath + "/fr_2_10.dat");
        
        qDebug() << "Checking for detector file:" << detectorFile.absoluteFilePath() << "exists:" << detectorFile.exists();
        qDebug() << "Checking for landmarker file:" << landmarkerFile.absoluteFilePath() << "exists:" << landmarkerFile.exists();
        qDebug() << "Checking for recognizer file:" << recognizerFile.absoluteFilePath() << "exists:" << recognizerFile.exists();
        
        if (!detectorFile.exists() || !landmarkerFile.exists() || !recognizerFile.exists()) {
            qDebug() << "Model files not found in directory: " << m_modelPath;
            return false;
        }
        
        // 配置人脸检测器
        seeta::ModelSetting::Device device = seeta::ModelSetting::CPU;
        int id = 0;
        
        qDebug() << "Creating face detector...";
        seeta::ModelSetting FD_model(detectorFile.absoluteFilePath().toStdString(), device, id);
        m_faceDetector = new seeta::FaceDetector(FD_model);
        // 使用正确的方法设置参数
        m_faceDetector->set(seeta::FaceDetector::PROPERTY_MIN_FACE_SIZE, 80);
        
        // 配置人脸特征点定位器
        qDebug() << "Creating face landmarker...";
        seeta::ModelSetting PD_model(landmarkerFile.absoluteFilePath().toStdString(), device, id);
        m_faceLandmarker = new seeta::FaceLandmarker(PD_model);
        
        // 配置人脸特征提取器
        qDebug() << "Creating face recognizer...";
        seeta::ModelSetting FR_model(recognizerFile.absoluteFilePath().toStdString(), device, id);
        m_faceRecognizer = new seeta::FaceRecognizer(FR_model);
        
        m_initialized = true;
        qDebug() << "Face recognition models initialized successfully.";
        return true;
    }
    catch (const std::exception &e) {
        qDebug() << "Error initializing face recognition models: " << e.what();
        return false;
    }
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
        
        // 转换为灰度图像
        cv::Mat gray;
        if (mat.channels() == 3) {
            cv::cvtColor(mat, gray, cv::COLOR_BGR2RGB);
        } else {
            gray = mat.clone();
        }
        
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
        m_faceRecognizer->Extract(imageData1, points1.data(), feature1);
        m_faceRecognizer->Extract(imageData2, points2.data(), feature2);
        
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
    QImage image(imagePath);
    if (image.isNull()) {
        qDebug() << "Failed to load image: " << imagePath;
    } else {
        qDebug() << "Successfully loaded image:" << imagePath << "Size:" << image.size();
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
        QImage image(mat.data, mat.cols, mat.rows, mat.step, QImage::Format_RGB888);
        return image.rgbSwapped(); // Convert BGR to RGB
    }
    // 8-bit, 1 channel
    else if (mat.type() == CV_8UC1) {
        QImage image(mat.data, mat.cols, mat.rows, mat.step, QImage::Format_Grayscale8);
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
        cv::Mat mat(image.height(), image.width(), CV_8UC3, (void*)image.constBits(), image.bytesPerLine());
        cv::cvtColor(mat, mat, cv::COLOR_RGB2BGR); // Convert RGB to BGR
        return mat.clone();
    }
    case QImage::Format_RGB32:
    case QImage::Format_ARGB32:
    case QImage::Format_ARGB32_Premultiplied: {
        cv::Mat mat(image.height(), image.width(), CV_8UC4, (void*)image.constBits(), image.bytesPerLine());
        cv::cvtColor(mat, mat, cv::COLOR_RGBA2BGR); // Convert RGBA to BGR
        return mat.clone();
    }
    case QImage::Format_Grayscale8: {
        cv::Mat mat(image.height(), image.width(), CV_8UC1, (void*)image.constBits(), image.bytesPerLine());
        return mat.clone();
    }
    default:
        // 其他格式转为RGB888后再处理
        qDebug() << "Converting QImage format" << image.format() << "to RGB888";
        QImage converted = image.convertToFormat(QImage::Format_RGB888);
        cv::Mat mat(converted.height(), converted.width(), CV_8UC3, (void*)converted.constBits(), converted.bytesPerLine());
        cv::cvtColor(mat, mat, cv::COLOR_RGB2BGR); // Convert RGB to BGR
        return mat.clone();
    }
}

// 人脸位置检测方法，返回人脸位置信息
QVariantMap FaceRecognizer::detectFacePosition(const QString &imagePath)
{
    QVariantMap result;
    result["faceDetected"] = false;
    
    qDebug() << "开始检测人脸位置:" << imagePath;
    
    // 检查文件是否存在
    QFileInfo fileInfo(imagePath);
    if (!fileInfo.exists() || !fileInfo.isFile()) {
        qDebug() << "人脸跟踪图像文件不存在:" << imagePath;
        return result;
    }
    
    if (!m_initialized && !initialize()) {
        qDebug() << "人脸检测模型未初始化.";
        return result;
    }
    
    try {
        // 加载图像
        QImage image = loadImage(imagePath);
        if (image.isNull()) {
            qDebug() << "无法加载人脸跟踪图像:" << imagePath;
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
            return result;
        }
        
        qDebug() << "图像已转换为Mat格式. 尺寸:" << mat.cols << "x" << mat.rows 
                 << ", 通道数:" << mat.channels();
        
        // 创建SeetaFace的图像对象
        seeta::ImageData imageData(mat.cols, mat.rows, mat.channels());
        imageData.data = mat.data;
        
        // 检测人脸
        qDebug() << "开始SeetaFace人脸检测...";
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
            
            qDebug() << "人脸检测成功: 位置(" << face.pos.x << "," << face.pos.y 
                     << ") 尺寸(" << face.pos.width << "x" << face.pos.height
                     << ") 置信度:" << face.score;
            
            // 如果面部置信度太低，可能是误检，标记为未检测到
            if (face.score < 0.3) {
                result["faceDetected"] = false;
                qDebug() << "人脸置信度太低，忽略此次检测.";
            }
        } else {
            qDebug() << "未检测到人脸.";
        }
        
        return result;
    }
    catch (const std::exception &e) {
        qDebug() << "人脸位置检测出错: " << e.what();
        return result;
    }
} 