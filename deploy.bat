@echo off
echo ==== 星火智能评测系统部署脚本 ====
echo 创建部署目录...

REM 设置源目录和目标目录
set SOURCE_DIR=.\build
set TARGET_DIR=.\Release

REM 创建目标目录
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
if not exist "%TARGET_DIR%\model" mkdir "%TARGET_DIR%\model"

echo 复制主程序和DLL文件...
copy "%SOURCE_DIR%\SparkExamAI.exe" "%TARGET_DIR%\" /Y
copy "%SOURCE_DIR%\*.dll" "%TARGET_DIR%\" /Y

echo 复制模型文件到model子目录...
copy "%SOURCE_DIR%\model\*.dat" "%TARGET_DIR%\model\" /Y

echo 复制模型文件到根目录...
copy "%SOURCE_DIR%\model\*.dat" "%TARGET_DIR%\" /Y

echo 复制数据库文件...
if not exist "%TARGET_DIR%\database" mkdir "%TARGET_DIR%\database"
copy "%SOURCE_DIR%\database\*.*" "%TARGET_DIR%\database\" /Y

echo 复制头像图片...
if not exist "%TARGET_DIR%\avatarimages" mkdir "%TARGET_DIR%\avatarimages"
copy "%SOURCE_DIR%\avatarimages\*.*" "%TARGET_DIR%\avatarimages\" /Y

echo 复制人脸图片...
if not exist "%TARGET_DIR%\faceimages" mkdir "%TARGET_DIR%\faceimages"
copy "%SOURCE_DIR%\faceimages\*.*" "%TARGET_DIR%\faceimages\" /Y

echo 创建临时目录...
if not exist "%TARGET_DIR%\temp" mkdir "%TARGET_DIR%\temp"

echo 复制Qt依赖项...
REM 使用windeployqt工具复制Qt依赖项
if exist "C:\Qt\5.15.2\msvc2019_64\bin\windeployqt.exe" (
    echo 使用Qt部署工具复制Qt依赖项...
    "C:\Qt\5.15.2\msvc2019_64\bin\windeployqt.exe" "%TARGET_DIR%\SparkExamAI.exe" --qmldir . --no-translations
) else (
    echo 未找到windeployqt工具，请手动复制Qt依赖项
)

echo.
echo ==== 检查模型文件 ====
if exist "%TARGET_DIR%\model\fd_2_00.dat" (
    echo 模型目录中的人脸检测模型: 存在
) else (
    echo 模型目录中的人脸检测模型: 不存在！
)

if exist "%TARGET_DIR%\model\pd_2_00_pts5.dat" (
    echo 模型目录中的人脸特征点模型: 存在
) else (
    echo 模型目录中的人脸特征点模型: 不存在！
)

if exist "%TARGET_DIR%\model\fr_2_10.dat" (
    echo 模型目录中的人脸识别模型: 存在
) else (
    echo 模型目录中的人脸识别模型: 不存在！
)

echo.
echo ==== 检查根目录中的模型文件 ====
if exist "%TARGET_DIR%\fd_2_00.dat" (
    echo 根目录中的人脸检测模型: 存在
) else (
    echo 根目录中的人脸检测模型: 不存在！
)

if exist "%TARGET_DIR%\pd_2_00_pts5.dat" (
    echo 根目录中的人脸特征点模型: 存在
) else (
    echo 根目录中的人脸特征点模型: 不存在！
)

if exist "%TARGET_DIR%\fr_2_10.dat" (
    echo 根目录中的人脸识别模型: 存在
) else (
    echo 根目录中的人脸识别模型: 不存在！
)

echo.
echo ==== 检查DLL文件 ====
if exist "%TARGET_DIR%\SeetaFaceDetector.dll" (
    echo SeetaFaceDetector.dll: 存在
) else (
    echo SeetaFaceDetector.dll: 不存在！
)

if exist "%TARGET_DIR%\SeetaFaceLandmarker.dll" (
    echo SeetaFaceLandmarker.dll: 存在
) else (
    echo SeetaFaceLandmarker.dll: 不存在！
)

if exist "%TARGET_DIR%\SeetaFaceRecognizer.dll" (
    echo SeetaFaceRecognizer.dll: 存在
) else (
    echo SeetaFaceRecognizer.dll: 不存在！
)

if exist "%TARGET_DIR%\SeetaNet.dll" (
    echo SeetaNet.dll: 存在
) else (
    echo SeetaNet.dll: 不存在！
)

echo.
echo ==== 部署完成 ====
echo 程序已部署到 %TARGET_DIR% 目录
echo.
echo 请将Release目录中的所有文件一起复制到目标部署位置
pause 