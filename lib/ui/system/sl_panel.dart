import 'package:flutter/material.dart';
import '../../core/sl/sl_colors.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — SLPanel: The Solo Leveling Panel Component
//
// Exact replication of the panel style from the reference image:
//   - Sharp 90° corners (NO border radius)
//   - Dim 1px border on all edges
//   - BRIGHT corner brackets (L-shapes at each corner)
//   - Outer glow (bloom shadow)
//   - Optional title box on top-center border
//
// Usage:
//   SLPanel(child: ...) — plain panel
//   SLPanel(title: 'STATUS', child: ...) — with title header
//   SLPanel(glowColor: SLColors.rankS, ...) — colored variant
// ═══════════════════════════════════════════════════════════════

class SLPanel extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final Color? glowColor;
  final double glowIntensity; // 0.0 – 1.0
  final Color? fillColor;
  final VoidCallback? onTap;

  const SLPanel({
    super.key,
    required this.child,
    this.title,
    this.padding,
    this.width,
    this.height,
    this.glowColor,
    this.glowIntensity = 0.5,
    this.fillColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final glow  = glowColor ?? SLColors.glowCore;
    final fill  = fillColor ?? SLColors.panelDeep;
    final inner = Stack(
      clipBehavior: Clip.none,
      children: [
        // Panel body
        CustomPaint(
          painter: _PanelPainter(
            borderColor: glow.withOpacity(0.30 + 0.35 * glowIntensity),
            bracketColor: glow.withOpacity(0.75 + 0.25 * glowIntensity),
            bloomColor: glow.withOpacity(0.10 * glowIntensity),
            fillColor: fill,
          ),
          child: Container(
            width: width,
            height: height,
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
        // Title header box (floats ON the top border)
        if (title != null)
          Positioned(
            top: -1,
            left: 0, right: 0,
            child: Center(child: _TitleBox(title: title!, glowColor: glow)),
          ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: inner);
    }
    return inner;
  }
}

// ── Title Box ────────────────────────────────────────────────────
class _TitleBox extends StatelessWidget {
  final String title;
  final Color glowColor;
  const _TitleBox({required this.title, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: SLColors.panelMid,
        border: Border.all(color: glowColor.withOpacity(0.7), width: 1),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: SLColors.textBright,
          letterSpacing: 6.0,
          shadows: [
            Shadow(color: glowColor.withOpacity(0.8), blurRadius: 8),
            Shadow(color: glowColor.withOpacity(0.4), blurRadius: 16),
          ],
        ),
      ),
    );
  }
}

// ── Inner Section Divider ────────────────────────────────────────
/// Use this to separate HP bars section from stats section, etc.
class SLDivider extends StatelessWidget {
  final Color? color;
  const SLDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: (color ?? SLColors.panelLine),
    );
  }
}

/// A sub-panel — the inner darker rectangle used for HP bars and stat groups
class SLSubPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;

  const SLSubPanel({super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SLColors.panelMid,
        border: Border.all(
          color: (borderColor ?? SLColors.glowDim).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ── Panel Painter ────────────────────────────────────────────────
class _PanelPainter extends CustomPainter {
  final Color borderColor, bracketColor, bloomColor, fillColor;
  static const double _bracket = 18.0; // arm length
  static const double _bracketW = 1.5; // arm width

  const _PanelPainter({
    required this.borderColor,
    required this.bracketColor,
    required this.bloomColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // Fill
    canvas.drawRect(rect, Paint()..color = fillColor);

    // Outer bloom (glow shadow drawn as a blurred rect)
    canvas.drawRect(
      rect.inflate(2),
      Paint()
        ..color = bloomColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 20),
    );

    // Dim perimeter border
    canvas.drawRect(rect, Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0);

    // ── Corner brackets (bright) ─────────────────────────────────
    final bp = Paint()
      ..color = bracketColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _bracketW
      ..strokeCap = StrokeCap.square;

    // TOP-LEFT
    canvas.drawLine(const Offset(0, _bracket), const Offset(0, 0), bp);
    canvas.drawLine(const Offset(0, 0), const Offset(_bracket, 0), bp);
    // TOP-RIGHT
    canvas.drawLine(Offset(w - _bracket, 0), Offset(w, 0), bp);
    canvas.drawLine(Offset(w, 0), Offset(w, _bracket), bp);
    // BOTTOM-LEFT
    canvas.drawLine(Offset(0, h - _bracket), Offset(0, h), bp);
    canvas.drawLine(Offset(0, h), Offset(_bracket, h), bp);
    // BOTTOM-RIGHT
    canvas.drawLine(Offset(w - _bracket, h), Offset(w, h), bp);
    canvas.drawLine(Offset(w, h), Offset(w, h - _bracket), bp);
  }

  @override
  bool shouldRepaint(_PanelPainter old) =>
    old.borderColor != borderColor ||
    old.bracketColor != bracketColor;
}
