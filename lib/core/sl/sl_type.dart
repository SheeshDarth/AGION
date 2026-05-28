import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sl_colors.dart';

// ═══════════════════════════════════════════════════════════════
// AGION Typography System — Solo Leveling Canonical
//
// Three-tier hierarchy:
//   Orbitron  → Level numbers, rank letters, HUD values, titles
//   Rajdhani  → Stat labels, descriptions, body text
//   Exo 2     → Small system labels, bar values, timestamps
//
// RULE: No TextStyle is constructed anywhere else in the codebase.
//       Every text style comes from a static method here.
// ═══════════════════════════════════════════════════════════════

List<Shadow> _orbitronGlow(Color c) => [
  Shadow(color: c.withOpacity(0.70), blurRadius: 8),
  Shadow(color: c.withOpacity(0.35), blurRadius: 18),
];

List<Shadow> _softGlow(Color c) => [
  Shadow(color: c.withOpacity(0.50), blurRadius: 6),
];

abstract class SLType {

  // ── ORBITRON — System / HUD ───────────────────────────────────

  /// Dominant level number. 64sp, bold, full glow.
  static TextStyle levelNum({double size = 64, Color? color}) {
    final c = color ?? SLColors.textBright;
    return GoogleFonts.orbitron(
      fontSize: size, fontWeight: FontWeight.w600,
      color: c, letterSpacing: 2.0, height: 1.0,
      shadows: _orbitronGlow(SLColors.glowCore));
  }

  /// Screen / panel titles.
  static TextStyle screenTitle({double size = 14, Color? color}) {
    final c = color ?? SLColors.textBright;
    return GoogleFonts.orbitron(
      fontSize: size, fontWeight: FontWeight.w500,
      color: c, letterSpacing: 6.0,
      shadows: _softGlow(SLColors.glowCore));
  }

  /// Stat values in profile/HUD (e.g. "48").
  static TextStyle statValue({double size = 18, Color? color}) {
    final c = color ?? SLColors.textBright;
    return GoogleFonts.orbitron(
      fontSize: size, fontWeight: FontWeight.w600,
      color: c, letterSpacing: 1.0,
      shadows: _softGlow(c));
  }

  /// Tiny system label in Orbitron.
  static TextStyle subLabel({double size = 10, Color? color}) =>
    GoogleFonts.orbitron(
      fontSize: size, fontWeight: FontWeight.w500,
      color: color ?? SLColors.textMid, letterSpacing: 3.0);

  // ── RAJDHANI — Content ────────────────────────────────────────

  /// Stat row labels (STR:, AGI:, etc.)
  static TextStyle statLabel({double size = 13, Color? color}) =>
    GoogleFonts.rajdhani(
      fontSize: size, fontWeight: FontWeight.w600,
      color: color ?? SLColors.textMid, letterSpacing: 2.5);

  /// Job/title lines in profile.
  static TextStyle jobTitle({double size = 14, Color? color}) =>
    GoogleFonts.rajdhani(
      fontSize: size, fontWeight: FontWeight.w600,
      color: color ?? SLColors.textBright, letterSpacing: 0.8);

  // ── EXO 2 — Micro ─────────────────────────────────────────────

  /// Bar value text ("2220/2220"), timestamps.
  static TextStyle barValue({double size = 9, Color? color}) =>
    GoogleFonts.exo2(
      fontSize: size, fontWeight: FontWeight.w400,
      color: color ?? SLColors.textMid, letterSpacing: 0.3);

  /// Extra-small system labels.
  static TextStyle micro({double size = 8, Color? color}) =>
    GoogleFonts.exo2(
      fontSize: size, fontWeight: FontWeight.w400,
      color: color ?? SLColors.textDim, letterSpacing: 0.5);

  // ── LEGACY METHODS (kept for backward compatibility) ──────────
  // All screens use these — do not remove.

  static TextStyle display({double size = 64, Color? color, double spacing = 4}) {
    final c = color ?? SLColors.textBright;
    return GoogleFonts.orbitron(
      fontSize: size, fontWeight: FontWeight.w700,
      color: c, letterSpacing: spacing, height: 1.0,
      shadows: _orbitronGlow(SLColors.glowCore));
  }

  static TextStyle headline({double size = 28, Color? color, double spacing = 3}) {
    final c = color ?? SLColors.textBright;
    return GoogleFonts.orbitron(
      fontSize: size, fontWeight: FontWeight.w600,
      color: c, letterSpacing: spacing,
      shadows: _softGlow(SLColors.glowCore));
  }

  static TextStyle hudNum({double size = 22, Color? color, double spacing = 2}) {
    final c = color ?? SLColors.glowCore;
    return GoogleFonts.orbitron(
      fontSize: size, fontWeight: FontWeight.w400,
      color: c, letterSpacing: spacing,
      shadows: _softGlow(c));
  }

  static TextStyle sysLabel({double size = 10, Color? color, double spacing = 3.5}) =>
    GoogleFonts.orbitron(
      fontSize: size, fontWeight: FontWeight.w500,
      color: color ?? SLColors.textMid, letterSpacing: spacing);

  static TextStyle questTitle({double size = 16, Color? color}) =>
    GoogleFonts.rajdhani(
      fontSize: size, fontWeight: FontWeight.w600,
      color: color ?? SLColors.textBright, letterSpacing: 1.2);

  static TextStyle body({double size = 14, Color? color}) =>
    GoogleFonts.rajdhani(
      fontSize: size, fontWeight: FontWeight.w400,
      color: color ?? SLColors.textMid, letterSpacing: 0.5);

  static TextStyle tag({double size = 11, Color? color, double spacing = 2.5}) =>
    GoogleFonts.rajdhani(
      fontSize: size, fontWeight: FontWeight.w600,
      color: color ?? SLColors.glowCore, letterSpacing: spacing);
}
