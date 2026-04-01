import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/audio_service.dart';
import 'home_screen.dart';
import 'quest_arc_screen.dart';
import 'workout_screen.dart';
import 'water_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';
import 'focus_screen.dart';
import 'settings_screen.dart';

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
    QuestArcScreen(),
    WorkoutScreen(),
    WaterScreen(),
    FocusScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: Stack(
        children: [
          // Screens
          IndexedStack(
            index: currentIndex,
            children: _screens,
          ),

          // Floating settings button (top-right on home screen)
          if (currentIndex == 0)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: AgionSpacing.md, top: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      _slideRoute(const SettingsScreen()),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AgionColors.white06,
                        borderRadius: AgionRadius.smallBR,
                        border: Border.all(color: AgionColors.white06),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AgionColors.mutedText,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, ref, currentIndex),
    );
  }

  Widget _buildBottomNav(
      BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AgionColors.backgroundDeep,
        border: Border(
          top: BorderSide(color: AgionColors.white06, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isSelected = i == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      AudioService.instance.playButtonTap();
                      ref.read(tabIndexProvider.notifier).setIndex(i);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AgionColors.neonCyan.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 20,
                          color: isSelected
                              ? AgionColors.neonCyan
                              : AgionColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 7,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          letterSpacing: 0.5,
                          color: isSelected
                              ? AgionColors.neonCyan
                              : AgionColors.mutedText,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

PageRoute _slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        )),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

const _navItems = [
  _NavItem(Icons.home_outlined, Icons.home_rounded, 'HOME'),
  _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome, 'QUESTS'),
  _NavItem(Icons.fitness_center_outlined, Icons.fitness_center_rounded, 'TRAIN'),
  _NavItem(Icons.water_drop_outlined, Icons.water_drop_rounded, 'WATER'),
  _NavItem(Icons.timer_outlined, Icons.timer_rounded, 'FOCUS'),
  _NavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'STATS'),
  _NavItem(Icons.person_outline, Icons.person_rounded, 'PROFILE'),
];
