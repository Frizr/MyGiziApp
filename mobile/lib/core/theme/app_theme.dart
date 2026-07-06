import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primary = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF00A87A);
  static const Color secondary = Color(0xFF6C63FF);
  static const Color background = Color(0xFF0F1923);
  static const Color surface = Color(0xFF1A2535);
  static const Color surfaceElevated = Color(0xFF243044);
  static const Color onSurface = Color(0xFFF0F4F8);
  static const Color onSurfaceMuted = Color(0xFF8899AA);
  static const Color error = Color(0xFFFF5F6D);

  // Macro Colors
  static const Color calorieColor = Color(0xFFFF9500);
  static const Color proteinColor = Color(0xFF00C896);
  static const Color carbsColor = Color(0xFF6C63FF);
  static const Color fatColor = Color(0xFFFF5F6D);
  static const Color fiberColor = Color(0xFF26E5B0);
  static const Color sugarColor = Color(0xFFFFCC02);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: onSurface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
    );
  }
}
