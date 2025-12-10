// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1A2E40); // Bleu nuit
  static const Color accentBlue = Color(0xFF3B82F6); // Bleu vif
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  // === THÈME CLAIR "BLEU NUIT" (STABILISÉ) ===
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: backgroundLight,
    primaryColor: primaryBlue,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryBlue, // Le bleu nuit est la couleur d'action
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: primaryBlue,
      subtitleTextStyle: TextStyle(color: Colors.black54),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryBlue,
    ),
  );

  // === THÈME SOMBRE "BLEU VIF" (STABILISÉ) ===
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: accentBlue,
    colorScheme: const ColorScheme.dark(
      primary: accentBlue,
      secondary: accentBlue,
      surface: cardDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cardDark, 
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentBlue,
      foregroundColor: Colors.white,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: accentBlue,
      subtitleTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentBlue,
    ),
  );
}
