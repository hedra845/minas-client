import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:minas_client/widgets/custom_text_feild.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('please_fill_all_fields'.tr())));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('https://minasagency.com/api/login');

      final resp = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'MINAS-Client/1.0',
            },
            body: jsonEncode({'login': login, 'password': password}),
          )
          .timeout(Duration(seconds: 30));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        String? token;
        Map<String, dynamic>? userData;
        try {
          final body = jsonDecode(resp.body);
          if (body is Map<String, dynamic>) {
            userData = body;
            token = (body['token'] ?? body['access_token']) as String?;
            if (token == null && body['data'] is Map) {
              final data = body['data'] as Map;
              token = (data['token'] ?? data['access_token']) as String?;
            }
          }
        } catch (_) {}

        if (token != null && token.isNotEmpty) {
          // Ensure email is included in user data from login field
          if (userData != null) {
            // If email is not in response, use the login field value
            if (userData['email'] == null || userData['email'].isEmpty) {
              userData['email'] = login; // Use login field as email
            }
          } else {
            // Create user data if not provided
            userData = {'email': login};
          }

          // Save login session using AuthService
          final success = await AuthService.saveLoginSession(
            token: token,
            userData: userData,
          );

          if (success) {
            // Update user provider with user data
            context.read<UserProvider>().updateUserData(userData);

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('success'.tr())));
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('login_failed'.tr())));
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('login_failed'.tr())));
        }
      } else {
        String message = 'error'.tr();
        try {
          final body = jsonDecode(resp.body);
          if (body is Map) {
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Top bar with language toggle
              Row(children: [const Spacer(), _languageButton(theme)]),
              // Logo
              Image.asset(
                'assets/images/logo_minas.png',
                width: 170,
                height: 100,
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'text_login'.tr(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 30),
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
                  // Login Field (email/phone)
                  CustomTextField(
                    hint: 'email_hint'.tr(),
                    isPassword: false,
                    controller: _loginController,
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
                    hint: '********',
                    isPassword: true,
                    controller: _passwordController,
                    onTap: () {},
                  ),
                ],
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
                  onPressed: _isLoading ? null : _performLogin,
                  child: Text(
                    _isLoading ? 'loading'.tr() : 'sign_in'.tr(),
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
                    'dont_have_account'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to signup
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'sign_up'.tr(),
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
