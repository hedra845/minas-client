import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';

    return BottomNavigationBar(
      onTap: onTap,
      currentIndex: currentIndex,
      backgroundColor: theme.colorScheme.surface,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.secondary,
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/home_icon.svg',
            color:
                currentIndex == 0
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
          ),
          label: 'home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/booking_icon.svg',
            color:
                currentIndex == 1
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
          ),
          label: 'bookings'.tr(),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/offers_icon.svg',
            color:
                currentIndex == 2
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
          ),
          label: 'offers'.tr(),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/deposit_icon.svg',
            color:
                currentIndex == 3
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
          ),
          label: 'deposit'.tr(),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/memberships_icon.svg',
            color:
                currentIndex == 4
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
          ),
          label: 'membership'.tr(),
        ),
      ],
    );
  }
}

// Helper class for navigation logic
class BottomNavigationHelper {
  static void navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/bookings');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/offers');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/transactions');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/membership');
        break;
    }
  }
}
