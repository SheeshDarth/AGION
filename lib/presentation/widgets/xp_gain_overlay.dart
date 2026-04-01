import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Animated XP gain overlay — shows "+50 XP" flying up with particle burst.
/// Call XpGainOverlay.show(context, xpAmount) after any action.
class XpGainOverlay {
  static void show(BuildContext context, int xp, {Offset? origin}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _XpGainAnimation(
        xp: xp,
        origin: origin ??
            Offset(
              MediaQuery.of(ctx).size.width / 2,
              MediaQuery.of(ctx).size.height / 2,
            ),
        onComplete: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _XpGainAnimation extends StatefulWidget {
  final int xp;
  final Offset origin;
  final VoidCallback onComplete;

  const _XpGainAnimation({
    required this.xp,
    required this.origin,
    required this.onComplete,
  });

  @override
  State<_XpGainAnimation> createState() => _XpGainAnimationState();
}

class _XpGainAnimationState extends State<_XpGainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -80),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.3)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 40),
    ]).animate(_controller);

    // Generate particles
    final rng = math.Random();
    for (int i = 0; i < 12; i++) {
      _particles.add(_Particle(
        angle: (i * math.pi * 2 / 12) + rng.nextDouble() * 0.3,
        speed: 40 + rng.nextDouble() * 60,
        size: 3 + rng.nextDouble() * 4,
        color: rng.nextBool() ? AgionColors.neonCyan : AgionColors.neonViolet,
      ));
    }

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Particles
            ..._particles.map((p) {
              final progress = _controller.value;
              final x = widget.origin.dx +
                  math.cos(p.angle) * p.speed * progress;
              final y = widget.origin.dy +
                  math.sin(p.angle) * p.speed * progress -
                  20 * progress;
              return Positioned(
                left: x - p.size / 2,
                top: y - p.size / 2,
                child: Opacity(
                  opacity: (1 - progress).clamp(0.0, 1.0),
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: p.color.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // XP text
            Positioned(
              left: widget.origin.dx - 40,
              top: widget.origin.dy + _slideAnimation.value.dy - 12,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SizedBox(
                    width: 80,
                    child: Text(
                      '+${widget.xp} XP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AgionColors.neonCyan,
                        shadows: [
                          Shadow(
                            color: AgionColors.neonCyan.withValues(alpha: 0.8),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

/// Workout completion celebration — full-screen flash + ring pulse.
class WorkoutCompleteAnimation {
  static void show(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _WorkoutCompleteCelebration(
        onComplete: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _WorkoutCompleteCelebration extends StatefulWidget {
  final VoidCallback onComplete;

  const _WorkoutCompleteCelebration({required this.onComplete});

  @override
  State<_WorkoutCompleteCelebration> createState() =>
      _WorkoutCompleteCelebrationState();
}

class _WorkoutCompleteCelebrationState
    extends State<_WorkoutCompleteCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flashAnimation;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flashAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.15), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: 0.0), weight: 80),
    ]).animate(_controller);

    _ringAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return IgnorePointer(
          child: Stack(
            children: [
              // Flash overlay
              Container(
                width: size.width,
                height: size.height,
                color: AgionColors.neonCyan
                    .withValues(alpha: _flashAnimation.value),
              ),
              // Expanding ring
              Center(
                child: Container(
                  width: 300 * _ringAnimation.value,
                  height: 300 * _ringAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AgionColors.neonCyan.withValues(
                          alpha: (1 - _ringAnimation.value).clamp(0.0, 0.6)),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
