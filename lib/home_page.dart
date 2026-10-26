import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:minas_client/widgets/quick_actions_drawer.dart';
import 'package:minas_client/providers/user_provider.dart';
import 'package:minas_client/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/widgets/custom_bottom_navigation.dart';

class TravelHomePage extends StatefulWidget {
  const TravelHomePage({super.key});

  @override
  State<TravelHomePage> createState() => _TravelHomePageState();
}

dynamic color_cards = [app_colors.primary, app_colors.secondary];

class _TravelHomePageState extends State<TravelHomePage> {
  @override
  void initState() {
    super.initState();
    // Load user data when the home page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Scaffold(
      appBar: MinasAppBar(isDarkMode: isDarkMode, themeProvider: themeProvider),
      drawer: QuickActionsDrawer(isDarkMode: isDarkMode),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/image_fx_ - 2025-02-03T204732.727.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Overlay with theme-aware opacity
            Positioned.fill(
              child: Container(
                color: (isDarkMode ? AppColors.darkSurface : app_colors.primary)
                    .withOpacity(0.6),
              ),
            ),

            // Top gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isDarkMode ? AppColors.black : Colors.black).withOpacity(
                        0.7,
                      ),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                  ),
                ),
              ),
            ),
            // Main content
            Positioned.fill(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/minas_logo.png',
                      height: 80,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'text_title_home'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? AppColors.darkText : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'text_subtitle_home'.tr(),
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? AppColors.darkTextSecondary
                              : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/form_deposit'),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isDarkMode
                                  ? AppColors.darkText
                                  : app_colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'button_start_now'.tr(),
                        style: TextStyle(
                          color: isDarkMode ? AppColors.darkText : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  // Service buttons container
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDarkMode
                                  ? AppColors.darkShadow
                                  : AppColors.lightShadow,
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _serviceButton(
                              "button_Hajj_and_Umrah".tr(),
                              'assets/images/Hajj_and_Umrah.svg',
                              isDarkMode: isDarkMode,
                              onTap:
                                  () => Navigator.pushNamed(context, '/offers'),
                            ),
                            _serviceButton(
                              "button_airplane_tickets".tr(),
                              'assets/images/plane.svg',
                              gradient: LinearGradient(colors: color_cards),
                              isDarkMode: isDarkMode,
                              onTap:
                                  () => Navigator.pushNamed(context, '/offers'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _serviceButton(
                              "button_other".tr(),
                              'assets/images/Other_services.svg',
                              isDarkMode: isDarkMode,
                              onTap:
                                  () => Navigator.pushNamed(context, '/offers'),
                            ),
                            _serviceButton(
                              "button_visa".tr(),
                              'assets/images/visa.svg',
                              isDarkMode: isDarkMode,
                              onTap:
                                  () => Navigator.pushNamed(context, '/offers'),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index != 0) {
            BottomNavigationHelper.navigateToPage(context, index);
          }
        },
      ),
    );
      },
    );
  }
}

Widget _serviceButton(
  String title,
  String icon, {
  LinearGradient? gradient,
  required bool isDarkMode,
  VoidCallback? onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          color:
              gradient == null
                  ? (isDarkMode ? AppColors.darkSurface : Colors.white)
                  : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border:
              gradient == null
                  ? Border.all(
                    color:
                        isDarkMode
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                    width: 1,
                  )
                  : null,
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              icon,
              color:
                  gradient == null
                      ? (isDarkMode ? app_colors.white : app_colors.primary)
                      : Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    gradient == null
                        ? (isDarkMode ? AppColors.darkText : app_colors.primary)
                        : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
