import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:provider/provider.dart';
import 'package:minas_client/providers/language_provider.dart';
import 'package:minas_client/providers/user_provider.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load user data from API when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDataFromAPI();
    });
  }

  Future<void> _loadUserDataFromAPI() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<UserProvider>().loadUserDataFromAPI();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_loading_profile'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showUpdateDialog() async {
    final userProvider = context.read<UserProvider>();
    final currentName = userProvider.getDisplayName();
    final currentPhone = userProvider.getDisplayPhone();
    final currentNotifyMail = userProvider.getDisplayNotifyMail();
    final currentNotifyWhatsapp = userProvider.getDisplayNotifyWhatsapp();
    final currentImage = userProvider.getDisplayProfileImage();

    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);
    bool notifyMail = currentNotifyMail;
    bool notifyWhatsapp = currentNotifyWhatsapp;
    String? selectedImagePath;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('update_profile'.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Image Section
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final ImageSource? source =
                            await showDialog<ImageSource>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('select_image_source'.tr()),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: Text('camera'.tr()),
                                        onTap:
                                            () => Navigator.of(
                                              context,
                                            ).pop(ImageSource.camera),
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.photo_library,
                                        ),
                                        title: Text('gallery'.tr()),
                                        onTap:
                                            () => Navigator.of(
                                              context,
                                            ).pop(ImageSource.gallery),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                        if (source != null) {
                          try {
                            final XFile? image = await picker.pickImage(
                              source: source,
                              maxWidth: 512,
                              maxHeight: 512,
                              imageQuality: 80,
                            );

                            if (image != null) {
                              setState(() {
                                selectedImagePath = image.path;
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('error_picking_image'.tr()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                selectedImagePath != null
                                    ? FileImage(File(selectedImagePath!))
                                    : _getProfileImageProvider(currentImage),
                            child:
                                selectedImagePath == null &&
                                        (currentImage == null ||
                                            currentImage.isEmpty)
                                    ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'tap_to_change_image'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'name'.tr(),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'phone'.tr(),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('email_notifications'.tr()),
                      value: notifyMail,
                      onChanged: (value) {
                        setState(() {
                          notifyMail = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text('whatsapp_notifications'.tr()),
                      value: notifyWhatsapp,
                      onChanged: (value) {
                        setState(() {
                          notifyWhatsapp = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('cancel'.tr()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('update'.tr()),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      await _updateProfile(
        name: nameController.text,
        phone: phoneController.text,
        notifyMail: notifyMail,
        notifyWhatsapp: notifyWhatsapp,
        imagePath: selectedImagePath,
      );
    }
  }

  Future<void> _updateProfile({
    required String name,
    required String phone,
    required bool notifyMail,
    required bool notifyWhatsapp,
    String? imagePath,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // إذا تم اختيار صورة جديدة، قم بتحديثها محلياً أولاً
      if (imagePath != null) {
        context.read<UserProvider>().updateProfileImage(imagePath);
        await AuthService.updateProfileImage(imagePath);
      }

      final success = await context.read<UserProvider>().updatePersonalInfo(
        name: name,
        phone: phone,
        notifyMail: notifyMail,
        notifyWhatsapp: notifyWhatsapp,
        image: imagePath,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('profile_updated_successfully'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('error_updating_profile'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_updating_profile'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('logout'.tr()),
          content: Text('logout_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('logout'.tr()),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Clear user data from provider
      context.read<UserProvider>().clearUserData();

      // Perform logout
      final success = await AuthService.logout();

      if (success && context.mounted) {
        // Navigate to login page and clear all previous routes
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('logout_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Get appropriate image provider for profile image
  ImageProvider _getProfileImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage("assets/images/user.svg");
    }

    // Check if it's a URL (starts with http)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }

    // Check if it's a local file path
    if (File(imagePath).existsSync()) {
      return FileImage(File(imagePath));
    }

    // Fallback to default image
    return const AssetImage("assets/images/user.svg");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          'profile'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon:
                _isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                    : Icon(
                      Icons.refresh,
                      color:
                          isDarkMode
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                    ),
            onPressed: _isLoading ? null : _loadUserDataFromAPI,
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
            ),
            onPressed: _isLoading ? null : _showUpdateDialog,
          ),
        ],
      ),
      body: Consumer2<LanguageProvider, UserProvider>(
        builder: (context, languageProvider, userProvider, _) {
          final userName = userProvider.getDisplayName();
          final userEmail = userProvider.getDisplayEmail();
          final userPhone = userProvider.getDisplayPhone();
          final userProfileImage = userProvider.getDisplayProfileImage();
          final userBalance = userProvider.getDisplayBalance();
          final userCountry = userProvider.getDisplayCountry();
          final notifyMail = userProvider.getDisplayNotifyMail();
          final notifyWhatsapp = userProvider.getDisplayNotifyWhatsapp();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: app_colors.primary, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    backgroundImage: _getProfileImageProvider(userProfileImage),
                    child:
                        userProfileImage == null || userProfileImage.isEmpty
                            ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userPhone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: app_colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: app_colors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: isDarkMode ? Colors.white : app_colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${userBalance.toStringAsFixed(2)} EGP',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withOpacity(
                                    0.1,
                                  ),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildProfileInfo(
                                  context,
                                  icon: Icons.person,
                                  title: 'name'.tr(),
                                  value: userName,
                                  iconColor:
                                      isDarkMode
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                ),
                                _buildProfileInfo(
                                  context,
                                  icon: Icons.email,
                                  title: 'email'.tr(),
                                  value:
                                      userEmail.isNotEmpty
                                          ? userEmail
                                          : 'user@example.com',
                                  iconColor:
                                      isDarkMode
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                ),
                                _buildProfileInfo(
                                  context,
                                  icon: Icons.phone,
                                  title: 'phone'.tr(),
                                  value: userPhone,
                                  iconColor:
                                      isDarkMode
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                ),
                                _buildProfileInfo(
                                  context,
                                  icon: Icons.account_balance_wallet,
                                  title: 'balance'.tr(),
                                  value:
                                      '${userBalance.toStringAsFixed(2)} EGP',
                                  iconColor:
                                      isDarkMode
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                ),
                                _buildProfileInfo(
                                  context,
                                  icon: Icons.public,
                                  title: 'country'.tr(),
                                  value:
                                      userCountry.isNotEmpty
                                          ? userCountry
                                          : 'N/A',
                                  iconColor:
                                      isDarkMode
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                ),
                                _buildProfileInfo(
                                  context,
                                  icon: Icons.email,
                                  title: 'email_notifications'.tr(),
                                  value:
                                      notifyMail
                                          ? 'enabled'.tr()
                                          : 'disabled'.tr(),
                                  iconColor:
                                      isDarkMode
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                ),
                                _buildProfileInfo(
                                  context,
                                  icon: Icons.chat,
                                  title: 'whatsapp_notifications'.tr(),
                                  value:
                                      notifyWhatsapp
                                          ? 'enabled'.tr()
                                          : 'disabled'.tr(),
                                  iconColor:
                                      isDarkMode
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.settings,
                        title: 'settings'.tr(),
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                      ),
                      const Divider(),
                      _buildSettingsTile(
                        context,
                        icon: Icons.logout,
                        title: 'logout'.tr(),
                        onTap: () => _handleLogout(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Language and Theme Options
                _buildLanguageOption(context),
                const SizedBox(height: 16),
                _buildThemeOption(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                iconColor ??
                (isDarkMode ? Colors.white : theme.colorScheme.primary),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDarkMode ? Colors.white : theme.colorScheme.onSurfaceVariant,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageOption(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final currentLanguage = languageProvider.currentLanguageCode;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'language_settings'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'current_language'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    currentLanguage == 'ar' ? 'العربية' : 'English',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await languageProvider.changeLanguageByCode('en');
                        if (context.mounted) {
                          context.setLocale(languageProvider.currentLocale);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            currentLanguage == 'en'
                                ? (isDarkMode
                                    ? AppColors.primary
                                    : app_colors.primary)
                                : theme.colorScheme.surface,
                        foregroundColor:
                            currentLanguage == 'en'
                                ? theme.colorScheme.onPrimary
                                : (isDarkMode
                                    ? Colors.white
                                    : theme.colorScheme.onSurfaceVariant),
                      ),
                      child: Text('switch_to_english'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await languageProvider.changeLanguageByCode('ar');
                        if (context.mounted) {
                          context.setLocale(languageProvider.currentLocale);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            currentLanguage == 'ar'
                                ? (isDarkMode
                                    ? AppColors.primary
                                    : theme.colorScheme.primary)
                                : theme.colorScheme.surface,
                        foregroundColor:
                            currentLanguage == 'ar'
                                ? theme.colorScheme.onPrimary
                                : (isDarkMode
                                    ? Colors.white
                                    : theme.colorScheme.onSurfaceVariant),
                      ),
                      child: Text('switch_to_arabic'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'theme_settings'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'current_theme'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    _getThemeModeText(themeProvider.themeMode),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildThemeOptionTile(
                      context,
                      title: 'light_theme'.tr(),
                      icon: Icons.light_mode,
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemeOptionTile(
                      context,
                      title: 'dark_theme'.tr(),
                      icon: Icons.dark_mode,
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemeOptionTile(
                      context,
                      title: 'system_theme'.tr(),
                      icon: Icons.brightness_auto,
                      isSelected: themeProvider.themeMode == ThemeMode.system,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? (isDarkMode ? Colors.white : theme.colorScheme.primary)
                      : (isDarkMode
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light_theme'.tr();
      case ThemeMode.dark:
        return 'dark_theme'.tr();
      case ThemeMode.system:
        return 'system_theme'.tr();
    }
  }
}
