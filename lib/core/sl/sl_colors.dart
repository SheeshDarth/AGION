import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — Solo Leveling Color System (Canonical)
// Source: UI.zip reference spec (CLAUDE.md)
//
// RULE: This is the ONLY place hex values exist in this codebase.
//       Every widget reads from SLColors. No exceptions.
//
// NAMING: Canonical names (voidBg, glowCore, etc.) match the
//         reference spec exactly. Legacy aliases (void_, cyan, etc.)
//         are kept for backward compatibility — do not add new code
//         using the legacy names.
// ═══════════════════════════════════════════════════════════════

abstract class SLColors {
  // ── BACKGROUND LAYERS ────────────────────────────────────────
  /// True AMOLED base — dark navy void behind everything.
  static const Color voidBg     = Color(0xFF030810);
  /// Outer panel fill — what panels sit on.
  static const Color panelDeep  = Color(0xFF060E1C);
  /// Inner panel fill — stat boxes, HP bars, sub-sections.
  static const Color panelMid   = Color(0xFF091525);
  /// Separator line color between panel sections.
  static const Color panelLine  = Color(0xFF0D1E30);

  // ── GLOW / BORDER SYSTEM ─────────────────────────────────────
  /// Primary border & corner bracket glow — slightly warm cyan.
  static const Color glowCore   = Color(0xFF7EC8E3);
  /// Dimmed border — inactive edges, panel midlines.
  static const Color glowDim    = Color(0xFF2A5A72);
  /// Outer bloom shadow — the soft halo around panels.
  static const Color glowBloom  = Color(0xFF4A9BB5);

  // ── RANK COLORS (EXACT Solo Leveling palette) ─────────────────
  static const Color rankE      = Color(0xFF8A9BA8); // grey-blue
  static const Color rankD      = Color(0xFF4CAF82); // muted green
  static const Color rankC      = Color(0xFF5B9BD5); // system blue
  static const Color rankB      = Color(0xFF9B6DC9); // purple
  static const Color rankA      = Color(0xFFD4A843); // gold
  static const Color rankS      = Color(0xFFE8603A); // ember

  // ── STAT BAR FILLS ────────────────────────────────────────────
  static const Color hpDark     = Color(0xFF8B2020);
  static const Color hpBright   = Color(0xFFC94040);
  static const Color mpDark     = Color(0xFF1A4A8B);
  static const Color mpBright   = Color(0xFF3A7BD5);
  static const Color xpDark     = Color(0xFF7A5A10);
  static const Color xpBright   = Color(0xFFC8A43A);

  // ── SEMANTIC ──────────────────────────────────────────────────
  static const Color danger     = Color(0xFFD94050);
  static const Color success    = Color(0xFF3AC890);
  static const Color warning    = Color(0xFFC8A43A); // same as xpBright

  // ── TYPOGRAPHY ────────────────────────────────────────────────
  /// Primary HUD text — near-white, slightly cool.
  static const Color textBright = Color(0xFFE8F4FF);
  /// Secondary labels — muted system blue.
  static const Color textMid    = Color(0xFF6A8FA8);
  /// Ghost / placeholder — barely visible.
  static const Color textDim    = Color(0xFF2A4055);

  // ── HELPERS ───────────────────────────────────────────────────
  static Color rankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'S': return rankS;
      case 'A': return rankA;
      case 'B': return rankB;
      case 'C': return rankC;
      case 'D': return rankD;
      default:  return rankE;
    }
  }

  static List<Color> hpGradient  = [hpDark, hpBright];
  static List<Color> mpGradient  = [mpDark, mpBright];
  static List<Color> xpGradient  = [xpDark, xpBright];

  // ── BACKWARD-COMPATIBLE ALIASES ───────────────────────────────
  // Legacy names kept so existing code compiles unchanged.
  // New code must use canonical names above.
  static const Color void_      = voidBg;
  static const Color abyss      = panelDeep;
  static const Color surface    = panelMid;
  static const Color glassWhite = Color(0x0DFFFFFF); // used in sl_theme.dart
  static const Color cyan       = glowCore;
  static const Color cyanDim    = glowDim;
  static const Color holoPure   = textBright;
  static const Color textPrime  = textBright;
  static const Color textMuted  = textMid;
  static const Color textGhost  = textDim;
  static const Color xpGold     = xpBright;

  // 3-color list kept for xp_ring.dart SweepGradient(stops: [0,0.6,1.0])
  static const List<Color> xpRingGradient = [xpDark, xpBright, glowCore];
  // bgGradient removed — SLBg handles background internally
}
