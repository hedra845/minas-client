import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF03003E);
  static const Color secondary = Color(0xFF455EC3);
  static const Color third = Color(0xFF33BAE0);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightDivider = Color(0xFFECECEC);
  static const Color lightInputFill = Color(0xFFFAFAFA);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x1A000000);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkDivider = Color(0xFF404040);
  static const Color darkInputFill = Color(0xFF2A2A2A);
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkShadow = Color(0x40000000);

  // Common Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static LinearGradient get darkPrimaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );
}

// Legacy support - keeping the old class name for backward compatibility
class app_colors {
  // Primary Colors
  static const Color primary = Color(0xFF03003E);
  static const Color secondary = Color(0xFF455EC3);
  static const Color third = Color(0xFF33BAE0);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightDivider = Color(0xFFECECEC);
  static const Color lightInputFill = Color(0xFFFAFAFA);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x1A000000);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkDivider = Color(0xFF404040);
  static const Color darkInputFill = Color(0xFF2A2A2A);
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkShadow = Color(0x40000000);

  // Common Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Additional legacy properties that existing code expects
  static const Color fill_input_color = Color(0xFFF5F5F5);
  static const Color divider_color = Color(0xFFE0E0E0);

  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static LinearGradient get darkPrimaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );
}
