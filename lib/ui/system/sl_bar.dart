import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/sl/sl_colors.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — SLBar: Solo Leveling Style Progress Bars
//
// Exact replication from reference image:
//   - Thin height (8px)
//   - Sharp ends (NO rounded caps)
//   - Gradient fill (dark → bright)
//   - 1px dim border around track
//   - Subtle glow on filled portion
//   - Value text right-aligned above or overlaid
//   - Icon on the left
// ═══════════════════════════════════════════════════════════════

enum SLBarType { hp, mp, xp, custom }

class SLBar extends StatelessWidget {
  final double value;        // 0.0 – 1.0
  final SLBarType type;
  final String label;        // "HP", "MP", etc.
  final String? valueText;   // "2220/2220" — shown right-aligned over bar
  final Widget? icon;        // icon widget on the left
  final List<Color>? colors; // override gradient for custom type
  final double height;

  const SLBar({
    super.key,
    required this.value,
    required this.label,
    this.type = SLBarType.hp,
    this.valueText,
    this.icon,
    this.colors,
    this.height = 8.0,
  });

  List<Color> get _gradient {
    if (colors != null) return colors!;
    switch (type) {
      case SLBarType.hp: return SLColors.hpGradient;
      case SLBarType.mp: return SLColors.mpGradient;
      case SLBarType.xp: return SLColors.xpGradient;
      case SLBarType.custom: return [SLColors.glowDim, SLColors.glowCore];
    }
  }

  Color get _glowColor => _gradient.last;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon or label
        if (icon != null) ...[
          SizedBox(width: 20, height: 20, child: icon),
          const SizedBox(width: 6),
        ] else ...[
          Text(
            label.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: SLColors.textMid,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Bar track
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Optional value text above bar (right-aligned)
              if (valueText != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    valueText!,
                    style: GoogleFonts.exo2(
                      fontSize: 9,
                      color: SLColors.textMid,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              const SizedBox(height: 2),
              // Bar itself
              CustomPaint(
                painter: _BarPainter(
                  value: value.clamp(0.0, 1.0),
                  gradient: _gradient,
                  glowColor: _glowColor,
                  barHeight: height,
                ),
                child: SizedBox(height: height),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Bar Painter ───────────────────────────────────────────────────
class _BarPainter extends CustomPainter {
  final double value;
  final List<Color> gradient;
  final Color glowColor;
  final double barHeight;

  const _BarPainter({
    required this.value,
    required this.gradient,
    required this.glowColor,
    required this.barHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackRect = Rect.fromLTWH(0, 0, size.width, barHeight);
    final fillWidth = size.width * value;
    final fillRect  = Rect.fromLTWH(0, 0, fillWidth, barHeight);

    // Track background
    canvas.drawRect(trackRect, Paint()..color = SLColors.panelMid);

    // Track border
    canvas.drawRect(trackRect, Paint()
      ..color = SLColors.glowDim.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0);

    if (value <= 0) return;

    // Fill glow behind bar
    canvas.drawRect(
      fillRect.inflate(1),
      Paint()
        ..color = glowColor.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Fill gradient
    canvas.drawRect(
      fillRect,
      Paint()
        ..shader = LinearGradient(colors: gradient)
            .createShader(trackRect),
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.value != value;
}

// ── Animated bar wrapper ──────────────────────────────────────────
/// Wraps SLBar with a smooth value animation (600ms ease-out).
class SLBarAnimated extends StatelessWidget {
  final double value;
  final SLBarType type;
  final String label;
  final String? valueText;
  final Widget? icon;

  const SLBarAnimated({
    super.key,
    required this.value,
    required this.label,
    this.type = SLBarType.hp,
    this.valueText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (_, v, __) => SLBar(
        value: v,
        type: type,
        label: label,
        valueText: valueText,
        icon: icon,
      ),
    );
  }
}
