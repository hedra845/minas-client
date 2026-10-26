import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minas_client/providers/language_provider.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Settings
          _buildSettingsSection(
            context,
            title: 'language'.tr(),
            icon: Icons.language,
            children: [
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, _) {
                  final supportedLanguages = languageProvider.getSupportedLanguages();
                  final currentLanguage = languageProvider.currentLanguageCode;
                  
                  return Column(
                    children: supportedLanguages.map((lang) {
                      final isSelected = lang['code'] == currentLanguage;
                      
                      return _buildLanguageOption(
                        context,
                        title: lang['name']!,
                        subtitle: lang['nativeName']!,
                        isSelected: isSelected,
                        leading: Text(
                          lang['flag']!,
                          style: const TextStyle(fontSize: 20),
                        ),
                        onTap: () async {
                          await languageProvider.changeLanguageByCode(lang['code']!);
                          if (context.mounted) {
                            context.setLocale(languageProvider.currentLocale);
                          }
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Language Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Consumer<LanguageProvider>(
                  builder: (context, languageProvider, _) {
                    final languageInfo = languageProvider.getLanguageInfo();
                    final stats = languageProvider.getLanguageStats();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'current_language'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              languageInfo['flag'] ?? '🇺🇸',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  languageInfo['name']!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  languageInfo['nativeName']!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Theme Settings
          _buildSettingsSection(
            context,
            title: 'theme'.tr(),
            icon: Icons.palette,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Column(
                    children: [
                      _buildThemeOption(
                        context,
                        title: 'light_mode'.tr(),
                        subtitle: 'Light theme',
                        icon: Icons.light_mode,
                        isSelected: themeProvider.themeMode == ThemeMode.light,
                        onTap:
                            () => themeProvider.setThemeMode(ThemeMode.light),
                      ),
                      _buildThemeOption(
                        context,
                        title: 'dark_mode'.tr(),
                        subtitle: 'Dark theme',
                        icon: Icons.dark_mode,
                        isSelected: themeProvider.themeMode == ThemeMode.dark,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                      ),
                      _buildThemeOption(
                        context,
                        title: 'auto'.tr(),
                        subtitle: 'Follow system',
                        icon: Icons.settings_system_daydream,
                        isSelected: themeProvider.themeMode == ThemeMode.system,
                        onTap:
                            () => themeProvider.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // const SizedBox(height: 24),

          // // Other Settings
          // _buildSettingsSection(
          //   context,
          //   title: 'preferences'.tr(),
          //   icon: Icons.settings,
          //   children: [
          //     _buildSettingsTile(
          //       context,
          //       title: 'notifications'.tr(),
          //       subtitle: 'Manage notifications',
          //       icon: Icons.notifications,
          //       onTap: () {
          //         // Navigate to notifications settings
          //       },
          //     ),
          //     _buildSettingsTile(
          //       context,
          //       title: 'privacy'.tr(),
          //       subtitle: 'Privacy settings',
          //       icon: Icons.privacy_tip,
          //       onTap: () {
          //         // Navigate to privacy settings
          //       },
          //     ),
          //     _buildSettingsTile(
          //       context,
          //       title: 'security'.tr(),
          //       subtitle: 'Security settings',
          //       icon: Icons.security,
          //       onTap: () {
          //         // Navigate to security settings
          //       },
          //     ),
          //   ],
          // ),
          const SizedBox(height: 24),

          // About Section
          _buildSettingsSection(
            context,
            title: 'about'.tr(),
            icon: Icons.info,
            children: [
              _buildSettingsTile(
                context,
                title: 'help'.tr(),
                subtitle: 'Get help and support',
                icon: Icons.help,
                onTap: () {
                  // Navigate to help page
                },
              ),
              _buildSettingsTile(
                context,
                title: 'contact_us'.tr(),
                subtitle: 'Contact support team',
                icon: Icons.contact_support,
                onTap: () {
                  // Navigate to contact page
                },
              ),
              _buildSettingsTile(
                context,
                title: 'version'.tr(),
                subtitle: '1.0.0',
                icon: Icons.info_outline,
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required Widget leading,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing:
          isSelected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : null,
      onTap: onTap,
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing:
          isSelected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : null,
      onTap: onTap,
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing:
          onTap != null
              ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              )
              : null,
      onTap: onTap,
    );
  }
}
