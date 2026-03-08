import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AgionTheme {
  AgionTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AgionColors.backgroundDeep,
      colorScheme: const ColorScheme.dark(
        primary: AgionColors.neonCyan,
        secondary: AgionColors.neonViolet,
        surface: AgionColors.backgroundDeep,
        error: AgionColors.danger,
        onPrimary: AgionColors.backgroundDeep,
        onSecondary: AgionColors.white,
        onSurface: AgionColors.white,
        onError: AgionColors.white,
      ),
      textTheme: _textTheme,
      cardTheme: CardThemeData(
        color: AgionColors.cardGlass,
        shape: RoundedRectangleBorder(
          borderRadius: AgionRadius.cardBR,
          side: const BorderSide(color: AgionColors.cardGlassBorder),
        ),
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _orbitron(20, FontWeight.w700, AgionColors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AgionColors.backgroundDeep,
        selectedItemColor: AgionColors.neonCyan,
        unselectedItemColor: AgionColors.mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(
        color: AgionColors.neonCyan,
        size: 24,
      ),
    );
  }

  // ─── TEXT THEME ───────────────────────────────────────────────────────
  static TextTheme get _textTheme {
    return TextTheme(
      // Display / Titles — Orbitron
      displayLarge: _orbitron(48, FontWeight.w700, AgionColors.white),
      displayMedium: _orbitron(36, FontWeight.w700, AgionColors.white),
      displaySmall: _orbitron(28, FontWeight.w700, AgionColors.white),
      headlineLarge: _orbitron(24, FontWeight.w700, AgionColors.white),
      headlineMedium: _orbitron(20, FontWeight.w500, AgionColors.white),
      headlineSmall: _orbitron(18, FontWeight.w500, AgionColors.white),

      // Body — Rajdhani
      titleLarge: _rajdhani(22, FontWeight.w600, AgionColors.white),
      titleMedium: _rajdhani(18, FontWeight.w600, AgionColors.white),
      titleSmall: _rajdhani(16, FontWeight.w600, AgionColors.mutedText),
      bodyLarge: _rajdhani(18, FontWeight.w400, AgionColors.white),
      bodyMedium: _rajdhani(16, FontWeight.w400, AgionColors.white),
      bodySmall: _rajdhani(14, FontWeight.w400, AgionColors.mutedText),

      // Labels — Inter
      labelLarge: _inter(14, FontWeight.w600, AgionColors.white),
      labelMedium: _inter(12, FontWeight.w500, AgionColors.mutedText),
      labelSmall: _inter(11, FontWeight.w500, AgionColors.mutedText),
    );
  }

  static TextStyle _orbitron(double size, FontWeight weight, Color color) {
    return GoogleFonts.orbitron(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 1.2,
    );
  }

  static TextStyle _rajdhani(double size, FontWeight weight, Color color) {
    return GoogleFonts.rajdhani(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle _inter(double size, FontWeight weight, Color color) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}
