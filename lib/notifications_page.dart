import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:minas_client/widgets/quick_actions_drawer.dart';
import 'package:minas_client/models/notification_model.dart';
import 'package:minas_client/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await NotificationService.getNotifications();

      if (mounted) {
        setState(() {
          _notifications = response?.notifications ?? [];
          _unreadCount = response?.unreadNotifications ?? 0;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        // Handle authentication error
        if (e.toString().contains('Authentication failed')) {
          _handleAuthenticationError();
        }
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      final success = await NotificationService.sendReadNotification(
        notification.id,
      );
      if (success && mounted) {
        setState(() {
          // Update the notification in the list
          final index = _notifications.indexWhere(
            (n) => n.id == notification.id,
          );
          if (index != -1) {
            _notifications[index] = NotificationModel(
              id: notification.id,
              type: notification.type,
              notifiableType: notification.notifiableType,
              notifiableId: notification.notifiableId,
              data: notification.data,
              readAt: DateTime.now().toIso8601String(),
              createdAt: notification.createdAt,
              updatedAt: notification.updatedAt,
              notificationImage: notification.notificationImage,
            );
            _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_marking_read'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) return;

    try {
      final success = await NotificationService.markAllAsRead();
      if (success && mounted) {
        setState(() {
          // Mark all notifications as read
          _notifications =
              _notifications.map((notification) {
                return NotificationModel(
                  id: notification.id,
                  type: notification.type,
                  notifiableType: notification.notifiableType,
                  notifiableId: notification.notifiableId,
                  data: notification.data,
                  readAt:
                      notification.readAt ?? DateTime.now().toIso8601String(),
                  createdAt: notification.createdAt,
                  updatedAt: notification.updatedAt,
                  notificationImage: notification.notificationImage,
                );
              }).toList();
          _unreadCount = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('all_notifications_marked_read'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_marking_all_notifications'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAuthenticationError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('session_expired'.tr()),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'login_button'.tr(),
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _openNotificationLink(String link) async {
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('cannot_open_link'.tr()),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_opening_link'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${'days_ago'.tr()}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${'hours_ago'.tr()}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${'minutes_ago'.tr()}';
      } else {
        return 'just_now'.tr();
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: MinasAppBar(isDarkMode: isDarkMode, themeProvider: themeProvider),
      drawer: QuickActionsDrawer(isDarkMode: isDarkMode),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(isRefresh: true),
        child: Column(
          children: [
            // Header with unread count and mark all as read
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'notifications'.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      if (_unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? AppColors.darkSurface
                                    : app_colors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_unreadCount > 0) const SizedBox(width: 8),
                      if (_unreadCount > 0)
                        TextButton(
                          onPressed: _isLoading ? null : _markAllAsRead,
                          child: Text(
                            'mark_all_read'.tr(),
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? AppColors.darkSurface
                                      : app_colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(child: _buildContent(theme, isDarkMode)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadNotifications(),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'no_notifications'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'no_notifications_description'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification, theme, isDarkMode);
      },
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _markAsRead(notification);
          if (notification.data.link.isNotEmpty) {
            _openNotificationLink(notification.data.link);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child:
                    notification.fullImageUrl.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            notification.fullImageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.notifications,
                                color: AppColors.primary,
                                size: 30,
                              );
                            },
                          ),
                        )
                        : Icon(
                          Icons.notifications,
                          color: AppColors.primary,
                          size: 30,
                        ),
              ),
              const SizedBox(width: 12),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Unread Indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.data.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? AppColors.white
                                      : AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Offer Name
                    if (notification.data.offerName.isNotEmpty)
                      Text(
                        notification.data.offerName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      notification.data.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Time and Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(notification.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Row(
                          children: [
                            if (!notification.isRead)
                              TextButton(
                                onPressed: () => _markAsRead(notification),
                                child: Text(
                                  'mark_read'.tr(),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
