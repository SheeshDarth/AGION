import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';
import '../system/system_text.dart';

class LevelUpOverlay extends StatefulWidget {
  final int newLevel;
  final String rank;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.rank,
    required this.onDismiss,
  });

  static OverlayEntry show(BuildContext context, int level, String rank) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => LevelUpOverlay(
        newLevel: level,
        rank: rank,
        onDismiss: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _ringController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  bool _showTap = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: 300.ms)..forward();

    _ringController = AnimationController(vsync: this, duration: 600.ms);
    Future.delayed(300.ms, () { if (mounted) _ringController.forward(); });

    _textController = AnimationController(vsync: this, duration: 280.ms);
    Future.delayed(600.ms, () { if (mounted) _textController.forward(); });

    _particleController = AnimationController(vsync: this, duration: 900.ms);
    Future.delayed(1000.ms, () { if (mounted) _particleController.forward(); });

    _pulseController = AnimationController(vsync: this, duration: 800.ms);
    Future.delayed(2200.ms, () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
        setState(() => _showTap = true);
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _ringController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = SLColors.rankColor(widget.rank);
    return GestureDetector(
      onTap: widget.onDismiss,
      child: AnimatedBuilder(
        animation: _bgController,
        builder: (_, child) => Opacity(
          opacity: _bgController.value * 0.88,
          child: child,
        ),
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ring
              AnimatedBuilder(
                animation: _ringController,
                builder: (_, __) {
                  return CustomPaint(
                    size: Size(MediaQuery.of(context).size.width * 2.5, MediaQuery.of(context).size.width * 2.5),
                    painter: _EnergyRingPainter(
                      progress: Curves.easeOut.transform(_ringController.value),
                    ),
                  );
                },
              ),
              // Particles
              if (_particleController.isAnimating || _particleController.isCompleted)
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (_, __) => CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                    painter: _BurstParticlePainter(progress: _particleController.value),
                  ),
                ),
              // Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SLText(
                    'LEVEL UP',
                    style: SLType.headline(size: 48, color: SLColors.textBright, spacing: 8),
                    glowColor: SLColors.glowCore,
                    glowRadius: 20,
                    align: TextAlign.center,
                  )
                  .animate(controller: _textController)
                    .fade(duration: 280.ms)
                    .scale(begin: const Offset(0.85, 0.85), duration: 280.ms, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  SLText(
                    '${widget.newLevel}',
                    style: SLType.display(size: 96, color: rankColor),
                    glowColor: rankColor,
                    glowRadius: 24,
                    align: TextAlign.center,
                  )
                  .animate(delay: 280.ms, controller: _textController)
                    .fade(duration: 400.ms)
                    .scale(begin: const Offset(2.0, 2.0), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 8),
                  SLText(
                    'RANK: ${widget.rank}',
                    style: SLType.questTitle(size: 18, color: rankColor),
                    align: TextAlign.center,
                  )
                  .animate(delay: 1800.ms)
                    .fade(duration: 300.ms),
                  const SizedBox(height: 32),
                  if (_showTap)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Opacity(
                        opacity: 0.4 + 0.6 * _pulseController.value,
                        child: SLText(
                          'TAP TO CONTINUE',
                          style: SLType.sysLabel(size: 11, color: SLColors.textMid),
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnergyRingPainter extends CustomPainter {
  final double progress;
  const _EnergyRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final radius = maxRadius * progress;
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = SLColors.glowCore.withOpacity((1.0 - progress) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12),
    );
  }

  @override
  bool shouldRepaint(_EnergyRingPainter old) => old.progress != progress;
}

class _BurstParticlePainter extends CustomPainter {
  final double progress;
  const _BurstParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rand = math.Random(42);
    for (int i = 0; i < 24; i++) {
      final angle = (i / 24) * 2 * math.pi;
      final speed = 80 + rand.nextDouble() * 120;
      final radius = speed * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final color = i % 2 == 0 ? SLColors.glowCore : SLColors.xpBright;
      canvas.drawCircle(
        Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle)),
        2.5,
        Paint()..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstParticlePainter old) => old.progress != progress;
}
