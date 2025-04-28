@echo off
echo ==== �ǻ���������ϵͳ����ű� ====
echo ��������Ŀ¼...

REM ����ԴĿ¼��Ŀ��Ŀ¼
set SOURCE_DIR=.\build
set TARGET_DIR=.\Release

REM ����Ŀ��Ŀ¼
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
if not exist "%TARGET_DIR%\model" mkdir "%TARGET_DIR%\model"

echo �����������DLL�ļ�...
copy "%SOURCE_DIR%\SparkExamAI.exe" "%TARGET_DIR%\" /Y
copy "%SOURCE_DIR%\*.dll" "%TARGET_DIR%\" /Y

echo ����ģ���ļ���model��Ŀ¼...
copy "%SOURCE_DIR%\model\*.dat" "%TARGET_DIR%\model\" /Y

echo ����ģ���ļ�����Ŀ¼...
copy "%SOURCE_DIR%\model\*.dat" "%TARGET_DIR%\" /Y

echo �������ݿ��ļ�...
if not exist "%TARGET_DIR%\database" mkdir "%TARGET_DIR%\database"
copy "%SOURCE_DIR%\database\*.*" "%TARGET_DIR%\database\" /Y

echo ����ͷ��ͼƬ...
if not exist "%TARGET_DIR%\avatarimages" mkdir "%TARGET_DIR%\avatarimages"
copy "%SOURCE_DIR%\avatarimages\*.*" "%TARGET_DIR%\avatarimages\" /Y

echo ��������ͼƬ...
if not exist "%TARGET_DIR%\faceimages" mkdir "%TARGET_DIR%\faceimages"
copy "%SOURCE_DIR%\faceimages\*.*" "%TARGET_DIR%\faceimages\" /Y

echo ������ʱĿ¼...
if not exist "%TARGET_DIR%\temp" mkdir "%TARGET_DIR%\temp"

echo ����Qt������...
REM ʹ��windeployqt���߸���Qt������
if exist "C:\Qt\5.15.2\msvc2019_64\bin\windeployqt.exe" (
    echo ʹ��Qt���𹤾߸���Qt������...
    "C:\Qt\5.15.2\msvc2019_64\bin\windeployqt.exe" "%TARGET_DIR%\SparkExamAI.exe" --qmldir . --no-translations
) else (
    echo δ�ҵ�windeployqt���ߣ����ֶ�����Qt������
)

echo.
echo ==== ���ģ���ļ� ====
if exist "%TARGET_DIR%\model\fd_2_00.dat" (
    echo ģ��Ŀ¼�е��������ģ��: ����
) else (
    echo ģ��Ŀ¼�е��������ģ��: �����ڣ�
)

if exist "%TARGET_DIR%\model\pd_2_00_pts5.dat" (
    echo ģ��Ŀ¼�е�����������ģ��: ����
) else (
    echo ģ��Ŀ¼�е�����������ģ��: �����ڣ�
)

if exist "%TARGET_DIR%\model\fr_2_10.dat" (
    echo ģ��Ŀ¼�е�����ʶ��ģ��: ����
) else (
    echo ģ��Ŀ¼�е�����ʶ��ģ��: �����ڣ�
)

echo.
echo ==== ����Ŀ¼�е�ģ���ļ� ====
if exist "%TARGET_DIR%\fd_2_00.dat" (
    echo ��Ŀ¼�е��������ģ��: ����
) else (
    echo ��Ŀ¼�е��������ģ��: �����ڣ�
)

if exist "%TARGET_DIR%\pd_2_00_pts5.dat" (
    echo ��Ŀ¼�е�����������ģ��: ����
) else (
    echo ��Ŀ¼�е�����������ģ��: �����ڣ�
)

if exist "%TARGET_DIR%\fr_2_10.dat" (
    echo ��Ŀ¼�е�����ʶ��ģ��: ����
) else (
    echo ��Ŀ¼�е�����ʶ��ģ��: �����ڣ�
)

echo.
echo ==== ���DLL�ļ� ====
if exist "%TARGET_DIR%\SeetaFaceDetector.dll" (
    echo SeetaFaceDetector.dll: ����
) else (
    echo SeetaFaceDetector.dll: �����ڣ�
)

if exist "%TARGET_DIR%\SeetaFaceLandmarker.dll" (
    echo SeetaFaceLandmarker.dll: ����
) else (
    echo SeetaFaceLandmarker.dll: �����ڣ�
)

if exist "%TARGET_DIR%\SeetaFaceRecognizer.dll" (
    echo SeetaFaceRecognizer.dll: ����
) else (
    echo SeetaFaceRecognizer.dll: �����ڣ�
)

if exist "%TARGET_DIR%\SeetaNet.dll" (
    echo SeetaNet.dll: ����
) else (
    echo SeetaNet.dll: �����ڣ�
)

echo.
echo ==== ������� ====
echo �����Ѳ��� %TARGET_DIR% Ŀ¼
echo.
echo �뽫ReleaseĿ¼�е������ļ�һ���Ƶ�Ŀ�겿��λ��
pause 