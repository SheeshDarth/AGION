import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import 'home_screen.dart';
import 'workout_screen.dart';
import 'water_screen.dart';

/// Tab index notifier for bottom nav.
class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final tabIndexProvider =
    NotifierProvider<TabIndexNotifier, int>(TabIndexNotifier.new);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    HomeScreen(),
    WorkoutScreen(),
    WaterScreen(),       // Using water as Diet tab for now
    _PlaceholderScreen(title: 'PROFILE', icon: '👤'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AgionColors.backgroundDeep,
          border: Border(
            top: BorderSide(color: AgionColors.white06, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => ref.read(tabIndexProvider.notifier).setIndex(index),
          backgroundColor: AgionColors.backgroundDeep,
          selectedItemColor: AgionColors.neonCyan,
          unselectedItemColor: AgionColors.mutedText,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              label: 'Workout',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_rounded),
              label: 'Water',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PLACEHOLDER ──────────────────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AgionSpacing.md),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AgionColors.mutedText,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AgionSpacing.sm),
            const Text(
              'Coming soon...',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 16,
                color: AgionColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
