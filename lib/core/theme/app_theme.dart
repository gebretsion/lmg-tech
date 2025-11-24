import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Define a seed color for the color scheme
  static const _seedColor = Color(0xFF0D47A1); // A deep blue

  // Define light theme colors
  static final _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
    primary: _seedColor,
    background: const Color(0xFFF7F9FC),
    surface: Colors.white,
  );

  // Define dark theme colors
  static final _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
    primary: const Color(0xFF64B5F6), // A lighter blue for dark mode
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
  );

  /// Returns the light theme data.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: _lightColorScheme.surface,
      appBarTheme: _appBarTheme(_lightColorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(_lightColorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(_lightColorScheme),
      inputDecorationTheme: _inputDecorationTheme(_lightColorScheme),
      cardTheme: _cardTheme(),
      textTheme: _textTheme(_lightColorScheme),
      useMaterial3: true,
    );
  }

  /// Returns the dark theme data.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: _darkColorScheme.surface,
      appBarTheme: _appBarTheme(_darkColorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(_darkColorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(_darkColorScheme),
      inputDecorationTheme: _inputDecorationTheme(_darkColorScheme),
      cardTheme: _cardTheme(),
      textTheme: _textTheme(_darkColorScheme),
      useMaterial3: true,
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    return GoogleFonts.poppinsTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(color: colorScheme.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}