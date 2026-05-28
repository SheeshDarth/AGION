import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../core/services/hive_service.dart';
import '../../../ui/system/system_text.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _animateDots();
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  void _animateDots() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _dotCount = (_dotCount % 3) + 1);
      _animateDots();
    });
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final hasPlayer = HiveService.playerBox.isNotEmpty;

    if (!mounted) return;
    if (!onboardingDone || !hasPlayer) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: Stack(
        children: [
          // Scanline sweep
          AnimatedBuilder(
            animation: _scanController,
            builder: (_, __) => Positioned(
              top: _scanController.value * MediaQuery.of(context).size.height - 2,
              left: 0, right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    SLColors.glowCore.withOpacity(0.6),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SLText(
                  'AGION',
                  style: SLType.display(size: 42, color: SLColors.textBright, spacing: 12),
                  glowColor: SLColors.glowCore,
                  glowRadius: 24,
                  align: TextAlign.center,
                )
                .animate()
                  .fade(duration: 600.ms, curve: Curves.easeIn)
                  .scale(begin: const Offset(0.9, 0.9), duration: 600.ms),

                const SizedBox(height: 24),

                SLText(
                  'SYSTEM INITIALIZING$dots',
                  style: SLType.body(size: 13, color: SLColors.textMid),
                  align: TextAlign.center,
                )
                .animate(delay: 400.ms)
                  .fade(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
