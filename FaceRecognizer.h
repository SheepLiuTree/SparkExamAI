#ifndef FACERECOGNIZER_H
#define FACERECOGNIZER_H

#include <QObject>
#include <QString>
#include <QImage>
#include <QDebug>
#include <opencv2/opencv.hpp>
#include <QVariantMap>
#include <QTimer>
#include <QDir>

// SeetaFace2 include files
#include <seeta/FaceDetector.h>
#include <seeta/FaceRecognizer.h>
#include <seeta/FaceLandmarker.h>

/**
 * @brief 人脸识别器类
 * 
 * 使用OpenCV和SeetaFace2进行人脸检测和识别
 */
class FaceRecognizer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(float rotationAngle READ rotationAngle NOTIFY rotationAngleChanged)

public:
    explicit FaceRecognizer(QObject *parent = nullptr);
    ~FaceRecognizer();

    /**
     * @brief 初始化人脸识别模型
     * @return 是否初始化成功
     */
    Q_INVOKABLE bool initialize();

    /**
     * @brief 从图像中检测人脸
     * @param imagePath 图像路径
     * @return 是否检测到人脸
     */
    Q_INVOKABLE bool detectFace(const QString &imagePath);

    /**
     * @brief 提取人脸特征
     * @param image QImage格式的图像
     * @return 提取的特征是否有效
     */
    Q_INVOKABLE bool extractFeature(const QImage &image);

    /**
     * @brief 比较两张人脸图像的相似度
     * @param image1Path 第一张图像的路径
     * @param image2Path 第二张图像的路径
     * @return 相似度得分，范围0-1，越大越相似
     */
    Q_INVOKABLE float compareFaces(const QString &image1Path, const QString &image2Path);

    /**
     * @brief 从图像路径获取QImage对象
     * @param imagePath 图像路径
     * @return QImage对象
     */
    Q_INVOKABLE QImage loadImage(const QString &imagePath);

    /**
     * @brief 转换OpenCV Mat到QImage
     * @param mat OpenCV Mat图像
     * @return QImage对象
     */
    Q_INVOKABLE QImage matToQImage(const cv::Mat &mat);

    /**
     * @brief 转换QImage到OpenCV Mat
     * @param image QImage对象
     * @return OpenCV Mat图像
     */
    Q_INVOKABLE cv::Mat qImageToMat(const QImage &image);

    // 用于人脸跟踪的方法，返回人脸位置信息
    Q_INVOKABLE QVariantMap detectFacePosition(const QString &imagePath);

    // 获取当前旋转角度
    float rotationAngle() const { return m_rotationAngle; }

    /**
     * @brief 开始人脸追踪框的逆时针旋转
     * @param interval 旋转更新间隔 (毫秒)
     * @param speed 旋转速度 (每次更新的角度增量)
     */
    Q_INVOKABLE void startRotation(int interval = 50, float speed = 2.0f);

    /**
     * @brief 停止人脸追踪框的旋转
     */
    Q_INVOKABLE void stopRotation();

signals:
    // 当旋转角度改变时发出信号
    void rotationAngleChanged();

private slots:
    // 更新旋转角度
    void updateRotation();

private:
    // SeetaFace2 models
    seeta::FaceDetector *m_faceDetector;
    seeta::FaceLandmarker *m_faceLandmarker;
    seeta::FaceRecognizer *m_faceRecognizer;

    // 模型是否已初始化
    bool m_initialized;

    // 模型路径
    QString m_modelPath;

    // 旋转角度 (0-360度)
    float m_rotationAngle;
    
    // 旋转速度 (每次更新的角度)
    float m_rotationSpeed;
    
    // 用于控制旋转的定时器
    QTimer *m_rotationTimer;
    
    // 递归搜索模型文件的辅助方法
    QStringList findModelFiles(const QDir &dir);
    
    // 紧急初始化方法 - 使用硬编码路径
    bool emergency_initialize();
};

#endif // FACERECOGNIZER_H 