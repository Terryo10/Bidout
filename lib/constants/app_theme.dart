import 'package:flutter/material.dart';

class AppTheme {
  // Colors from backend
  static const Color primaryColor = Color(0xFF0D5152); // Dark teal
  static const Color accentColor = Color(0xFFF27457); // Orange
  static const Color lightBgColor = Color(0xFFF2FAFA); // Light background
  static const Color darkBgColor = Color(0xFF272626); // Dark background
  static const Color softTextColor = Color(0xFF898D96); // Soft text
  static const Color paleTextColor = Color(0xFFC4C4C4); // Pale text
  static const Color darkSoftTextColor = Color(0xFFA0CDCD); // Dark soft text

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: lightBgColor,
      surface: lightBgColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: primaryColor,
      onSurface: primaryColor,
    ),
    scaffoldBackgroundColor: lightBgColor,
    appBarTheme: AppBarTheme(
      backgroundColor: lightBgColor,
      foregroundColor: primaryColor,
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: primaryColor),
      displayMedium: TextStyle(color: primaryColor),
      displaySmall: TextStyle(color: primaryColor),
      headlineMedium: TextStyle(color: primaryColor),
      headlineSmall: TextStyle(color: primaryColor),
      titleLarge: TextStyle(color: primaryColor),
      bodyLarge: TextStyle(color: primaryColor),
      bodyMedium: TextStyle(color: softTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      background: darkBgColor,
      surface: darkBgColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: lightBgColor,
      onSurface: lightBgColor,
    ),
    scaffoldBackgroundColor: darkBgColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBgColor,
      foregroundColor: lightBgColor,
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: lightBgColor),
      displayMedium: TextStyle(color: lightBgColor),
      displaySmall: TextStyle(color: lightBgColor),
      headlineMedium: TextStyle(color: lightBgColor),
      headlineSmall: TextStyle(color: lightBgColor),
      titleLarge: TextStyle(color: lightBgColor),
      bodyLarge: TextStyle(color: lightBgColor),
      bodyMedium: TextStyle(color: darkSoftTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}
