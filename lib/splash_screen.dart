import 'package:flutter/material.dart';
import 'dart:async';

import 'package:minas_client/login_page.dart';
import 'package:minas_client/home_page.dart';
import 'package:minas_client/services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _logoOffsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Check login status and navigate after 4 seconds
    Timer(const Duration(seconds: 4), () {
      _checkLoginStatusAndNavigate();
    });
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    try {
      if (!mounted) return;

      // فحص حالة تسجيل الدخول باستخدام AuthService
      final isLoggedIn = await AuthService.isLoggedIn();

      if (isLoggedIn) {
        // المستخدم مسجل دخول، انتقل للصفحة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TravelHomePage()),
        );
      } else {
        // المستخدم غير مسجل دخول، انتقل لصفحة تسجيل الدخول
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      // في حالة حدوث خطأ، انتقل لصفحة تسجيل الدخول
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/images/splach_screen.jpg', fit: BoxFit.cover),

          // Overlay + logo
          Container(
            color: theme.colorScheme.primary.withOpacity(
              0.3,
            ), // Optional overlay
            child: Center(
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _logoOffsetAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // شعار ميتناس
                      Image.asset(
                        'assets/images/minas_logo.png', // تأكد من وضع الشعار الأبيض هنا
                        width: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'welcome'.tr(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Text(
          "الصفحة الرئيسية",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
