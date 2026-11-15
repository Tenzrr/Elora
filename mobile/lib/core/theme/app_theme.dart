import 'package:flutter/material.dart';

/// Shared visual foundation for every feature slice.
class EloraColors {
  static const deepGreen = Color(0xFF173B2B);
  static const leafGreen = Color(0xFF4F8A5B);
  static const navigation = Color(0xFF1E4D3B);
  static const mint = Color(0xFFA6E3C3);
  static const cream = Color(0xFFF8F6EF);
  static const ink = Color(0xFF1B241E);
  static const muted = Color(0xFF58645C);
  static const danger = Color(0xFFB34D45);
}

class EloraTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: EloraColors.leafGreen,
      brightness: Brightness.light,
      surface: EloraColors.cream,
      onSurface: EloraColors.ink,
      onSurfaceVariant: EloraColors.muted,
      primary: EloraColors.deepGreen,
      onPrimary: Colors.white,
      primaryContainer: EloraColors.mint,
      onPrimaryContainer: EloraColors.deepGreen,
      error: EloraColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: EloraColors.cream,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: EloraColors.cream,
        foregroundColor: EloraColors.ink,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
