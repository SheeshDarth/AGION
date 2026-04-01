import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/audio_service.dart';
import '../../core/ai_guide_voice.dart';

/// Full-screen level-up cinematic overlay.
/// Call [LevelUpCinematic.show] from anywhere in the widget tree.
class LevelUpCinematic extends StatefulWidget {
  final int newLevel;
  final String rank;
  final bool isRankUp;
  final String? previousRank;

  const LevelUpCinematic({
    super.key,
    required this.newLevel,
    required this.rank,
    this.isRankUp = false,
    this.previousRank,
  });

  static Future<void> show(
    BuildContext context, {
    required int newLevel,
    required String rank,
    bool isRankUp = false,
    String? previousRank,
  }) async {
    // Play audio
    if (isRankUp) {
      await AudioService.instance.playRankUp();
      await AiGuideVoice.instance.announceRankUp(rank);
    } else {
      await AudioService.instance.playLevelUp();
      await AiGuideVoice.instance.announceLevelUp(newLevel);
    }

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => LevelUpCinematic(
        newLevel: newLevel,
        rank: rank,
        isRankUp: isRankUp,
        previousRank: previousRank,
      ),
    );
  }

  @override
  State<LevelUpCinematic> createState() => _LevelUpCinematicState();
}

class _LevelUpCinematicState extends State<LevelUpCinematic>
    with TickerProviderStateMixin {
  late AnimationController _shockwaveController;
  late AnimationController _particleController;
  late AnimationController _rotateController;
  late AnimationController _autoClose;

  @override
  void initState() {
    super.initState();
    _shockwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _autoClose = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward().then((_) {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      });
  }

  @override
  void dispose() {
    _shockwaveController.dispose();
    _particleController.dispose();
    _rotateController.dispose();
    _autoClose.dispose();
    super.dispose();
  }

  Color get _accentColor =>
      widget.isRankUp ? _rankColor(widget.rank) : AgionColors.neonCyan;

  Color _rankColor(String rank) {
    switch (rank) {
      case 'S':
        return Colors.red.shade400;
      case 'A':
        return Colors.orange.shade400;
      case 'B':
        return AgionColors.neonViolet;
      case 'C':
        return AgionColors.neonCyan;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).pop(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Particle burst
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _LevelUpParticlePainter(
                _particleController.value,
                _accentColor,
                widget.isRankUp,
              ),
            ),
          ),

          // Shockwave rings
          AnimatedBuilder(
            animation: _shockwaveController,
            builder: (_, __) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(3, (i) {
                  final delay = i * 0.2;
                  final progress =
                      (_shockwaveController.value - delay).clamp(0.0, 1.0);
                  final radius = progress * 200.0;
                  return Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _accentColor
                            .withValues(alpha: (1.0 - progress) * 0.4),
                        width: 2.0,
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // Rotating outer ring
          AnimatedBuilder(
            animation: _rotateController,
            builder: (_, child) => Transform.rotate(
              angle: _rotateController.value * 2 * math.pi,
              child: child,
            ),
            child: SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _RotatingRingPainter(_accentColor),
              ),
            ),
          ),

          // Central content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top label
              Text(
                widget.isRankUp ? 'RANK UP!' : 'LEVEL UP!',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _accentColor,
                  letterSpacing: 6,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.5, end: 0.0, duration: 300.ms),

              const SizedBox(height: AgionSpacing.md),

              // Rank badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accentColor, width: 2),
                  gradient: RadialGradient(
                    colors: [
                      _accentColor.withValues(alpha: 0.2),
                      AgionColors.backgroundDeep.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: widget.isRankUp
                      ? Text(
                          widget.rank,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: _accentColor,
                          ),
                        )
                      : Text(
                          '${widget.newLevel}',
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: AgionColors.white,
                          ),
                        ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    delay: 200.ms,
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(delay: 200.ms, duration: 300.ms),

              const SizedBox(height: AgionSpacing.lg),

              // Title
              ShaderMask(
                shaderCallback: (bounds) =>
                    AgionColors.accentGradient.createShader(bounds),
                child: Text(
                  widget.isRankUp
                      ? '${widget.rank}-RANK ACHIEVED'
                      : 'LEVEL ${widget.newLevel}',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0.0, delay: 500.ms, duration: 400.ms),

              const SizedBox(height: AgionSpacing.sm),

              // Subtitle
              if (widget.isRankUp && widget.previousRank != null)
                Text(
                  '${widget.previousRank}-Rank → ${widget.rank}-Rank',
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AgionColors.mutedText,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

              const SizedBox(height: AgionSpacing.xl),

              // Tap to continue
              const Text(
                'TAP TO CONTINUE',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  color: AgionColors.mutedText,
                  letterSpacing: 3,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(delay: 1200.ms, duration: 500.ms)
                  .then()
                  .fadeOut(duration: 500.ms),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── PAINTERS ────────────────────────────────────────────────────────────────

class _LevelUpParticlePainter extends CustomPainter {
  final double time;
  final Color color;
  final bool isRankUp;
  static final _rng = math.Random(99);
  static final _particles = List.generate(
    80,
    (i) => (
      angle: _rng.nextDouble() * 2 * math.pi,
      speed: 0.03 + _rng.nextDouble() * 0.15,
      size: 1.5 + _rng.nextDouble() * 3.0,
      phase: _rng.nextDouble(),
    ),
  );

  _LevelUpParticlePainter(this.time, this.color, this.isRankUp);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(
            size.width * size.width + size.height * size.height) /
        2;

    for (final p in _particles) {
      final t = ((time + p.phase) % 1.0);
      final r = t * maxRadius * p.speed * 10;
      final alpha = (1.0 - t).clamp(0.0, 1.0);
      if (alpha < 0.05) continue;

      final x = center.dx + r * math.cos(p.angle);
      final y = center.dy + r * math.sin(p.angle);

      canvas.drawCircle(
        Offset(x, y),
        p.size * (1.0 - t * 0.5),
        Paint()
          ..color = color.withValues(alpha: alpha * 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_LevelUpParticlePainter old) => old.time != time;
}

class _RotatingRingPainter extends CustomPainter {
  final Color color;
  _RotatingRingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dashCount = 24;
    const dashLength = math.pi / 36;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (2 * math.pi * i / dashCount);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RotatingRingPainter old) => false;
}
