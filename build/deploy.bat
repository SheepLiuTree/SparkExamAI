@echo off
setlocal enabledelayedexpansion

:: ���ó������ļ����� windeployqt ·��
set EXE_NAME=SparkExamAI.exe
set QT_BIN=C:\Qt\5.15.2\mingw81_64\bin\windeployqt.exe
set OUT_DIR=deploy_output
set RESOURCE_DIRS=database model

echo [1/5] ��������Ŀ¼...
rd /s /q %OUT_DIR% >nul 2>nul
mkdir %OUT_DIR%

echo [2/5] ���Ƴ������ļ�...
copy %EXE_NAME% %OUT_DIR%\ >nul

echo [3/5] ���� Qt ��̬��Ͳ��...
"%QT_BIN%" --qmldir . --no-angle --no-opengl-sw %OUT_DIR%\%EXE_NAME%

echo [4/5] ����ģ�ͺ���Դ�ļ���...
for %%D in (%RESOURCE_DIRS%) do (
    if exist %%D (
        echo     -> ���� %%D
        xcopy /s /e /i /y %%D %OUT_DIR%\%%D >nul
    ) else (
        echo     !! δ�ҵ���ԴĿ¼ %%D������
    )
)

echo.
echo ? ������ɣ����Ŀ¼��%OUT_DIR%
pause
