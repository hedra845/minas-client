import 'package:flutter/material.dart';
import 'package:minas_client/Reservations.dart';
import 'package:minas_client/form_deposit_money.dart';
import 'package:minas_client/memberships_page.dart';
import 'package:minas_client/notifications_page.dart';
import 'package:minas_client/transactions_page.dart';
import 'package:minas_client/login_page.dart';
import 'package:minas_client/offers.dart';
import 'package:minas_client/profile.dart';
import 'package:minas_client/register.dart';
import 'package:minas_client/splash_screen.dart';
import 'package:minas_client/home_page.dart';
import 'package:minas_client/settings_page.dart';
import 'package:minas_client/example_theme_usage.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get device locale
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

  // Check if device locale is supported (Arabic or English)
  Locale initialLocale;
  if (deviceLocale.languageCode == 'ar') {
    initialLocale = const Locale('ar');
  } else {
    initialLocale = const Locale('en');
  }

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: initialLocale, // Set initial locale based on device
      child: MyApp(deviceLocale: initialLocale),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Locale deviceLocale;

  const MyApp({super.key, required this.deviceLocale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(deviceLocale: deviceLocale),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          // Listen to language changes and update the app locale
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.locale != languageProvider.currentLocale) {
              context.setLocale(languageProvider.currentLocale);
            }
          });

          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: languageProvider.currentLocale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            builder: (context, child) {
              return SafeArea(child: child ?? const SizedBox.shrink());
            },
            routes: {
              '/home': (context) => const TravelHomePage(),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/profile': (context) => ProfilePage(),
              '/offers': (context) => OffersPage(),
              '/transactions': (context) => TransactionsPage(),
              '/notifications': (context) => NotificationsPage(),
              '/bookings': (context) => BookingsPage(),
              '/membership': (context) => MembershipsPage(),
              '/form_deposit': (context) => DepositScreen(),
              '/settings': (context) => const SettingsPage(),
              '/theme-example': (context) => const ExampleThemeUsage(),
            },
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
