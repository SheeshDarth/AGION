import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Animated XP ring with gradient arc stroke and inner level display.
///
/// Uses CustomPainter for the ring and an implicit animation for smooth
/// value transitions (600ms, cubic-bezier(.22,.9,.07,1)).
class XpRingWidget extends StatefulWidget {
  final double progress; // 0.0 – 1.0
  final int level;
  final String rank;
  final String xpText;
  final double size;
  final VoidCallback? onTap;

  const XpRingWidget({
    super.key,
    required this.progress,
    required this.level,
    required this.rank,
    required this.xpText,
    this.size = 220,
    this.onTap,
  });

  @override
  State<XpRingWidget> createState() => _XpRingWidgetState();
}

class _XpRingWidgetState extends State<XpRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldProgress = 0.0;

  // Custom easing: cubic-bezier(.22,.9,.07,1)
  static const Cubic _xpCurve = Cubic(0.22, 0.9, 0.07, 1.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: _xpCurve),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(XpRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = oldWidget.progress;
      _animation = Tween<double>(begin: _oldProgress, end: widget.progress)
          .animate(CurvedAnimation(parent: _controller, curve: _xpCurve));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _XpRingPainter(progress: _animation.value),
              child: child,
            );
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rank badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AgionSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AgionColors.accentGradient,
                    borderRadius: BorderRadius.circular(AgionRadius.small),
                  ),
                  child: Text(
                    'RANK ${widget.rank}',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AgionColors.backgroundDeep,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: AgionSpacing.xs),
                // Level
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AgionColors.accentGradient.createShader(bounds),
                  child: Text(
                    'LV ${widget.level}',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: AgionSpacing.xs),
                // XP text
                Text(
                  widget.xpText,
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AgionColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── CUSTOM PAINTER ────────────────────────────────────────────────────────

class _XpRingPainter extends CustomPainter {
  final double progress;

  _XpRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const strokeWidth = 6.0;
    const trackStrokeWidth = 3.0;

    // Track (background ring)
    final trackPaint = Paint()
      ..color = AgionColors.white06
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Outer glow ring (subtle)
    final glowPaint = Paint()
      ..color = AgionColors.neonCyan.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sweepAngle = 2 * math.pi * progress;
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // Progress arc with gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: const [
          AgionColors.neonCyan,
          AgionColors.neonViolet,
          AgionColors.neonCyan,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // End-cap glow dot
      final endAngle = -math.pi / 2 + sweepAngle;
      final glowDotCenter = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );
      final dotGlow = Paint()
        ..color = AgionColors.neonCyan.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(glowDotCenter, 4, dotGlow);
      canvas.drawCircle(
        glowDotCenter,
        3,
        Paint()..color = AgionColors.neonCyan,
      );
    }
  }

  @override
  bool shouldRepaint(_XpRingPainter old) => old.progress != progress;
}
