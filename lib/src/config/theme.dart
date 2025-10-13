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

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryBeige,
      onPrimary: _lightTextColor,
      secondary: accent,
      onSecondary: Colors.white,
      surface: lightBeige,
      error: Colors.red.shade400,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.crimsonText(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        color: _lightTextColor,
      ),
      displayMedium: GoogleFonts.crimsonText(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        color: _lightTextColor,
      ),
      displaySmall: GoogleFonts.crimsonText(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: _lightTextColor,
      ),
      headlineMedium: GoogleFonts.crimsonText(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: _lightTextColor,
      ),
      headlineSmall: GoogleFonts.crimsonText(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: _lightTextColor,
      ),
      titleLarge: GoogleFonts.crimsonText(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: _lightTextColor,
      ),
      bodyLarge: GoogleFonts.crimsonText(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _lightTextColor,
      ),
      bodyMedium: GoogleFonts.crimsonText(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _lightTextColor,
      ),
    ),

    // AppBar Theme
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

    // Card Theme
    cardTheme: CardThemeData(
      color: lightBeige,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Button Themes
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

    // Input Decoration Theme
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

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: darkBeige,
      onPrimary: _darkTextColor,
      secondary: accent,
      onSecondary: Colors.white,
      surface: Color(0xFF3D3D3D),
      error: Colors.red.shade300,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.crimsonText(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        color: _darkTextColor,
      ),
      displayMedium: GoogleFonts.crimsonText(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        color: _darkTextColor,
      ),
      displaySmall: GoogleFonts.crimsonText(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: _darkTextColor,
      ),
      headlineMedium: GoogleFonts.crimsonText(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: _darkTextColor,
      ),
      headlineSmall: GoogleFonts.crimsonText(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: _darkTextColor,
      ),
      titleLarge: GoogleFonts.crimsonText(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: _darkTextColor,
      ),
      bodyLarge: GoogleFonts.crimsonText(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _darkTextColor,
      ),
      bodyMedium: GoogleFonts.crimsonText(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _darkTextColor,
      ),
    ),

    // AppBar Theme
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

    // Card Theme
    cardTheme: CardThemeData(
      color: Color(0xFF3D3D3D),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Button Themes
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

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Color(0xFF3D3D3D),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accent),
      ),
    ),
  );
}
