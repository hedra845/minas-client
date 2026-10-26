# PowerShell script to generate splash screen assets
# Make sure you have placed your logo as 'assets/splash_logo.png' before running this script

Write-Host "Generating splash screen assets..." -ForegroundColor Green

# Check if logo exists
if (-not (Test-Path "assets/splash_logo.png")) {
    Write-Host "Error: assets/splash_logo.png not found!" -ForegroundColor Red
    Write-Host "Please place your logo image in the assets directory as 'splash_logo.png'" -ForegroundColor Yellow
    Write-Host "Recommended size: 512x512 pixels, white logo on transparent background" -ForegroundColor Yellow
    exit 1
}

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Blue
flutter pub get

# Generate splash screen assets
Write-Host "Generating native splash screen assets..." -ForegroundColor Blue
flutter pub run flutter_native_splash:create

Write-Host "Splash screen assets generated successfully!" -ForegroundColor Green
Write-Host "You can now build your app with the new splash screen." -ForegroundColor Green 