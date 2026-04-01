import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/audio_service.dart';

/// Animated splash screen with theme music and AGION branding.
/// Auto-navigates to app after animation completes.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _ringAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _ringAnimation = CurvedAnimation(
      parent: _ringController,
      curve: const Cubic(0.16, 1, 0.3, 1),
    );
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Play opening sound + theme music
    await Future.delayed(const Duration(milliseconds: 300));
    await AudioService.instance.playAppOpen();

    await Future.delayed(const Duration(milliseconds: 100));
    _ringController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    await AudioService.instance.playThemeMusic();

    // Wait for full animation + branding display
    await Future.delayed(const Duration(milliseconds: 2800));

    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: Stack(
        children: [
          // Particle field background
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _ParticlePainter(_particleController.value),
            ),
          ),

          // Radial glow behind logo
          Center(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AgionColors.neonCyan
                          .withValues(alpha: 0.06 + 0.04 * _glowAnimation.value),
                      AgionColors.neonViolet
                          .withValues(alpha: 0.04 + 0.03 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Rotating arc ring
          Center(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => Transform.rotate(
                angle: _particleController.value * 2 * math.pi * 0.15,
                child: CustomPaint(
                  size: const Size(240, 240),
                  painter: _SplashRingPainter(_ringAnimation.value),
                ),
              ),
            ),
          ),

          // Core content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AGION logo text
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AgionColors.accentGradient.createShader(bounds),
                  child: const Text(
                    'AGION',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 12,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 800.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      delay: 600.ms,
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 8),

                const Text(
                  'PERSONAL ASCENSION SYSTEM',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AgionColors.mutedText,
                    letterSpacing: 4,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0.0, delay: 1000.ms, duration: 600.ms),

                const SizedBox(height: 48),

                // Pulsing status indicator
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (_, __) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AgionColors.neonCyan.withValues(
                            alpha: 0.4 + 0.6 * _glowAnimation.value,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AgionColors.neonCyan.withValues(
                                alpha: 0.3 * _glowAnimation.value,
                              ),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SYSTEM INITIALIZING',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: AgionColors.neonCyan.withValues(
                            alpha: 0.4 + 0.4 * _glowAnimation.value,
                          ),
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1400.ms, duration: 600.ms),
              ],
            ),
          ),

          // Version tag at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                'v1.0.0',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 12,
                  color: AgionColors.mutedText,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1600.ms, duration: 600.ms),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SPLASH RING PAINTER ────────────────────────────────────────────────────

class _SplashRingPainter extends CustomPainter {
  final double progress;
  _SplashRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AgionColors.white06
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    if (progress <= 0) return;

    // Glow ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AgionColors.neonCyan.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Primary arc
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: const [
        AgionColors.neonViolet,
        AgionColors.neonCyan,
        AgionColors.neonViolet,
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = gradient.createShader(
            Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Leading dot
    final angle = -math.pi / 2 + 2 * math.pi * progress;
    final dotX = center.dx + radius * math.cos(angle);
    final dotY = center.dy + radius * math.sin(angle);
    canvas.drawCircle(
      Offset(dotX, dotY),
      5,
      Paint()
        ..color = AgionColors.neonCyan
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset(dotX, dotY),
      3,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_SplashRingPainter old) => old.progress != progress;
}

// ─── STAR PARTICLE PAINTER ──────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double time;
  static final _rng = math.Random(42);
  static final List<_Particle> _particles = List.generate(
    60,
    (i) => _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: _rng.nextDouble() * 1.5 + 0.3,
      speed: _rng.nextDouble() * 0.008 + 0.002,
      opacity: _rng.nextDouble() * 0.5 + 0.1,
    ),
  );

  _ParticlePainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final y = ((p.y + time * p.speed) % 1.0) * size.height;
      final alpha = (p.opacity * 255 *
              (0.6 + 0.4 * math.sin(time * math.pi * 2 + p.x * 10)))
          .clamp(0, 255)
          .toInt();
      canvas.drawCircle(
        Offset(p.x * size.width, y),
        p.size,
        Paint()..color = AgionColors.neonCyan.withAlpha(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.time != time;
}

class _Particle {
  final double x, y, size, speed, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
