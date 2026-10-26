# Flutter App Translation Guide - Enhanced Version

This guide explains how to use the enhanced translation system in the Flutter app, which supports English and Arabic languages with advanced features.

## 🚀 Enhanced Features

- **Bilingual Support**: English and Arabic translations
- **RTL Support**: Automatic Right-to-Left text direction for Arabic
- **Persistent Language Selection**: User's language choice is saved and restored
- **Automatic Device Language Detection**: App automatically detects and uses the device's language on first launch
- **Dynamic Language Switching**: Change language at runtime without restarting the app
- **Advanced Language Management**: Country codes, flags, and language statistics
- **Smart Language Provider**: Enhanced state management with error handling
- **Multiple UI Components**: Various language switcher widgets for different use cases

## 🔧 Enhanced Language Provider

The `LanguageProvider` now includes advanced features:

### New Methods
```dart
// Get language information
final languageInfo = languageProvider.getLanguageInfo();
final stats = languageProvider.getLanguageStats();

// Check language support
bool isSupported = languageProvider.isLanguageSupported('fr');

// Toggle between languages
await languageProvider.toggleLanguage();

// Change language with country
await languageProvider.changeLanguageWithCountry('en', 'US');

// Reset to device language
await languageProvider.resetToDeviceLanguage(deviceLocale);
```

### Language Statistics
```dart
Map<String, dynamic> stats = languageProvider.getLanguageStats();
// Returns: {
//   'currentLanguage': 'en',
//   'currentCountry': 'US',
//   'isRTL': false,
//   'supportedLanguages': 2,
//   'lastChanged': '2025-01-20T10:30:00.000Z'
// }
```

## 🎨 Enhanced UI Components

### 1. LanguageSwitcher (Advanced)
```dart
LanguageSwitcher(
  showIcon: true,
  showFlag: true,
  showNativeName: true,
  padding: EdgeInsets.all(16),
  borderRadius: BorderRadius.circular(12),
)
```

### 2. LanguageToggleButton (Enhanced)
```dart
LanguageToggleButton(
  showFlag: true,
  compact: false,
)
```

### 3. LanguageSelectionDialog (New)
```dart
// Automatically shows when tapping LanguageSwitcher
// Displays all supported languages with flags and native names
```

### 4. LanguageIndicator (New)
```dart
LanguageIndicator(
  showFlag: true,
  showCode: true,
)
```

## 📱 Usage Examples

### Basic Language Switching
```dart
// Simple toggle
final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
await languageProvider.toggleLanguage();

// Specific language
await languageProvider.changeLanguageByCode('ar');
```

### Advanced Language Management
```dart
// Get current language info
final info = languageProvider.getLanguageInfo();
print('Current: ${info['name']} (${info['nativeName']})');

// Check RTL support
if (languageProvider.isArabic) {
  // Handle RTL layout
}

// Get supported languages
final languages = languageProvider.getSupportedLanguages();
for (final lang in languages) {
  print('${lang['flag']} ${lang['name']} (${lang['nativeName']})');
}
```

### UI Integration
```dart
// In AppBar
AppBar(
  title: Text('page_title'.tr()),
  actions: [
    LanguageToggleButton(showFlag: true),
  ],
)

// In settings
LanguageSwitcher(
  showFlag: true,
  showNativeName: true,
  padding: EdgeInsets.all(16),
)

// Compact indicator
LanguageIndicator(showFlag: true, showCode: false)
```

## 🌍 Adding New Languages

### 1. Update LanguageProvider
```dart
// In getSupportedLanguages()
{
  'code': 'fr',
  'name': 'French',
  'nativeName': 'Français',
  'country': 'FR',
  'flag': '🇫🇷',
}
```

### 2. Add Translation Files
Create `assets/translations/fr.json`:
```json
{
  "home": "Accueil",
  "settings": "Paramètres",
  "language": "Langue"
}
```

### 3. Update Main App
```dart
// In main.dart
supportedLocales: const [
  Locale('en'), 
  Locale('ar'), 
  Locale('fr')  // Add new locale
],
```

