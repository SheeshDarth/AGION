import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sl_colors.dart';
import 'sl_type.dart';

ThemeData buildSLTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SLColors.voidBg,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    textTheme: TextTheme(
      displayLarge:  SLType.display(),
      headlineLarge: SLType.headline(),
      bodyLarge:     SLType.body(size: 16),
      bodyMedium:    SLType.body(),
      labelSmall:    SLType.sysLabel(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SLColors.glassWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: SLColors.glowDim.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: SLColors.glowDim.withValues(alpha: 0.3)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: SLColors.glowCore, width: 1.5),
      ),
      hintStyle: SLType.body(color: SLColors.textGhost),
      labelStyle: SLType.sysLabel(),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    colorScheme: const ColorScheme.dark(
      primary: SLColors.glowCore,
      secondary: SLColors.glowDim,
      surface: SLColors.panelMid,
      error: SLColors.danger,
    ),
  );
}
