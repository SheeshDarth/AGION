import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/audio_service.dart';
import '../../core/ai_guide_voice.dart';
import '../../features/player/player_state.dart';
import '../widgets/system_toast.dart';
import '../widgets/xp_gain_overlay.dart';

// Focus timer durations (minutes)
enum FocusMode {
  pomodoro('Pomodoro', 25, 5),
  deepFocus('Deep Focus', 50, 10),
  sprint('Sprint', 15, 3),
  custom('Custom', 30, 5);

  const FocusMode(this.label, this.workMinutes, this.breakMinutes);
  final String label;
  final int workMinutes;
  final int breakMinutes;
}

final focusModeProvider =
    NotifierProvider<FocusModeNotifier, FocusMode>(FocusModeNotifier.new);

class FocusModeNotifier extends Notifier<FocusMode> {
  @override
  FocusMode build() => FocusMode.pomodoro;
  void set(FocusMode mode) => state = mode;
}

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnim;

  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _sessionsCompleted = 0;
  int _customMinutes = 30;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    final mode = ref.read(focusModeProvider);
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _secondsRemaining =
          (mode == FocusMode.custom ? _customMinutes : mode.workMinutes) * 60;
    });
  }

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
      _pulseController.stop();
      setState(() => _isRunning = false);
    } else {
      AudioService.instance.playFocusStart();
      AiGuideVoice.instance.announceFocusStart(
        _secondsRemaining ~/ 60,
      );
      _pulseController.repeat(reverse: true);
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void _tick() {
    if (_secondsRemaining <= 0) {
      _onTimerDone();
    } else {
      setState(() => _secondsRemaining--);
    }
  }

  Future<void> _onTimerDone() async {
    _timer?.cancel();
    _pulseController.stop();

    if (!_isBreak) {
      // Work session done
      _sessionsCompleted++;
      AudioService.instance.playFocusEnd();
      AiGuideVoice.instance.announceFocusEnd();

      // Award XP
      final xp = XpConfig.focusXp;
      ref.read(playerProvider.notifier).addXp(xp);
      if (mounted) {
        XpGainOverlay.show(context, xp);
        SystemToast.show(context, '🎯 Focus complete! +$xp XP');
      }

      // Start break
      final mode = ref.read(focusModeProvider);
      final breakMins = mode == FocusMode.custom ? 5 : mode.breakMinutes;
      setState(() {
        _isRunning = false;
        _isBreak = true;
        _secondsRemaining = breakMins * 60;
      });
    } else {
      // Break done
      AudioService.instance.playFocusStart();
      _resetTimer();
      if (mounted) {
        SystemToast.show(context, 'Break over — start your next session!');
      }
    }
  }

  double get _progress {
    final mode = ref.read(focusModeProvider);
    final totalSeconds = _isBreak
        ? (mode == FocusMode.custom ? 5 : mode.breakMinutes) * 60
        : (mode == FocusMode.custom ? _customMinutes : mode.workMinutes) * 60;
    if (totalSeconds == 0) return 0;
    return 1.0 - (_secondsRemaining / totalSeconds);
  }

  String get _timeDisplay {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(focusModeProvider);

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AgionSpacing.md),
              child: ShaderMask(
                shaderCallback: (b) =>
                    AgionColors.accentGradient.createShader(b),
                child: const Text(
                  'FOCUS MODE',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // Mode selector
            _buildModeSelector(mode),

            const SizedBox(height: AgionSpacing.xl),

            // Timer ring
            Expanded(
              child: Center(
                child: _buildTimerRing(),
              ),
            ),

            // Session counter
            _buildSessionCounter(),

            const SizedBox(height: AgionSpacing.lg),

            // Controls
            _buildControls(),

            const SizedBox(height: AgionSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(FocusMode selected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AgionSpacing.md),
      child: Row(
        children: FocusMode.values.map((mode) {
          final isSelected = mode == selected;
          return GestureDetector(
            onTap: _isRunning
                ? null
                : () {
                    ref.read(focusModeProvider.notifier).set(mode);
                    _resetTimer();
                    AudioService.instance.playButtonTap();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: AgionSpacing.sm),
              padding: const EdgeInsets.symmetric(
                  horizontal: AgionSpacing.md, vertical: AgionSpacing.sm),
              decoration: BoxDecoration(
                gradient: isSelected ? AgionColors.accentGradient : null,
                color: isSelected ? null : AgionColors.white06,
                borderRadius: AgionRadius.smallBR,
              ),
              child: Column(
                children: [
                  Text(
                    mode.label,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AgionColors.backgroundDeep
                          : AgionColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${mode == FocusMode.custom ? _customMinutes : mode.workMinutes}m',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 11,
                      color: isSelected
                          ? AgionColors.backgroundDeep.withValues(alpha: 0.7)
                          : AgionColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildTimerRing() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) {
        final glowIntensity = _isRunning ? 0.08 + 0.07 * _pulseAnim.value : 0.04;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (_isBreak ? Colors.green : AgionColors.neonCyan)
                        .withValues(alpha: glowIntensity),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Ring
            SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _FocusRingPainter(
                  progress: _progress,
                  isBreak: _isBreak,
                  isRunning: _isRunning,
                  pulseValue: _pulseAnim.value,
                ),
              ),
            ),

            // Center content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isBreak ? '☕' : '🎯',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeDisplay,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: _isBreak ? Colors.green : AgionColors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  _isBreak ? 'BREAK TIME' : (_isRunning ? 'FOCUSING' : 'READY'),
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _isBreak
                        ? Colors.green
                        : (_isRunning
                            ? AgionColors.neonCyan
                            : AgionColors.mutedText),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSessionCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final isDone = i < _sessionsCompleted % 4;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                isDone ? AgionColors.accentGradient : null,
            color: isDone ? null : AgionColors.white06,
          ),
        );
      }),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AgionSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reset
          GestureDetector(
            onTap: _resetTimer,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AgionColors.white06,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AgionColors.mutedText,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: AgionSpacing.xl),

          // Start/Stop
          GestureDetector(
            onTap: _startStop,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AgionColors.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: AgionColors.neonCyan
                        .withValues(alpha: _isRunning ? 0.3 : 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AgionColors.backgroundDeep,
                size: 32,
              ),
            ),
          ),

          const SizedBox(width: AgionSpacing.xl),

          // Skip
          GestureDetector(
            onTap: _onTimerDone,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AgionColors.white06,
              ),
              child: const Icon(
                Icons.skip_next_rounded,
                color: AgionColors.mutedText,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0.0, delay: 500.ms);
  }
}

// ─── FOCUS RING PAINTER ──────────────────────────────────────────────────────

class _FocusRingPainter extends CustomPainter {
  final double progress;
  final bool isBreak;
  final bool isRunning;
  final double pulseValue;

  _FocusRingPainter({
    required this.progress,
    required this.isBreak,
    required this.isRunning,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AgionColors.white06
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;
    final activeColor =
        isBreak ? Colors.green : AgionColors.neonCyan;

    // Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = activeColor.withValues(
            alpha: isRunning ? 0.1 + 0.08 * pulseValue : 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Arc
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: isBreak
          ? [Colors.green.shade300, Colors.teal, Colors.green.shade300]
          : [AgionColors.neonViolet, AgionColors.neonCyan, AgionColors.neonViolet],
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
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) =>
      old.progress != progress ||
      old.isBreak != isBreak ||
      old.pulseValue != pulseValue;
}
