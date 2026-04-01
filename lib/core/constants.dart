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
// Designed for LONG-TERM progression. A daily-active user should take:
// ~2 weeks to reach Level 5, ~2 months to reach Level 15,
// ~6 months to reach Level 30, ~1+ year for Level 50+.
class XpConfig {
  XpConfig._();

  static const int baseXp = 500;      // base XP to go from L1 → L2
  static const int xpGrowthLinear = 100;  // linear growth per level
  static const double xpGrowthQuadratic = 15; // quadratic scaling

  /// XP required to advance from level [n] to level [n+1].
  /// Formula: 500 + 100*(n-1) + 15*(n-1)^2
  ///   L1→2:  500 XP  (~10 workouts)
  ///   L5→6:  1060 XP (~21 workouts)
  ///   L10→11: 1715 XP (~34 workouts)
  ///   L20→21: 5810 XP (~116 workouts)
  ///   L50→51: 38405 XP (~768 workouts)
  static int xpForLevel(int n) {
    final linear = xpGrowthLinear * (n - 1);
    final quadratic = (xpGrowthQuadratic * (n - 1) * (n - 1)).round();
    return baseXp + linear + quadratic;
  }

  // XP awards per action (daily caps enforced by streak logic)
  static const int workoutXp = 50;      // per workout session
  static const int waterGoalXp = 25;    // daily goal completion
  static const int stepGoalXp = 35;     // daily step goal
  static const int dietGoalXp = 30;     // daily diet log
  static const int focusXp = 40;        // focus session
  static const int disciplineXp = 20;   // discipline check-in
}

// ─── RANKS ─────────────────────────────────────────────────────────────────
// Spread across months/years of real progression.
class RankConfig {
  RankConfig._();

  static const Map<String, int> rankThresholds = {
    'E': 1,    // Beginner (~first week)
    'D': 8,    // ~1 month
    'C': 20,   // ~3 months
    'B': 35,   // ~6 months
    'A': 55,   // ~10 months
    'S': 75,   // ~1+ year of dedication
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
