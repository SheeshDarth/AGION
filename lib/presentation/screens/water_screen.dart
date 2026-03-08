import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../features/water/water_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/system_toast.dart';

class WaterScreen extends ConsumerStatefulWidget {
  const WaterScreen({super.key});

  @override
  ConsumerState<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends ConsumerState<WaterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(waterProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final waterLog = ref.watch(waterProvider);
    final progress = ref.watch(waterProgressProvider);
    final goalReached = ref.watch(waterGoalReachedProvider);

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AgionSpacing.md),
          child: Column(
            children: [
              // Header
              ShaderMask(
                shaderCallback: (bounds) =>
                    AgionColors.accentGradient.createShader(bounds),
                child: const Text(
                  'WATER TRACKER',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: AgionSpacing.xl),

              // Water ring
              _WaterRingWidget(
                progress: progress,
                consumed: waterLog.consumed,
                target: waterLog.target,
                goalReached: goalReached,
              ),

              const SizedBox(height: AgionSpacing.lg),

              // Goal status
              if (goalReached)
                GlassCard(
                  showGlow: true,
                  padding: const EdgeInsets.all(AgionSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: AgionSpacing.sm),
                      const Text(
                        'GOAL REACHED! +20 XP',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AgionColors.neonCyan,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AgionSpacing.lg),

              // Quick-add buttons
              _buildQuickAddButtons(),

              const SizedBox(height: AgionSpacing.lg),

              // Today's entries
              _buildEntryList(waterLog),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddButtons() {
    const amounts = [250, 500, 750];
    return Row(
      children: amounts.map((ml) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AgionSpacing.xs),
            child: _QuickAddButton(
              amount: ml,
              onTap: () => _addWater(ml),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEntryList(dynamic waterLog) {
    if (waterLog.entries.isEmpty) {
      return const GlassCard(
        child: Center(
          child: Text(
            'No water logged today — tap a button above',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 15,
              color: AgionColors.mutedText,
            ),
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(AgionSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S LOG",
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AgionColors.mutedText,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AgionSpacing.sm),
          ...waterLog.entries.reversed.take(10).map((entry) {
            final time =
                '${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}';
            return Padding(
              padding: const EdgeInsets.only(bottom: AgionSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '+${entry.amount} ml',
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AgionColors.neonCyan,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 14,
                      color: AgionColors.mutedText,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _addWater(int ml) {
    ref.read(waterProvider.notifier).addWater(ml);

    final goalJustReached = ref.read(waterGoalReachedProvider);
    if (goalJustReached) {
      SystemToast.show(context, '💧 Goal reached! +20 XP');
    } else {
      SystemToast.show(context, '+${ml}ml added');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WATER RING WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _WaterRingWidget extends StatefulWidget {
  final double progress;
  final int consumed;
  final int target;
  final bool goalReached;

  const _WaterRingWidget({
    required this.progress,
    required this.consumed,
    required this.target,
    required this.goalReached,
  });

  @override
  State<_WaterRingWidget> createState() => _WaterRingWidgetState();
}

class _WaterRingWidgetState extends State<_WaterRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.22, 0.9, 0.07, 1.0),
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_WaterRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = oldWidget.progress;
      _animation = Tween<double>(begin: _oldProgress, end: widget.progress)
          .animate(CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.22, 0.9, 0.07, 1.0),
      ));
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
    return SizedBox(
      width: 220,
      height: 220,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _WaterRingPainter(
              progress: _animation.value,
              goalReached: widget.goalReached,
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💧', style: TextStyle(fontSize: 32)),
              const SizedBox(height: AgionSpacing.xs),
              Text(
                '${widget.consumed}',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: widget.goalReached
                      ? AgionColors.neonCyan
                      : AgionColors.white,
                ),
              ),
              Text(
                '/ ${widget.target} ml',
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
    );
  }
}

class _WaterRingPainter extends CustomPainter {
  final double progress;
  final bool goalReached;

  _WaterRingPainter({required this.progress, required this.goalReached});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AgionColors.white06
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    // Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = (goalReached ? AgionColors.neonCyan : const Color(0xFF4FC3F7))
            .withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Progress arc
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: goalReached
          ? const [AgionColors.neonCyan, Color(0xFF4FC3F7), AgionColors.neonCyan]
          : const [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF4FC3F7)],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader =
            gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_WaterRingPainter old) =>
      old.progress != progress || old.goalReached != goalReached;
}

// ═══════════════════════════════════════════════════════════════════════════
// QUICK ADD BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class _QuickAddButton extends StatefulWidget {
  final int amount;
  final VoidCallback onTap;

  const _QuickAddButton({required this.amount, required this.onTap});

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.95),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 120,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTap: () {
          _controller.forward(from: 0);
          widget.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AgionSpacing.lg),
          decoration: BoxDecoration(
            color: AgionColors.white03,
            borderRadius: AgionRadius.cardBR,
            border: Border.all(color: AgionColors.cardGlassBorder),
            boxShadow: AgionShadows.neonGlow,
          ),
          child: Column(
            children: [
              const Text('💧', style: TextStyle(fontSize: 24)),
              const SizedBox(height: AgionSpacing.xs),
              Text(
                '+${widget.amount}ml',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AgionColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
