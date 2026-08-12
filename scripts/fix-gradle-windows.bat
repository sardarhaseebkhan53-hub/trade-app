@echo off
echo === GRADLE LOCK NUKE - FINAL FIX ===
cd /D "%~dp0.."

echo [1/6] Killing Owner PID 4588 and all Java...
taskkill /F /PID 4588 2>nul
taskkill /F /PID 12252 2>nul
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
timeout /t 2 /nobreak >nul

echo [2/6] gradlew --stop
call android\gradlew.bat --stop 2>nul

echo [3/6] Deleting android\.gradle buildLogic.lock
rmdir /S /Q android\.gradle 2>nul
rmdir /S /Q android\build 2>nul
rmdir /S /Q android\app\build 2>nul
rmdir /S /Q build 2>nul
del /Q "C:\Users\TECHNIFI\Videos\trade-app-main\android\.gradle\noVersion\buildLogic.lock" 2>nul

echo [4/6] Deleting %USERPROFILE%\.gradle\wrapper\dists\gradle-8.14.4-bin
rmdir /S /Q "%USERPROFILE%\.gradle\wrapper\dists\gradle-8.14.4-bin" 2>nul

echo [5/6] flutter clean
flutter clean 2>nul
flutter pub get 2>nul

echo [6/6] Verify gradle.properties
type android\gradle.properties
echo --- wrapper ---
type android\gradle\wrapper\gradle-wrapper.properties

echo.
echo NEXT: flutter run -d 10546373B2148905 --no-configuration-cache -v
pause
