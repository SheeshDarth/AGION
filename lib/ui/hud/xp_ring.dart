import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';
import '../system/system_text.dart';

/// The signature XP ring widget — CustomPainter based.
class XPRing extends StatefulWidget {
  final int currentXP;
  final int xpForLevel;
  final int level;
  final String rank;

  const XPRing({
    super.key,
    required this.currentXP,
    required this.xpForLevel,
    required this.level,
    required this.rank,
  });

  @override
  State<XPRing> createState() => _XPRingState();
}

class _XPRingState extends State<XPRing> with TickerProviderStateMixin {
  late AnimationController _arcController;
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _arcAnim;
  late Animation<double> _pulseAnim;

  double _prevProgress = 0;

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(vsync: this, duration: 600.ms);
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

    _arcAnim = Tween<double>(begin: 0, end: _progress).animate(
      CurvedAnimation(parent: _arcController, curve: Curves.easeOut),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _arcController.forward();
  }

  @override
  void didUpdateWidget(XPRing old) {
    super.didUpdateWidget(old);
    if (old.currentXP != widget.currentXP || old.xpForLevel != widget.xpForLevel) {
      _arcAnim = Tween<double>(begin: _prevProgress, end: _progress).animate(
        CurvedAnimation(parent: _arcController, curve: Curves.easeOut),
      );
      _arcController.forward(from: 0);
    }
    _prevProgress = _progress;
  }

  @override
  void dispose() {
    _arcController.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double get _progress => widget.xpForLevel > 0
      ? (widget.currentXP / widget.xpForLevel).clamp(0.0, 1.0)
      : 0.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_arcAnim, _scanController, _pulseAnim]),
      builder: (_, __) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: _XPRingPainter(
                progress: _arcAnim.value,
                scanProgress: _scanController.value,
                rank: widget.rank,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SLText(
                      '${widget.level}',
                      style: SLType.display(size: 48, color: SLColors.textBright),
                      glowColor: SLColors.glowCore,
                      glowRadius: 16,
                    ),
                    const SizedBox(height: 2),
                    _RankDiamondBadge(rank: widget.rank, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _XPRingPainter extends CustomPainter {
  final double progress, scanProgress;
  final String rank;

  const _XPRingPainter({
    required this.progress,
    required this.scanProgress,
    required this.rank,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    // Track arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi, false,
      Paint()
        ..color = SLColors.textDim.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Tick marks
    final tickPaint = Paint()
      ..color = SLColors.glowDim.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + (i / 12) * 2 * math.pi;
      final inner = Offset(
        center.dx + (radius - 8) * math.cos(angle),
        center.dy + (radius - 8) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + (radius + 2) * math.cos(angle),
        center.dy + (radius + 2) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // XP progress arc gradient
    if (progress > 0) {
      final sweepAngle = progress * 2 * math.pi;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + sweepAngle,
        colors: SLColors.xpRingGradient,
        stops: const [0.0, 0.6, 1.0],
      );
      canvas.drawArc(
        rect,
        -math.pi / 2, sweepAngle, false,
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );

      // Glow on arc tip
      final tipAngle = -math.pi / 2 + sweepAngle;
      final tip = Offset(
        center.dx + radius * math.cos(tipAngle),
        center.dy + radius * math.sin(tipAngle),
      );
      canvas.drawCircle(tip, 4,
          Paint()..color = SLColors.glowCore.withValues(alpha: 0.9)
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6));
    }

    // Rotating scan line
    final scanAngle = -math.pi / 2 + scanProgress * 2 * math.pi;
    const scanSweep = math.pi * 0.3;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      scanAngle, scanSweep, false,
      Paint()
        ..color = SLColors.glowCore.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
  }

  @override
  bool shouldRepaint(_XPRingPainter old) =>
      old.progress != progress || old.scanProgress != scanProgress;
}

class _RankDiamondBadge extends StatelessWidget {
  final String rank;
  final double size;
  const _RankDiamondBadge({required this.rank, required this.size});

  @override
  Widget build(BuildContext context) {
    final color = SLColors.rankColor(rank);
    return Container(
      width: size * 1.6,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1),
        color: color.withValues(alpha: 0.08),
      ),
      child: Center(
        child: SLText(
          rank,
          style: SLType.sysLabel(size: size * 0.55, color: color),
          glowColor: color,
          glowRadius: 6,
        ),
      ),
    );
  }
}
