import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minas_client/providers/language_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showIcon;
  final Color? textColor;
  final double? fontSize;
  final bool showFlag;
  final bool showNativeName;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const LanguageSwitcher({
    super.key,
    this.showIcon = true,
    this.textColor,
    this.fontSize,
    this.showFlag = false,
    this.showNativeName = false,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final isArabic = languageProvider.isArabic;
        final languageInfo = languageProvider.getLanguageInfo();
        
        return InkWell(
          onTap: () => _showLanguageDialog(context, languageProvider),
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon) ...[
                  Icon(
                    Icons.language,
                    color: textColor ?? theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                if (showFlag) ...[
                  Text(
                    isArabic ? '🇸🇦' : '🇺🇸',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isArabic ? 'English' : 'العربية',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor ?? theme.colorScheme.primary,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (showNativeName) ...[
                      const SizedBox(height: 2),
                      Text(
                        languageInfo['nativeName']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor?.withOpacity(0.7) ?? theme.colorScheme.onSurfaceVariant,
                          fontSize: (fontSize ?? 14) - 2,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: textColor ?? theme.colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => LanguageSelectionDialog(languageProvider: languageProvider),
    );
  }
}

// Simple language toggle button
class LanguageToggleButton extends StatelessWidget {
  final bool showFlag;
  final bool compact;

  const LanguageToggleButton({
    super.key,
    this.showFlag = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final isArabic = languageProvider.isArabic;
        
        return ElevatedButton.icon(
          onPressed: () async {
            await languageProvider.toggleLanguage();
            if (context.mounted) {
              context.setLocale(languageProvider.currentLocale);
            }
          },
          icon: Icon(
            Icons.language,
            color: Colors.white,
            size: compact ? 16 : 20,
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showFlag) ...[
                Text(
                  isArabic ? '🇺🇸' : '🇸🇦',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                languageProvider.getLanguageCodeForDisplay(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 12 : 14,
                ),
              ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: compact 
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );
      },
    );
  }
}

// Language selection dialog
class LanguageSelectionDialog extends StatelessWidget {
  final LanguageProvider languageProvider;

  const LanguageSelectionDialog({
    super.key,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supportedLanguages = languageProvider.getSupportedLanguages();
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.language, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('language_settings'.tr()),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedLanguages.map((lang) {
            final isSelected = lang['code'] == languageProvider.currentLanguageCode;
            
            return ListTile(
              leading: Text(
                lang['flag']!,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(lang['name']!),
              subtitle: Text(lang['nativeName']!),
              trailing: isSelected 
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              selected: isSelected,
              onTap: () async {
                await languageProvider.changeLanguageByCode(lang['code']!);
                if (context.mounted) {
                  context.setLocale(languageProvider.currentLocale);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr()),
        ),
      ],
    );
  }
}

// Compact language indicator
class LanguageIndicator extends StatelessWidget {
  final bool showFlag;
  final bool showCode;

  const LanguageIndicator({
    super.key,
    this.showFlag = true,
    this.showCode = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final isArabic = languageProvider.isArabic;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlag) ...[
              Text(
                isArabic ? '🇸🇦' : '🇺🇸',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
            ],
            if (showCode) ...[
              Text(
                languageProvider.getLanguageCodeForDisplay(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
