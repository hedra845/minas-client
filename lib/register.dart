import 'package:flutter/material.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/widgets/custom_text_feild.dart';
import 'package:minas_client/widgets/text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'services/auth_service.dart';
import 'dart:convert';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _phoneCountryCode = '';

  // Extra fields required by API
  bool _notifyMail = true;
  bool _notifyWhatsapp = true;
  String _userType = 'customer'; // allowed: customer, agent, company

  bool _isLoading = false;

  void _toggleLanguage() {
    final next =
        context.locale.languageCode == 'ar'
            ? const Locale('en')
            : const Locale('ar');
    context.read<LanguageProvider>().changeLanguage(next);
    context.setLocale(next);
  }

  Widget _languageButton(ThemeData theme) {
    final isArabic = context.locale.languageCode == 'ar';
    return TextButton(
      onPressed: _toggleLanguage,
      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface),
      child: Text(isArabic ? 'EN' : 'AR'),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String passwordConfirmation = _confirmPasswordController.text;
    final String phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('please_fill_all_fields'.tr())));
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('password_too_short'.tr())));
      return;
    }

    if (password != passwordConfirmation) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('passwords_do_not_match'.tr())));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('https://minasagency.com/api/signup');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'MINAS-Client/1.0',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
              'phone': '$_phoneCountryCode$phone',
              'notify_mail': _notifyMail,
              'notify_whatsapp': _notifyWhatsapp,
              'user_type': _userType, // customer | agent | company
            }),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        // Try to auto-login if token is returned
        final String? token =
            (data['token'] ?? data['access_token']) as String?;
        Map<String, dynamic> userData = {
          'name': data['name'] ?? name,
          'email': data['email'] ?? email,
          'phone': data['phone'] ?? '$_phoneCountryCode$phone',
          'profile_image': data['avatar'] ?? '',
        };

        if (token != null && token.isNotEmpty) {
          final saved = await AuthService.saveLoginSession(
            token: token,
            userData: userData,
          );
          if (saved) {
            if (!mounted) return;
            context.read<UserProvider>().updateUserData(userData);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('success'.tr())));
            Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
            return;
          }
        }

        // Fallback: show message and go to login if no token returned
        final message =
            (data is Map && data['message'] is String)
                ? data['message']
                : 'success'.tr();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pushNamed(context, '/login');
      } else {
        String message = 'signup_failed'.tr();
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          // Check for message key first
          if (body['message'] is String) {
            message = body['message'];
          }
          // Also check for other common error keys
          else if (body['error'] is String) {
            message = body['error'];
          } else if (body['errors'] is Map) {
            // Handle validation errors
            final errors = body['errors'] as Map;
            if (errors.isNotEmpty) {
              message = errors.values.first.toString();
            }
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'network_error'.tr();

      // Provide more specific error messages
      if (e.toString().contains('SocketException')) {
        errorMessage = 'no_internet_connection'.tr();
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'connection_timeout'.tr();
      } else if (e.toString().contains('HandshakeException')) {
        errorMessage = 'ssl_error'.tr();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;
    // ignore: unused_local_variable
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo_minas.png',
                    width: 100,
                    height: 100,
                  ),
                  _languageButton(theme),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'create_account'.tr(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'name'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  SizedBox(height: 5),
                  // Name Field
                  buildTextField(
                    'name_hint'.tr(),
                    _nameController,
                    false,
                    null,
                    null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'email'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  SizedBox(height: 5),
                  // Email Field
                  buildTextField(
                    'email_hint_register'.tr(),
                    _emailController,
                    false,
                    null,
                    null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'phone'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  SizedBox(height: 5),
                  // International Phone Field
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IntlPhoneField(
                      controller: _phoneController,
                      textAlign: TextAlign.right,
                      initialCountryCode: 'EG',
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        border: InputBorder.none,
                        fillColor: AppColors.darkTextSecondary.withOpacity(
                          0.05,
                        ),
                        filled: true,
                        counterText: '',
                      ),
                      onChanged: (phone) {
                        _phoneCountryCode = phone.countryCode;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'password'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  SizedBox(height: 5),
                  // Password Field
                  CustomTextField(
                    hint: 'password_hint'.tr(),
                    isPassword: true,
                    controller: _passwordController,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'confirm_password'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  SizedBox(height: 5),
                  // Password Confirmation Field
                  CustomTextField(
                    hint: 'confirm_password_hint'.tr(),
                    isPassword: true,
                    controller: _confirmPasswordController,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // User type
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'user_type'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: _userType,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface,
                          width: 2,
                        ),
                      ),
                      border: InputBorder.none,
                      fillColor: AppColors.darkTextSecondary.withOpacity(0.05),
                      filled: true,
                      counterText: '',
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'customer',
                        child: Text('Customer'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'agent',
                        child: Text('Agent'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'company',
                        child: Text('Company'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _userType = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Notify switches
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _notifyMail,
                title: Text('notify_mail'.tr()),
                onChanged: (v) => setState(() => _notifyMail = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _notifyWhatsapp,
                title: Text('notify_whatsapp'.tr()),
                onChanged: (v) => setState(() => _notifyWhatsapp = v),
              ),
              const SizedBox(height: 30),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _signup,
                  child: Text(
                    _isLoading ? 'loading'.tr() : 'sign_up_button'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 30),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'dont_have_account_register'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to signup
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'sign_in_link'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
