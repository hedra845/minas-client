# PowerShell script to convert SVG to PNG
# This script provides instructions for converting the SVG background to PNG

Write-Host "SVG to PNG Conversion Instructions" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""
Write-Host "To convert the SVG background to PNG, you can use one of these methods:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Method 1: Online Converter" -ForegroundColor Cyan
Write-Host "1. Go to https://convertio.co/svg-png/ or https://cloudconvert.com/svg-to-png" -ForegroundColor White
Write-Host "2. Upload assets/splash_bg.svg" -ForegroundColor White
Write-Host "3. Set output size to 1080x1920 pixels" -ForegroundColor White
Write-Host "4. Download and save as assets/splash_bg.png" -ForegroundColor White
Write-Host ""
Write-Host "Method 2: Inkscape (Free)" -ForegroundColor Cyan
Write-Host "1. Download Inkscape from https://inkscape.org/" -ForegroundColor White
Write-Host "2. Open assets/splash_bg.svg" -ForegroundColor White
Write-Host "3. File > Export PNG Image" -ForegroundColor White
Write-Host "4. Set size to 1080x1920 pixels" -ForegroundColor White
Write-Host "5. Export as assets/splash_bg.png" -ForegroundColor White
Write-Host ""
Write-Host "Method 3: Command Line (if you have ImageMagick)" -ForegroundColor Cyan
Write-Host "magick assets/splash_bg.svg -resize 1080x1920 assets/splash_bg.png" -ForegroundColor White
Write-Host ""
Write-Host "After conversion, update the splash screen to use PNG instead of SVG:" -ForegroundColor Yellow
Write-Host "Replace SvgPicture.asset with DecorationImage in splash_screen.dart" -ForegroundColor White 