import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/audio_service.dart';
import 'core/ai_guide_voice.dart';
import 'features/auth/auth_state.dart';
import 'features/player/player_state.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding_screen.dart';

// App-wide state for which screen to show
enum _AppScreen { splash, login, onboarding, main }

class AgionApp extends ConsumerStatefulWidget {
  const AgionApp({super.key});

  @override
  ConsumerState<AgionApp> createState() => _AgionAppState();
}

class _AgionAppState extends ConsumerState<AgionApp> {
  _AppScreen _screen = _AppScreen.splash;
  bool _onboardingDone = false;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    // Init audio services
    await AudioService.instance.init();
    await AiGuideVoice.instance.init();

    // Check onboarding status
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool('onboarding_done') ?? false;

    // Init auth
    await ref.read(authProvider.notifier).init();

    // Init player
    await ref.read(playerProvider.notifier).init();
  }

  void _onSplashComplete() {
    final authState = ref.read(authProvider);
    if (!authState.isSignedIn) {
      setState(() => _screen = _AppScreen.login);
    } else if (!_onboardingDone) {
      setState(() => _screen = _AppScreen.onboarding);
    } else {
      setState(() => _screen = _AppScreen.main);
    }
  }

  void _onAuthComplete() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((p) {
      final done = p.getBool('onboarding_done') ?? false;
      setState(() =>
          _screen = done ? _AppScreen.main : _AppScreen.onboarding);
    });
  }

  void _onOnboardingComplete() {
    setState(() => _screen = _AppScreen.main);
    AiGuideVoice.instance.announceWelcome(
      ref.read(playerProvider).displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to react to sign-out
    final authState = ref.watch(authProvider);

    // Handle sign-out while on main
    if (_screen == _AppScreen.main && !authState.isSignedIn) {
      Future.microtask(() => setState(() => _screen = _AppScreen.login));
    }

    return MaterialApp(
      title: 'Agion',
      debugShowCheckedModeBanner: false,
      theme: AgionTheme.dark,
      home: _buildCurrentScreen(authState),
    );
  }

  Widget _buildCurrentScreen(authState) {
    switch (_screen) {
      case _AppScreen.splash:
        return SplashScreen(onComplete: _onSplashComplete);

      case _AppScreen.login:
        return _LoginWrapper(
          onLoginSuccess: _onAuthComplete,
          onGuestContinue: _onAuthComplete,
        );

      case _AppScreen.onboarding:
        return OnboardingScreen(onComplete: _onOnboardingComplete);

      case _AppScreen.main:
        return const MainShell();
    }
  }
}

/// Wrapper that calls callbacks when login state changes.
class _LoginWrapper extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onGuestContinue;

  const _LoginWrapper({
    required this.onLoginSuccess,
    required this.onGuestContinue,
  });

  @override
  ConsumerState<_LoginWrapper> createState() => _LoginWrapperState();
}

class _LoginWrapperState extends ConsumerState<_LoginWrapper> {
  bool _wasSignedIn = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState.isSignedIn && !_wasSignedIn) {
      _wasSignedIn = true;
      Future.microtask(() {
        if (authState.isGuest) {
          widget.onGuestContinue();
        } else {
          widget.onLoginSuccess();
        }
      });
    }
    return const LoginScreen();
  }
}
