import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Beige color palette
  static const Color primaryBeige = Color(0xFFE8DCC4);
  static const Color lightBeige = Color(0xFFF5EFE6);
  static const Color darkBeige = Color(0xFFD4C5A9);
  static const Color accent = Color(0xFF7C6A46);

  // Text colors
  static const Color _lightTextColor = Color(0xFF2D2D2D);
  static const Color _darkTextColor = Color(0xFFF5F5F5);

  // Background colors
  static const Color _lightBackground = Color(0xFFFAF9F6);
  static const Color _darkBackground = Color(0xFF2D2D2D);

  static final TextTheme _baseTextTheme = TextTheme(
    displayLarge: GoogleFonts.crimsonText(
      fontSize: 96,
      fontWeight: FontWeight.w300,
    ),
    displayMedium: GoogleFonts.crimsonText(
      fontSize: 60,
      fontWeight: FontWeight.w300,
    ),
    displaySmall: GoogleFonts.crimsonText(
      fontSize: 48,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.crimsonText(
      fontSize: 34,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: GoogleFonts.crimsonText(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: GoogleFonts.crimsonText(
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.crimsonText(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.crimsonText(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryBeige,
      onPrimary: _lightTextColor,
      secondary: accent,
      onSecondary: Colors.white,
      surface: lightBeige,
      error: Colors.red.shade400,
    ),
    textTheme: _baseTextTheme.apply(
      bodyColor: _lightTextColor,
      displayColor: _lightTextColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBeige,
      foregroundColor: _lightTextColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.crimsonText(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: _lightTextColor,
      ),
    ),
    cardTheme: const CardThemeData(
      color: lightBeige,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBeige,
        foregroundColor: _lightTextColor,
        textStyle: GoogleFonts.crimsonText(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: lightBeige,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accent),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: darkBeige,
      onPrimary: _darkTextColor,
      secondary: accent,
      onSecondary: Colors.white,
      surface: const Color(0xFF3D3D3D),
      error: Colors.red.shade300,
    ),
    textTheme: _baseTextTheme.apply(
      bodyColor: _darkTextColor,
      displayColor: _darkTextColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkTextColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.crimsonText(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: _darkTextColor,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF3D3D3D),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkBeige,
        foregroundColor: _darkTextColor,
        textStyle: GoogleFonts.crimsonText(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF3D3D3D),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accent),
      ),
    ),
  );
}
