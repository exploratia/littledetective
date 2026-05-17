c:
cd \
cd dev/littledetective

call flutter build apk --split-per-abi

REM echo copy to desktop

REM xcopy .\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk D:\OneDrive\Desktop /Y
