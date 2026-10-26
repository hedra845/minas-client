import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:minas_client/widgets/float_action_b.dart';
import 'package:minas_client/widgets/quick_actions_drawer.dart';
import 'package:minas_client/widgets/custom_bottom_navigation.dart';
import 'package:minas_client/models/membership_model.dart';
import 'package:minas_client/services/memberships_service.dart';
import 'package:minas_client/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:minas_client/theme/theme_provider.dart';

class MembershipsPage extends StatefulWidget {
  const MembershipsPage({super.key});

  @override
  State<MembershipsPage> createState() => _MembershipsPageState();
}

class _MembershipsPageState extends State<MembershipsPage> {
  List<Membership> memberships = [];
  UserMembership? userMembership;
  int? userMembershipId;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  // Refresh data when page becomes visible
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemberships();
    });
  }

  Future<void> _loadMemberships() async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await AuthService.isLoggedIn();

      if (!isAuthenticated) {
        setState(() {
          errorMessage = 'يرجى تسجيل الدخول أولاً - Please login first';
          isLoading = false;
        });
        return;
      }

      // Load memberships directly from API - always fresh data
      final response = await MembershipsService.getMemberships();
      setState(() {
        memberships = response.memberships;
        userMembership = response.userMembership;
        userMembershipId = response.userMembershipId;
        isLoading = false;
        errorMessage = null; // Clear any previous errors
      });
    } catch (e) {
      // print('Error loading memberships: $e'); // Debug log
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.blue; // Default color
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: MinasAppBar(isDarkMode: isDarkMode, themeProvider: themeProvider),
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: QuickActionsDrawer(isDarkMode: isDarkMode),
      body: RefreshIndicator(
        onRefresh: _loadMemberships,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loading state
              if (isLoading)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode ? AppColors.primary : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'جاري التحميل... - Loading...',
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ),

              // Error state
              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? Colors.red.withOpacity(0.2)
                            : Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Memberships list
              if (!isLoading && errorMessage == null)
                ...memberships.map(
                  (membership) => _buildMembershipCard(membership),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 4, // Assuming memberships is at index 1
        onTap: (index) {
          if (index != 4) {
            BottomNavigationHelper.navigateToPage(context, index);
          }
        },
      ),
      floatingActionButton: GradientFABE(),
    );
  }

  Widget _buildMembershipCard(Membership membership) {
    final currentLocale = context.locale.languageCode;
    final membershipName = membership.name.getLocalizedName(currentLocale);
    final bgColor = _parseColor(membership.bgColor);
    final textColor = _parseColor(membership.textColor);
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    // Check if this membership is selected
    final isSelected =
        membership.isSelected ||
        (userMembershipId != null && membership.id == userMembershipId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border:
            isSelected
                ? Border.all(
                  color: isDarkMode ? AppColors.primary : Colors.blue,
                  width: 2,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          if (isSelected)
            BoxShadow(
              color: (isDarkMode ? AppColors.primary : Colors.blue).withOpacity(
                0.3,
              ),
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: Card(
        color: bgColor,
        child: Stack(
          children: [
            // Text content drives height
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment:
                    currentLocale == 'ar'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  // MINAS Logo - positioned differently for Arabic
                  if (currentLocale == 'ar')
                    Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'assets/images/minas_logo.png',
                        height: 50,
                        color: textColor,
                      ),
                    )
                  else
                    Image.asset(
                      'assets/images/minas_logo.png',
                      height: 40,
                      color: textColor,
                    ),
                  const SizedBox(height: 10),
                  // Membership name
                  if (currentLocale == 'ar')
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        membershipName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    )
                  else
                    Text(
                      membershipName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  const SizedBox(height: 20),
                  // Price range
                  // _buildPriceItem(
                  //   'min_invoice'.tr(),
                  //   '${(membership.minInvoice / 1000).toStringAsFixed(0)}K',
                  //   textColor,
                  // ),
                  // const SizedBox(height: 8),
                  // _buildPriceItem(
                  //   'max_invoice'.tr(),
                  //   '${(membership.maxInvoice / 1000).toStringAsFixed(0)}K',
                  //   textColor,
                  // ),
                  // const SizedBox(height: 16),
                  // // Features title with count
                  Row(
                    children: [
                      Text(
                        currentLocale == 'ar' ? 'المميزات' : 'Features',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${membership.features.length}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Features (show all features)
                  ...membership.features.map(
                    (feature) => _buildFeatureItem(
                      feature,
                      feature,
                      textColor,
                      membership.checkIcon,
                    ),
                  ),
                ],
              ),
            ),
            // SVG - positioned based on language
            Positioned(
              top: 0,
              left: currentLocale == 'ar' ? 0 : null, // Left for Arabic
              right: currentLocale == 'ar' ? null : 0, // Right for English
              child: Transform(
                alignment: Alignment.center,
                transform:
                    currentLocale == 'ar'
                        ? (Matrix4.identity()
                          ..scale(-1.0, 1.0)) // انعكاس للعربية
                        : Matrix4.identity(), // بدون انعكاس للإنجليزية
                child:
                    membership.memberlogo.isNotEmpty
                        ? Image.network(
                          'https://minasagency.com/storage/${membership.memberlogo}',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return SvgPicture.asset(
                              "assets/images/Ellipse_card.svg",
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                textColor.withOpacity(0.3),
                                BlendMode.srcIn,
                              ),
                            );
                          },
                        )
                        : SvgPicture.asset(
                          "assets/images/Ellipse_card.svg",
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            textColor.withOpacity(0.3),
                            BlendMode.srcIn,
                          ),
                        ),
              ),
            ),
            // Sidebar Image - positioned at the opposite side
            if (membership.sidebarImage.isNotEmpty)
              Positioned(
                top: 20,
                left:
                    currentLocale == 'ar' ? null : 20, // Right side for Arabic
                right:
                    currentLocale == 'ar' ? 20 : null, // Left side for English
                child: Image.network(
                  'https://minasagency.com/storage/${membership.sidebarImage}',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            // MINAS Logo at bottom - positioned based on language
            Positioned(
              bottom: 20,
              left: currentLocale == 'ar' ? 20 : null, // Left for Arabic
              right: currentLocale == 'ar' ? null : 20, // Right for English
              child:
                  membership.logo.isNotEmpty
                      ? Image.network(
                        'https://minasagency.com/storage/${membership.logo}',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return SvgPicture.asset(
                            "assets/images/minas_logo_v_c.svg",
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          );
                        },
                      )
                      : SvgPicture.asset(
                        "assets/images/minas_logo_v_c.svg",
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    String arabicText,
    String englishText,
    Color textColor,
    String checkIcon,
  ) {
    final currentLocale = context.locale.languageCode;
    final displayText = currentLocale == 'ar' ? arabicText : englishText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child:
                checkIcon.isNotEmpty
                    ? Image.network(
                      'https://minasagency.com/storage/$checkIcon',
                      width: 12,
                      height: 12,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.check, color: textColor, size: 12);
                      },
                    )
                    : Icon(Icons.check, color: textColor, size: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayText,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
