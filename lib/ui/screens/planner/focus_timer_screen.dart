import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../providers/player_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_button.dart';
import '../../system/system_text.dart';

class FocusTimerScreen extends ConsumerStatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen>
    with TickerProviderStateMixin {
  static const int _focusDuration = 25 * 60; // 25 minutes
  static const int _breakDuration = 5 * 60;

  Timer? _timer;
  int _remaining = _focusDuration;
  bool _running = false;
  bool _isFocus = true;
  int _sessionsCompleted = 0;

  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_remaining > 0) {
            _remaining--;
          } else {
            _onComplete();
          }
        });
      });
      setState(() => _running = true);
    }
  }

  void _onComplete() {
    _timer?.cancel();
    setState(() => _running = false);

    if (_isFocus) {
      _sessionsCompleted++;
      const center = Offset(200, 400);
      ref.read(playerProvider.notifier).addXP(30, 'deepFocus', center);
      setState(() { _isFocus = false; _remaining = _breakDuration; });
    } else {
      setState(() { _isFocus = true; _remaining = _focusDuration; });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _isFocus = true;
      _remaining = _focusDuration;
    });
  }

  String get _timeStr {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = _isFocus ? _focusDuration : _breakDuration;
    return 1.0 - (_remaining / total);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _isFocus ? SLColors.glowCore : SLColors.success;

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        intensity: 0.25,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(),
                      child: Icon(Icons.arrow_back, color: SLColors.textMid, size: 20)),
                    const Spacer(),
                    SLText(_isFocus ? 'FOCUS' : 'BREAK',
                        style: SLType.sysLabel(size: 12, color: accentColor)),
                    const Spacer(),
                    SLText('SESSION $_sessionsCompleted',
                        style: SLType.sysLabel(color: SLColors.textMid)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 240, height: 240,
                      child: CustomPaint(
                        painter: _TimerRingPainter(progress: _progress, color: accentColor),
                        child: Center(
                          child: SLText(_timeStr,
                              style: SLType.display(size: 48, color: SLColors.textBright),
                              glowColor: accentColor, glowRadius: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SystemButton(
                          label: _running ? 'PAUSE' : 'START',
                          color: accentColor,
                          icon: _running ? Icons.pause : Icons.play_arrow,
                          onTap: _toggle,
                        ),
                        const SizedBox(width: 16),
                        SystemButton(
                          label: 'RESET',
                          variant: SystemButtonVariant.ghost,
                          onTap: _reset,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SLText(
                      _isFocus
                          ? '◈ SYSTEM: Deep work mode active. Minimize distractions.'
                          : '◈ SYSTEM: Recovery phase. Hydrate and breathe.',
                      style: SLType.body(size: 12, color: SLColors.textMid),
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _TimerRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    // Track
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi, false,
      Paint()..color = SLColors.textDim.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 4);
    // Progress
    if (progress > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, progress * 2 * math.pi, false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, 6));
    }
  }

  @override
  bool shouldRepaint(_TimerRingPainter old) => old.progress != progress;
}
