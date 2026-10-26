import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minas_client/widgets/custom_bottom_navigation.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:minas_client/widgets/quick_actions_drawer.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class MembershipCard extends StatelessWidget {
  const MembershipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: MinasAppBar(isDarkMode: isDarkMode, themeProvider: themeProvider),
      drawer: QuickActionsDrawer(isDarkMode: isDarkMode),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'membership_card'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.primary,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Card(
                color: AppColors.primary,
                child: Stack(
                  children: [
                    // Text content on the left
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 120, // Leave space for SVG
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MINAS Logo
                          Image.asset(
                            'assets/images/minas_logo.png',
                            height: 40,
                            color: Colors.white,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'العضوية العادية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildFeatureItem('5-10 خدمات', '5-10 services'),
                          SizedBox(height: 8),
                          _buildFeatureItem(
                            'الدعم الفني 24/7',
                            '24/7 technical support',
                          ),
                          SizedBox(height: 8),
                          _buildFeatureItem(
                            'محدودية الوصول إلى الميزات',
                            'Limited access to features',
                          ),
                          SizedBox(height: 8),
                          _buildFeatureItem(
                            'التحديثات الشهرية',
                            'Monthly updates',
                          ),
                        ],
                      ),
                    ),
                    // SVG on the right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: SvgPicture.asset(
                        "assets/images/Ellipse_card.svg",
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // MINAS Logo at bottom right
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: SvgPicture.asset(
                        "assets/images/minas_logo_v_c.svg",
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          if (index != 4) {
            BottomNavigationHelper.navigateToPage(context, index);
          }
        },
      ),
    );
  }

  Widget _buildFeatureItem(String arabicText, String englishText) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.white, size: 12),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                arabicText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                englishText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
