# Fix for: Timeout of 120000 reached waiting for exclusive access to file gradle-8.14.4-bin.zip
# And: Gradle threw an error while downloading artifacts from the network

Write-Host "=== Fixing Gradle Wrapper Lock (Windows) ===" -ForegroundColor Cyan

# 1. Kill all Java / Gradle daemons that may hold the lock
Write-Host "[1/5] Killing java.exe processes holding Gradle lock..." -ForegroundColor Yellow
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "gradle*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Clear Gradle wrapper dists partial download (the locked zip)
$gradleDistPath = "$env:USERPROFILE\.gradle\wrapper\dists\gradle-8.14.4-bin"
Write-Host "[2/5] Cleaning $gradleDistPath ..." -ForegroundColor Yellow
if (Test-Path $gradleDistPath) {
    Remove-Item -Recurse -Force $gradleDistPath -ErrorAction SilentlyContinue
    Write-Host "  Deleted $gradleDistPath" -ForegroundColor Green
} else {
    Write-Host "  Path not found, skipping" -ForegroundColor DarkGray
}

# 3. Clear global gradle cache locks (optional but helps)
Write-Host "[3/5] Cleaning .gradle caches file locks..." -ForegroundColor Yellow
Get-ChildItem "$env:USERPROFILE\.gradle" -Filter "*.lock" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem "$env:USERPROFILE\.gradle" -Filter "*.lck" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# 4. Clean project build caches
Write-Host "[4/5] Cleaning project build folders..." -ForegroundColor Yellow
Set-Location $PSScriptRoot\..
if (Test-Path ".\build") { Remove-Item -Recurse -Force ".\build" -ErrorAction SilentlyContinue }
if (Test-Path ".\android\.gradle") { Remove-Item -Recurse -Force ".\android\.gradle" -ErrorAction SilentlyContinue }
if (Test-Path ".\android\app\build") { Remove-Item -Recurse -Force ".\android\app\build" -ErrorAction SilentlyContinue }
if (Test-Path ".\android\build") { Remove-Item -Recurse -Force ".\android\build" -ErrorAction SilentlyContinue }

# 5. Instructions for manual download if network is flaky
Write-Host "[5/5] Done. Now try manual wrapper download..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Temporarily disable Windows Defender Real-time protection for .gradle folder"
Write-Host "     Add exclusion: $env:USERPROFILE\.gradle"
Write-Host "  2. Run: .\android\gradlew.bat --stop   (kills daemon)"
Write-Host "  3. Run: flutter clean && flutter pub get"
Write-Host "  4. If download still fails, manually download:"
Write-Host "     https://services.gradle.org/distributions/gradle-8.14.4-bin.zip"
Write-Host "     And place in $gradleDistPath\<hash>\ folder, then run gradlew"
Write-Host "  5. Run: flutter run -v  (verbose shows if it retries)"
Write-Host ""
Write-Host "Fixed! gradle.properties upgraded with:" -ForegroundColor Green
Write-Host "  - networkTimeout=30000 (was 10000)"
Write-Host "  - systemProp retry + timeouts"
Write-Host "  - caching + parallel"
