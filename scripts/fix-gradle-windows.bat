@echo off
echo === Fixing Gradle Wrapper Lock (Windows) ===
echo [1/5] Killing Java processes...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul

echo [2/5] Cleaning Gradle wrapper dists...
rmdir /S /Q "%USERPROFILE%\.gradle\wrapper\dists\gradle-8.14.4-bin" 2>nul
del /S /Q "%USERPROFILE%\.gradle\*.lock" 2>nul
del /S /Q "%USERPROFILE%\.gradle\*.lck" 2>nul

echo [3/5] Cleaning project build folders...
cd /D "%~dp0.."
rmdir /S /Q build 2>nul
rmdir /S /Q android\.gradle 2>nul
rmdir /S /Q android\app\build 2>nul
rmdir /S /Q android\build 2>nul

echo [4/5] Stopping Gradle daemons...
call android\gradlew.bat --stop 2>nul

echo [5/5] Cleaning Flutter...
where flutter >nul 2>&1
if %ERRORLEVEL%==0 (
  flutter clean
  flutter pub get
) else (
  echo Flutter not in PATH, skip
)

echo.
echo DONE. Now try: flutter run -v
echo If still failing, add Windows Defender exclusion for %%USERPROFILE%%\.gradle
pause
