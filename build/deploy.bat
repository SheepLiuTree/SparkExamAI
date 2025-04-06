@echo off
setlocal enabledelayedexpansion

:: 设置程序主文件名和 windeployqt 路径
set EXE_NAME=SparkExamAI.exe
set QT_BIN=C:\Qt\5.15.2\mingw81_64\bin\windeployqt.exe
set OUT_DIR=deploy_output
set RESOURCE_DIRS=database model

echo [1/5] 清理旧输出目录...
rd /s /q %OUT_DIR% >nul 2>nul
mkdir %OUT_DIR%

echo [2/5] 复制程序主文件...
copy %EXE_NAME% %OUT_DIR%\ >nul

echo [3/5] 部署 Qt 动态库和插件...
"%QT_BIN%" --qmldir . --no-angle --no-opengl-sw %OUT_DIR%\%EXE_NAME%

echo [4/5] 拷贝模型和资源文件夹...
for %%D in (%RESOURCE_DIRS%) do (
    if exist %%D (
        echo     -> 复制 %%D
        xcopy /s /e /i /y %%D %OUT_DIR%\%%D >nul
    ) else (
        echo     !! 未找到资源目录 %%D，跳过
    )
)

echo.
echo ? 部署完成！输出目录：%OUT_DIR%
pause
