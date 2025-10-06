import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const darkGreen = Color(0xFF064E3B);  // เขียวเข้ม
  static const lightGreen = Color(0xFF10B981); // เขียวอ่อน
  static const white = Color(0xFFFFFFFF);      // ขาว
  static const black = Color(0xFF000000);      // ดำ

  // Accent Colors
  static const errorRed = Color(0xFFE53935);
  static const successGreen = Color(0xFF43A047);
  static const warningAmber = Color(0xFFFFA000);
  
  // Admin Dashboard Colors
  static const lightBlue = Color(0xFF3B82F6);
  static const lightOrange = Color(0xFFF97316);
  static const lightPurple = Color(0xFF8B5CF6);

  // Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: black,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: black,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: black,
  );

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    primaryColor: darkGreen,
    scaffoldBackgroundColor: white,
    colorScheme: ColorScheme.light(
      primary: darkGreen,
      secondary: lightGreen,
      error: errorRed,
      background: white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkGreen,
      foregroundColor: white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkGreen,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightGreen),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}