## 🔍 Language Detection & Fallbacks

### Device Language Detection
```dart
// Automatic detection on app start
final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

// Smart fallback
if (deviceLocale.languageCode == 'ar') {
  initialLocale = const Locale('ar');
} else {
  initialLocale = const Locale('en'); // Default fallback
}
```

### Error Handling
```dart
try {
  await languageProvider.changeLanguage(locale);
} catch (e) {
  debugPrint('Language change failed: $e');
  // Fallback to English
  await languageProvider.changeLanguage(const Locale('en'));
}
```

## 📊 Performance & Best Practices

### 1. Efficient Language Switching
```dart
// Use async/await for language changes
onPressed: () async {
  await languageProvider.changeLanguageByCode('ar');
  if (context.mounted) {
    context.setLocale(languageProvider.currentLocale);
  }
}
```

### 2. Memory Management
```dart
// Dispose providers properly
@override
void dispose() {
  languageProvider.dispose();
  super.dispose();
}
```

### 3. Translation Key Naming
```dart
// Use descriptive, hierarchical keys
"user_profile_name": "Name",
"user_profile_email": "Email",
"user_profile_phone": "Phone"

// Avoid generic keys
"text1": "Name",  // ❌ Bad
"name": "Name",   // ✅ Good
```

## 🧪 Testing

### Test Language Switching
```dart
// Test all supported languages
for (final lang in languageProvider.getSupportedLanguages()) {
  await languageProvider.changeLanguageByCode(lang['code']!);
  expect(languageProvider.currentLanguageCode, lang['code']);
}
```

### Test RTL Layout
```dart
// Test Arabic RTL
await languageProvider.changeLanguageByCode('ar');
expect(languageProvider.isArabic, true);
expect(languageProvider.currentLocale.languageCode, 'ar');
```

### Test Persistence
```dart
// Test language persistence
await languageProvider.changeLanguageByCode('ar');
await app.restart();
expect(languageProvider.currentLanguageCode, 'ar');
```

## 🚨 Troubleshooting

### Common Issues

1. **Language Not Persisting**
   ```dart
   // Check SharedPreferences permissions
   // Verify LanguageProvider initialization
   // Check for error logs
   ```

2. **RTL Not Working**
   ```dart
   // Ensure easy_localization is configured
   // Check Directionality widgets
   // Verify locale is set to Arabic
   ```

3. **Translation Keys Missing**
   ```dart
   // Check both JSON files
   // Verify .tr() method calls
   // Run flutter analyze
   ```

### Debug Commands
```bash
# Check for syntax errors
flutter analyze

# Run with verbose logging
flutter run --verbose

# Check device locale
flutter run --debug
```

## 📚 Dependencies

```yaml
dependencies:
  easy_localization: ^3.0.0
  provider: ^6.0.0
  shared_preferences: ^2.0.0
```

## 🏗️ File Structure

```
assets/
  translations/
    en.json          # English translations
    ar.json          # Arabic translations

lib/
  providers/
    language_provider.dart    # Enhanced language management
  widgets/
    language_switcher.dart    # Advanced UI components
  main.dart                   # App initialization
```

## 🔮 Future Enhancements

- **Multi-language Support**: Add French, Spanish, etc.
- **Dynamic Translations**: Load from server
- **Context-aware**: Cultural adaptations
- **Pluralization**: Handle plural forms
- **Date/Number Formatting**: Locale-specific formatting
- **Translation Memory**: Learn user preferences
- **Voice Commands**: Voice language switching

## 📖 API Reference

### LanguageProvider Methods
- `changeLanguage(Locale locale)`
- `changeLanguageByCode(String code)`
- `toggleLanguage()`
- `getLanguageInfo()`
- `getLanguageStats()`
- `isLanguageSupported(String code)`

### Widget Properties
- `LanguageSwitcher`: `showIcon`, `showFlag`, `showNativeName`
- `LanguageToggleButton`: `showFlag`, `compact`
- `LanguageIndicator`: `showFlag`, `showCode`

This enhanced translation system provides a robust, user-friendly, and maintainable solution for multi-language Flutter applications.
