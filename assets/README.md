# Assets Directory

This directory contains assets for the Minas Travel app.

## Splash Screen Assets

### Required Files:
- `splash_logo.png` - The main logo for the splash screen
  - Should be a white logo on transparent background
  - Recommended size: 512x512 pixels
  - Will be automatically colorized by the splash screen configuration

### Background Options:

#### Option 1: Programmatic Background (Current Implementation)
- Uses `lib/background_painter.dart` - Custom painter that draws the background programmatically
- Features: airplanes, buildings, runway, stars, and gradient
- No additional assets required
- Best performance and compatibility

#### Option 2: SVG Background
- `splash_bg.svg` - SVG background image for the splash screen
  - Beautiful airport/travel themed background
  - Features airplanes, buildings, and runway elements
  - Uses the app's blue gradient colors
- Requires `flutter_svg` dependency

#### Option 3: PNG Background
- `splash_bg.png` - PNG version of the background image
  - Convert from SVG for better compatibility
  - Recommended size: 1080x1920 pixels
- Use `convert_svg_to_png.ps1` for conversion instructions

## How to Add Assets

1. Place your logo image in this directory as `splash_logo.png`
2. Run `flutter pub get` to update dependencies
3. Run `flutter pub run flutter_native_splash:create` to generate the splash screen assets
4. The splash screen will automatically use your logo

## Current Configuration

The splash screen is configured in `flutter_native_splash.yaml` with:
- Dark blue gradient background (#1E3A8A to #2563EB)
- White logo with automatic colorization
- Fullscreen mode enabled
- Support for Android 12+ splash screen

## Background Implementation

The current implementation uses a custom `BackgroundPainter` that draws:
- Gradient background from dark blue to light blue
- Cloud patterns with subtle opacity
- Multiple airplanes at different angles
- Airport buildings with windows
- Runway markings
- Stars and moon in the sky 