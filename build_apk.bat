@echo off
chcp 65001 >nul
echo ========================================================
echo   Token Monitor 极速本地构建打包器 (Flutter 3.24)
echo ========================================================
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot\"
set "ANDROID_HOME=D:\dev_tools\android-sdk"
set "GRADLE_USER_HOME=D:\dev_tools\.gradle"
set "PUB_HOSTED_URL=https://pub.flutter-io.cn"
set "FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn"
set "PATH=D:\dev_tools\flutter\bin;D:\dev_tools\android-sdk\platform-tools;D:\dev_tools\android-sdk\cmdline-tools\latest\bin;%PATH%"

cd /d "%~dp0mobile"
echo [1/3] 解析依赖...
call flutter pub get

echo [2/3] 开始编译 Release APK (主流 arm64-v8a 架构)...
call flutter build apk --release --target-platform android-arm64

if %ERRORLEVEL% equ 0 (
    echo [3/3] 正在复制产物到交付目录...
    if not exist "%~dp0mobile\build-output" mkdir "%~dp0mobile\build-output"
    copy /y "%~dp0mobile\build\app\outputs\flutter-apk\app-release.apk" "%~dp0mobile\build-output\TokenMonitor-release.apk" >nul
    copy /y "%~dp0mobile\build\app\outputs\flutter-apk\app-release.apk" "d:\PYTHON\Ai passport\TokenMonitor-release.apk" >nul
    echo.
    echo ========================================================
    echo   [SUCCESS] 打包成功！耗时约 40-60 秒！
    echo   输出路径: d:\PYTHON\Ai passport\TokenMonitor-release.apk
    echo ========================================================
) else (
    echo.
    echo [ERROR] 编译失败，请检查上方日志。
)
pause
