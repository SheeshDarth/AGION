import 'package:flutter/material.dart';

// ─── COLORS ────────────────────────────────────────────────────────────────
class AgionColors {
  AgionColors._();

  static const Color backgroundDeep = Color(0xFF020513);
  static const Color cardGlass = Color.fromRGBO(255, 255, 255, 0.04);
  static const Color cardGlassBorder = Color.fromRGBO(255, 255, 255, 0.04);
  static const Color neonCyan = Color(0xFF00F6FF);
  static const Color neonViolet = Color(0xFF7F5CFF);
  static const Color mutedText = Color(0xFF8FA3C7);
  static const Color danger = Color(0xFFFF5C6C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white10 = Color.fromRGBO(255, 255, 255, 0.10);
  static const Color white03 = Color.fromRGBO(255, 255, 255, 0.03);
  static const Color white06 = Color.fromRGBO(255, 255, 255, 0.06);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [neonCyan, neonViolet],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradientVertical = LinearGradient(
    colors: [neonCyan, neonViolet],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ─── SPACING (4pt base) ────────────────────────────────────────────────────
class AgionSpacing {
  AgionSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

// ─── BORDER RADIUS ─────────────────────────────────────────────────────────
class AgionRadius {
  AgionRadius._();

  static const double small = 8;
  static const double card = 16;
  static const double large = 24;

  static final BorderRadius smallBR = BorderRadius.circular(small);
  static final BorderRadius cardBR = BorderRadius.circular(card);
  static final BorderRadius largeBR = BorderRadius.circular(large);
}

// ─── SHADOWS / GLOW ────────────────────────────────────────────────────────
class AgionShadows {
  AgionShadows._();

  static final List<BoxShadow> neonGlow = [
    BoxShadow(
      color: AgionColors.neonCyan.withValues(alpha: 0.06),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AgionColors.neonViolet.withValues(alpha: 0.06),
      blurRadius: 18,
    ),
  ];

  static final List<BoxShadow> neonGlowStrong = [
    BoxShadow(
      color: AgionColors.neonCyan.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AgionColors.neonViolet.withValues(alpha: 0.15),
      blurRadius: 18,
    ),
  ];
}

// ─── XP FORMULAS ───────────────────────────────────────────────────────────
class XpConfig {
  XpConfig._();

  static const int baseXp = 100;
  static const int xpGrowth = 50;

  /// XP required to advance from level [n] to level [n+1].
  static int xpForLevel(int n) => baseXp + (n - 1) * xpGrowth;

  // XP awards per action
  static const int workoutXp = 50;
  static const int waterGoalXp = 20;
  static const int stepGoalXp = 30;
  static const int dietGoalXp = 25;
  static const int focusXp = 30;
  static const int disciplineXp = 20;
}

// ─── RANKS ─────────────────────────────────────────────────────────────────
class RankConfig {
  RankConfig._();

  static const Map<String, int> rankThresholds = {
    'E': 1,
    'D': 5,
    'C': 10,
    'B': 20,
    'A': 35,
    'S': 50,
  };

  static const List<String> rankOrder = ['E', 'D', 'C', 'B', 'A', 'S'];

  /// Returns the rank string for the given [level].
  static String rankForLevel(int level) {
    String rank = 'E';
    for (final entry in rankThresholds.entries) {
      if (level >= entry.value) rank = entry.key;
    }
    return rank;
  }
}

// ─── QUICK ACTIONS ─────────────────────────────────────────────────────────
enum QuickAction {
  workout('WORKOUT', '⚔️', XpConfig.workoutXp),
  water('WATER', '💧', XpConfig.waterGoalXp),
  steps('STEPS', '👟', XpConfig.stepGoalXp),
  diet('DIET', '🍛', XpConfig.dietGoalXp),
  focus('FOCUS', '🎯', XpConfig.focusXp),
  discipline('DISCIPLINE', '🛡️', XpConfig.disciplineXp);

  const QuickAction(this.label, this.icon, this.xpReward);
  final String label;
  final String icon;
  final int xpReward;
}
