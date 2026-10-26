import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class ThemeSwitcher extends StatelessWidget {
  final bool showLabel;
  final double? size;
  final Color? backgroundColor;
  final Color? iconColor;

  const ThemeSwitcher({
    super.key,
    this.showLabel = false,
    this.size,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return PopupMenuButton<ThemeMode>(
          icon: Icon(
            themeProvider.getThemeModeIcon(),
            size: size ?? 24,
            color: iconColor ?? Theme.of(context).iconTheme.color,
          ),
          onSelected: (ThemeMode themeMode) {
            themeProvider.setThemeMode(themeMode);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Row(
                children: [
                  Icon(
                    Icons.light_mode,
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Light',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.light
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: themeProvider.themeMode == ThemeMode.light
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode,
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dark',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: themeProvider.themeMode == ThemeMode.dark
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_auto,
                    color: themeProvider.themeMode == ThemeMode.system
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'System',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.system
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: themeProvider.themeMode == ThemeMode.system
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SimpleThemeSwitcher extends StatelessWidget {
  final double? size;
  final Color? backgroundColor;
  final Color? iconColor;

  const SimpleThemeSwitcher({
    super.key,
    this.size,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          onPressed: () {
            themeProvider.toggleTheme();
          },
          icon: Icon(
            themeProvider.getThemeModeIcon(),
            size: size ?? 24,
            color: iconColor ?? Theme.of(context).iconTheme.color,
          ),
          style: backgroundColor != null
              ? IconButton.styleFrom(
                  backgroundColor: backgroundColor,
                )
              : null,
        );
      },
    );
  }
}

class ThemeSwitcherCard extends StatelessWidget {
  const ThemeSwitcherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.brightness_6,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ThemeOption(
                        title: 'Light',
                        icon: Icons.light_mode,
                        isSelected: themeProvider.themeMode == ThemeMode.light,
                        onTap: () => themeProvider.setLightMode(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ThemeOption(
                        title: 'Dark',
                        icon: Icons.dark_mode,
                        isSelected: themeProvider.themeMode == ThemeMode.dark,
                        onTap: () => themeProvider.setDarkMode(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ThemeOption(
                        title: 'System',
                        icon: Icons.brightness_auto,
                        isSelected: themeProvider.themeMode == ThemeMode.system,
                        onTap: () => themeProvider.setSystemMode(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
