import 'package:flutter/material.dart';
import '../../core/sl/sl_colors.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — SLStatRow: The Stat Display Widget
//
// Replicates the "STR: 48" style from the reference image:
//   [icon]  LABEL:  VALUE
//
// Icon is tinted with SLColors.glowCore.
// Label uses Rajdhani, W600, textMid, wide spacing.
// Value uses Orbitron, W600, textBright, with subtle glow.
// ═══════════════════════════════════════════════════════════════

class SLStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color? valueColor; // override for special stats
  final bool isHighlighted; // larger value for "Available Points"

  const SLStatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final vc = valueColor ?? SLColors.textBright;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        Icon(icon, size: 18, color: SLColors.glowCore.withOpacity(0.85)),
        const SizedBox(width: 6),
        // Label
        Text(
          '${label.toUpperCase()}:',
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: isHighlighted ? 11 : 13,
            fontWeight: FontWeight.w600,
            color: SLColors.textMid,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(width: 8),
        // Value
        Text(
          '$value',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: isHighlighted ? 22 : 18,
            fontWeight: FontWeight.w600,
            color: vc,
            letterSpacing: 1.0,
            shadows: [
              Shadow(color: vc.withOpacity(0.7), blurRadius: 8),
              Shadow(color: vc.withOpacity(0.3), blurRadius: 16),
            ],
          ),
        ),
      ],
    );
  }
}

/// 2-column grid of stat rows — matches the reference image layout exactly.
/// [STR, AGI, PER] on left, [VIT, INT] on right.
class SLStatGrid extends StatelessWidget {
  final int str, agi, per, vit, int_, availPoints;

  const SLStatGrid({
    super.key,
    required this.str,
    required this.agi,
    required this.per,
    required this.vit,
    required this.int_,
    this.availPoints = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SLStatRow(icon: Icons.fitness_center, label: 'STR', value: str),
              const SizedBox(height: 10),
              SLStatRow(icon: Icons.directions_run, label: 'AGI', value: agi),
              const SizedBox(height: 10),
              SLStatRow(icon: Icons.remove_red_eye_outlined, label: 'PER', value: per),
            ],
          ),
        ),
        // Right column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SLStatRow(icon: Icons.favorite_border, label: 'VIT', value: vit),
              const SizedBox(height: 10),
              SLStatRow(icon: Icons.psychology_outlined, label: 'INT', value: int_),
              const SizedBox(height: 10),
              // Available Ability Points — bottom right, larger value
              if (availPoints > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVAILABLE\nABILITY POINTS',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 9,
                        color: SLColors.textMid.withOpacity(0.7),
                        letterSpacing: 1.5,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$availPoints',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: SLColors.glowCore,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: SLColors.glowCore.withOpacity(0.8),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
