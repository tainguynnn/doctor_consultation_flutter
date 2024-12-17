import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2194F3);
  static const Color lighterPrimaryColor = Color(0xFF6eC4FF);
  static const Color darkerPrimaryColor = Color(0xFF0067C0);

  static const Color secondaryColor = Color(0xFF5EFC8D);
  static const Color lighterSecondaryColor = Color(0xFF98FFBE);
  static const Color darkerSecondaryColor = Color(0xFF00BDAD);

  static const Color warningColor = Color(0xFFF27F21);
  static const Color dangerColor = Color(0xFFA30000);

  // This use for PDFColor
  static const int primaryInt = 0xFF2194F3;

  static ThemeData themeData = ThemeData(
    primaryColor: AppTheme.primaryColor,
    colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryColor),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: false,
  );
}
