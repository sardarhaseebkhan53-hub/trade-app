# NUKE FIX for double lock bug:
# 1) gradle-8.14.4-bin.zip  exclusive access timeout
# 2) buildLogic.lock  Timeout waiting to lock build logic queue. Owner PID: 4588

Write-Host "=== GRADLE LOCK NUKE - FINAL FIX ===" -ForegroundColor Red

# 0. Go to trade-app root (one level above scripts)
Set-Location "$PSScriptRoot\.."
$projectAndroidGradle = "$(Get-Location)\android\.gradle"
$projectBuild = "$(Get-Location)\android\build"
$projectAppBuild = "$(Get-Location)\android\app\build"

# 1. Kill known PIDs from your log + all java
Write-Host "[1/6] Killing Owner PID 4588 and all java daemons..." -ForegroundColor Yellow
taskkill /F /PID 4588 2>$null; taskkill /F /PID 12252 2>$null
Get-Process -Name "java","javaw","gradle" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 2. Stop Gradle daemons via wrapper if still present
Write-Host "[2/6] gradlew --stop" -ForegroundColor Yellow
if (Test-Path ".\android\gradlew.bat") {
    cmd /c ".\android\gradlew.bat --stop" 2>$null
}

# 3. DELETE PROJECT LOCKS - fixes "buildLogic.lock"
Write-Host "[3/6] Deleting $projectAndroidGradle (buildLogic.lock)" -ForegroundColor Yellow
Remove-Item -Recurse -Force $projectAndroidGradle -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $projectBuild -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $projectAppBuild -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ".\build" -ErrorAction SilentlyContinue

# Double-check lock file path from your log
$lockFile = "C:\Users\TECHNIFI\Videos\trade-app-main\android\.gradle\noVersion\buildLogic.lock"
if (Test-Path $lockFile) {
    Write-Host "Deleting specific lock file: $lockFile" -ForegroundColor Red
    Remove-Item -Force $lockFile -ErrorAction SilentlyContinue
}

# 4. DELETE GLOBAL WRAPPER DIST - fixes gradle-8.14.4-bin.zip timeout
$gradleDist = "$env:USERPROFILE\.gradle\wrapper\dists\gradle-8.14.4-bin"
Write-Host "[4/6] Deleting $gradleDist (zip lock)" -ForegroundColor Yellow
Remove-Item -Recurse -Force $gradleDist -ErrorAction SilentlyContinue

# Also clear all *.lock *.lck in .gradle cache
Get-ChildItem "$env:USERPROFILE\.gradle" -Include "*.lock","*.lck" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# 5. Clean Flutter
Write-Host "[5/6] flutter clean & pub get (if flutter in PATH)" -ForegroundColor Yellow
flutter clean 2>$null
flutter pub get 2>$null

# 6. Manual wrapper download hint + Defender exclusion
Write-Host "[6/6] Adding Defender exclusion hint & verifying files" -ForegroundColor Yellow
Write-Host "  -> Please manually add Windows Defender exclusion for:" -ForegroundColor Cyan
Write-Host "     $env:USERPROFILE\.gradle"
Write-Host "     (Windows Security > Virus & Threat Protection > Manage Settings > Exclusions > Add Folder)" -ForegroundColor Cyan

Write-Host ""
Write-Host "PROJECT FIXES APPLIED:" -ForegroundColor Green
Get-Content ".\android\gradle.properties"
Write-Host "--- wrapper ---"
Get-Content ".\android\gradle\wrapper\gradle-wrapper.properties"

Write-Host ""
Write-Host "NEXT: Run this ONE command now:" -ForegroundColor Green
Write-Host "  flutter run -d 10546373B2148905 --no-configuration-cache -v" -ForegroundColor White
Write-Host "If it still fails downloading gradle-8.14.4-bin.zip, download manually:"
Write-Host "  https://services.gradle.org/distributions/gradle-8.14.4-bin.zip"
Write-Host "And run: .\android\gradlew.bat --no-daemon --no-configuration-cache tasks"
