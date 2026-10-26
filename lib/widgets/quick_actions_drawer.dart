import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

class QuickActionsDrawer extends StatelessWidget {
  final bool isDarkMode;

  const QuickActionsDrawer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'minas_brand'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'quick_actions'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Actions List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildQuickActionTile(
                  context,
                  icon: 'assets/images/home_icon.svg',
                  title: 'home'.tr(),
                  subtitle: 'go_to_home'.tr(),
                  onTap: () => _navigateToRoute(context, '/home'),
                ),
                _buildQuickActionTile(
                  context,
                  icon: 'assets/images/booking_icon.svg',
                  title: 'bookings'.tr(),
                  subtitle: 'view_reservations'.tr(),
                  onTap: () => _navigateToRoute(context, '/bookings'),
                ),
                _buildQuickActionTile(
                  context,
                  icon: 'assets/images/offers_icon.svg',
                  title: 'offers'.tr(),
                  subtitle: 'view_special_offers'.tr(),
                  onTap: () => _navigateToRoute(context, '/offers'),
                ),
                _buildQuickActionTile(
                  context,
                  icon: 'assets/images/deposit_icon.svg',
                  title: 'deposit'.tr(),
                  subtitle: 'add_money_to_account'.tr(),
                  onTap: () => _navigateToRoute(context, '/form_deposit'),
                ),
                _buildQuickActionTile(
                  context,
                  icon: 'assets/images/memberships_icon.svg',
                  title: 'membership'.tr(),
                  subtitle: 'view_membership_details'.tr(),
                  onTap: () => _navigateToRoute(context, '/membership'),
                ),
                _buildQuickActionTile(
                  context,
                  icon: 'assets/images/notfication.svg',
                  title: 'notifications'.tr(),
                  subtitle: 'view_notifications'.tr(),
                  onTap: () => _navigateToRoute(context, '/notification'),
                ),
                _buildQuickActionTile(
                  context,
                  icon: 'assets/images/user.svg',
                  title: 'profile'.tr(),
                  subtitle: 'view_profile_settings'.tr(),
                  onTap: () => _navigateToRoute(context, '/profile'),
                ),
                _buildQuickActionTile(
                  context,
                  icon: 'assets/images/plus-circle-outline.svg',
                  title: 'transactions'.tr(),
                  subtitle: 'view_transaction_history'.tr(),
                  onTap: () => _navigateToRoute(context, '/transactions'),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'version'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            color: theme.colorScheme.onPrimaryContainer,
            width: 20,
            height: 20,
          ),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  void _navigateToRoute(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
}
