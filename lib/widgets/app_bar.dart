import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MinasAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final ThemeProvider themeProvider;
  final String? title;

  const MinasAppBar({
    super.key,
    required this.isDarkMode,
    required this.themeProvider,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:
          title != null
              ? Text(
                title!,
                style: TextStyle(
                  color: isDarkMode ? AppColors.white : AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
              : null,
      surfaceTintColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDarkMode ? AppColors.darkText : AppColors.lightText,
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      leading: Builder(
        builder:
            (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(15),
                child: SvgPicture.asset(
                  'assets/images/menu.svg',
                  color: isDarkMode ? AppColors.white : AppColors.primary,
                ),
              ),
            ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final userName = userProvider.getDisplayName();
              return Row(
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      color: isDarkMode ? AppColors.white : AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => themeProvider.toggleTheme(),
                    child: _buildIconContainer(
                      isDarkMode,
                      Icon(
                        themeProvider.getThemeModeIcon(),
                        color:
                            isDarkMode
                                ? AppColors.secondary
                                : AppColors.primary,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  _buildIconContainer(
                    isDarkMode,
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                      child: SvgPicture.asset(
                        'assets/images/notfication.svg',
                        color: isDarkMode ? AppColors.white : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: _buildIconContainer(
                      isDarkMode,
                      SvgPicture.asset(
                        'assets/images/user.svg',
                        color: isDarkMode ? AppColors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer(bool isDark, Widget child) {
    return Container(
      padding: const EdgeInsets.all(3),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: child,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
