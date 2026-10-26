# Light and Dark Mode Implementation Guide

This guide explains how to use the new light and dark mode system implemented in your Flutter app.

## 🎨 Features

- **Light Theme**: Clean, bright interface with light backgrounds
- **Dark Theme**: Easy on the eyes with dark backgrounds
- **System Theme**: Automatically follows device theme preference
- **Persistent Settings**: Theme choice is saved and restored
- **Global Theme Switcher**: Quick toggle in the top-left corner
- **Settings Page**: Detailed theme management

## 🚀 Quick Start

### 1. Theme Switching

The app now includes a global theme switcher in the top-left corner of every screen. Tap it to cycle through:
- 🌞 Light Mode
- 🌙 Dark Mode  
- 🔄 System Mode (follows device setting)

### 2. Settings Page

Navigate to `/settings` to access the comprehensive settings page with:
- Theme selection with visual preview
- Language settings
- Notification preferences
- Privacy and support options

## 📁 File Structure

```
lib/
├── theme/
│   ├── app_theme.dart          # Theme definitions
│   └── theme_provider.dart     # Theme state management
├── widgets/
│   └── theme_switcher.dart     # Theme switching widgets
├── constans/
│   └── colors.dart             # Updated color constants
├── settings_page.dart          # Settings page
└── example_theme_usage.dart    # Usage examples
```

## 🎯 How to Use in Your Code

### 1. Basic Theme Usage

Instead of hard-coded colors, use theme-aware components:

```dart
// ❌ Before (hard-coded)
Container(
  color: Colors.white,
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.black),
  ),
)

// ✅ After (theme-aware)
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text(
      'Hello',
      style: Theme.of(context).textTheme.bodyLarge,
    ),
  ),
)
```

### 2. Using Theme Colors

```dart
// Access theme colors
final colorScheme = Theme.of(context).colorScheme;

Container(
  color: colorScheme.surface,        // Background color
  child: Text(
    'Text',
    style: TextStyle(
      color: colorScheme.onSurface,  // Text color
    ),
  ),
)
```

### 3. Using Theme Text Styles

```dart
// Use predefined text styles
Text(
  'Title',
  style: Theme.of(context).textTheme.titleLarge,
)

Text(
  'Body text',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### 4. Adding Theme Switcher

```dart
// In AppBar actions
AppBar(
  title: Text('My Page'),
  actions: [
    ThemeSwitcher(),  // Dropdown menu
    // or
    SimpleThemeSwitcher(),  // Simple toggle
  ],
)
```

## 🔧 Migration Guide

### Step 1: Replace Hard-coded Colors

| Before | After |
|--------|-------|
| `Colors.white` | `Theme.of(context).colorScheme.surface` |
| `Colors.black` | `Theme.of(context).colorScheme.onSurface` |
| `Colors.grey` | `Theme.of(context).colorScheme.onSurface.withOpacity(0.6)` |

### Step 2: Use Theme Text Styles

| Before | After |
|--------|-------|
| `TextStyle(color: Colors.black)` | `Theme.of(context).textTheme.bodyLarge` |
| `TextStyle(fontSize: 18, fontWeight: FontWeight.bold)` | `Theme.of(context).textTheme.headlineMedium` |

### Step 3: Use Theme-aware Widgets

| Before | After |
|--------|-------|
| `Container(color: Colors.white)` | `Card()` |
| `TextField()` | `TextField()` (already theme-aware) |
| `ElevatedButton()` | `ElevatedButton()` (already theme-aware) |

## 🎨 Color System

### Light Theme Colors
- **Background**: `#FFFFFF` (Pure white)
- **Surface**: `#FAFAFA` (Light gray)
- **Text**: `#1A1A1A` (Dark gray)
- **Text Secondary**: `#666666` (Medium gray)
- **Divider**: `#ECECEC` (Light gray)

### Dark Theme Colors
- **Background**: `#121212` (Dark gray)
- **Surface**: `#1E1E1E` (Medium dark gray)
- **Card**: `#2D2D2D` (Card background)
- **Text**: `#FFFFFF` (White)
- **Text Secondary**: `#B3B3B3` (Light gray)
- **Divider**: `#404040` (Dark gray)

### Brand Colors (Same in both themes)
- **Primary**: `#03003E` (Dark blue)
- **Secondary**: `#455EC3` (Medium blue)
- **Tertiary**: `#33BAE0` (Light blue)

## 🧪 Testing

### Example Pages

1. **Theme Example**: `/theme-example`
   - Shows all theme components
   - Demonstrates proper usage
   - Includes color scheme examples

2. **Migration Example**: `/theme-migration`
   - Shows before/after comparisons
   - Explains migration steps
   - Best practices guide

3. **Settings Page**: `/settings`
   - Full settings interface
   - Theme management
   - Other app settings

## 🔍 Troubleshooting

### Common Issues

1. **Colors not changing**: Make sure you're using `Theme.of(context)` instead of hard-coded colors
2. **Text not visible**: Check contrast between text and background colors
3. **Theme not persisting**: Ensure `shared_preferences` dependency is added

### Debug Tips

```dart
// Check current theme mode
Consumer<ThemeProvider>(
  builder: (context, themeProvider, _) {
    print('Current theme: ${themeProvider.getThemeModeName()}');
    return YourWidget();
  },
)

// Check if dark mode is active
if (Theme.of(context).brightness == Brightness.dark) {
  print('Dark mode is active');
}
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Desktop (Windows, macOS, Linux)

## 🔄 Future Enhancements

- Custom theme colors
- High contrast mode
- Reduced motion support
- Color scheme customization
- Theme presets

## 📚 Additional Resources

- [Flutter Theme Documentation](https://docs.flutter.dev/ui/advanced/themes)
- [Material Design Color System](https://m3.material.io/foundations/color)
- [Provider Package Documentation](https://pub.dev/packages/provider)

---

**Note**: The old `app_colors` class is still available for backward compatibility, but it's recommended to migrate to the new theme system for better maintainability and user experience.
