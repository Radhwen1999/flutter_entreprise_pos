import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceLight = Color(0xFF1A1A24);
  static const Color surfaceBorder = Color(0xFF2A2A3C);

  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5B4BD5);
  static const Color primaryLight = Color(0xFF8B7CF7);

  static const Color secondary = Color(0xFF00CEC9);
  static const Color secondaryLight = Color(0xFF55EFC4);

  static const Color accent = Color(0xFFFF7675);

  static const Color success = Color(0xFF00B894);
  static const Color successLight = Color(0xFF55EFC4);
  static const Color successBg = Color(0xFF0D2818);

  static const Color warning = Color(0xFFFDCB6E);
  static const Color warningBg = Color(0xFF2D2006);

  static const Color error = Color(0xFFFF6B6B);
  static const Color errorBg = Color(0xFF2D0D0D);

  static const Color info = Color(0xFF74B9FF);

  static const Color textPrimary = Color(0xFFF5F6FA);
  static const Color textSecondary = Color(0xFF9DA5B4);
  static const Color textTertiary = Color(0xFF636E7B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF7675), Color(0xFFFDCB6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color glassWhite = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);

  static const List<Color> chartColors = [
    primary, secondary, accent, success, info,
    Color(0xFFE17055), Color(0xFFA29BFE), Color(0xFFFD79A8),
  ];

  static const Color statusPending = warning;
  static const Color statusCompleted = success;
  static const Color statusCancelled = error;
  static const Color statusProcessing = info;

  static const Color stockHigh = success;
  static const Color stockMedium = warning;
  static const Color stockLow = error;
}