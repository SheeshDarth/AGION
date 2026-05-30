import 'package:go_router/go_router.dart';
import '../../ui/screens/splash/splash_screen.dart';
import '../../ui/screens/onboarding/onboarding_shell.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/workout/workout_hub_screen.dart';
import '../../ui/screens/workout/active_session_screen.dart';
import '../../ui/screens/workout/session_summary_screen.dart';
import '../../ui/screens/nutrition/nutrition_screen.dart';
import '../../ui/screens/finance/finance_screen.dart';
import '../../ui/screens/planner/planner_screen.dart';
import '../../ui/screens/planner/focus_timer_screen.dart';
import '../../ui/screens/analytics/analytics_screen.dart';
import '../../ui/screens/ai_coach/ai_coach_screen.dart';
import '../../ui/screens/profile/profile_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';
import '../../ui/screens/legal/privacy_policy_screen.dart';
import '../../ui/screens/legal/terms_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',      name: 'splash',      builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/onboarding',  name: 'onboarding',  builder: (c, s) => const OnboardingShell()),
    GoRoute(path: '/home',        name: 'home',        builder: (c, s) => const HomeScreen()),
    GoRoute(path: '/workout',     name: 'workout',     builder: (c, s) => const WorkoutHubScreen()),
    GoRoute(path: '/workout/session', name: 'session', builder: (c, s) => const ActiveSessionScreen()),
    GoRoute(path: '/workout/summary', name: 'summary', builder: (c, s) => const SessionSummaryScreen()),
    GoRoute(path: '/nutrition',   name: 'nutrition',   builder: (c, s) => const NutritionScreen()),
    GoRoute(path: '/finance',     name: 'finance',     builder: (c, s) => const FinanceScreen()),
    GoRoute(path: '/planner',     name: 'planner',     builder: (c, s) => const PlannerScreen()),
    GoRoute(path: '/focus',       name: 'focus',       builder: (c, s) => const FocusTimerScreen()),
    GoRoute(path: '/analytics',   name: 'analytics',   builder: (c, s) => const AnalyticsScreen()),
    GoRoute(path: '/ai',          name: 'ai',          builder: (c, s) => const AiCoachScreen()),
    GoRoute(path: '/profile',     name: 'profile',     builder: (c, s) => const ProfileScreen()),
    GoRoute(path: '/settings',      name: 'settings', builder: (c, s) => const SettingsScreen()),
    GoRoute(path: '/legal/privacy', name: 'privacy',  builder: (c, s) => const PrivacyPolicyScreen()),
    GoRoute(path: '/legal/terms',   name: 'terms',    builder: (c, s) => const TermsScreen()),
  ],
);
