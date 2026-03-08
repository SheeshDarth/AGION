import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agion/presentation/screens/home_screen.dart';
import 'package:agion/features/player/player_state.dart';
import 'package:agion/domain/models/player.dart';
import 'package:agion/core/theme.dart';
import 'package:agion/data/local/player_local_source.dart';
import 'package:agion/data/repositories/player_repository.dart';

// Mock PlayerLocalSource that doesn't need Hive
class MockPlayerLocalSource extends PlayerLocalSource {
  Player? _player;

  @override
  Future<void> init() async {}

  @override
  Player? getPlayer() => _player;

  @override
  Future<void> savePlayer(Player player) async {
    _player = player;
  }

  @override
  Future<void> deletePlayer() async {
    _player = null;
  }

  @override
  bool hasPlayer() => _player != null;
}

void main() {
  group('HomeScreen Widget Tests', () {
    Widget createTestApp() {
      final mockSource = MockPlayerLocalSource();
      return ProviderScope(
        overrides: [
          playerLocalSourceProvider.overrideWithValue(mockSource),
          playerRepositoryProvider.overrideWith((ref) {
            return PlayerRepository(mockSource);
          }),
        ],
        child: MaterialApp(
          theme: AgionTheme.dark,
          home: const HomeScreen(),
        ),
      );
    }

    testWidgets('HomeScreen renders XP ring with level display',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      // Use pump() instead of pumpAndSettle() to avoid timeout from
      // RankBadgeWidget's infinite pulse animation
      await tester.pump(const Duration(milliseconds: 500));

      // Should show LV text
      expect(find.textContaining('LV'), findsWidgets);
    });

    testWidgets('HomeScreen shows all 6 quick action buttons',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('WATER'), findsOneWidget);
      expect(find.text('STEPS'), findsOneWidget);
      expect(find.text('DIET'), findsOneWidget);
      expect(find.text('FOCUS'), findsOneWidget);
      expect(find.text('DISCIPLINE'), findsOneWidget);
    });

    testWidgets('HomeScreen shows XP reward amounts', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('+50 XP'), findsOneWidget); // Workout
      expect(find.text('+20 XP'), findsWidgets);   // Water + Discipline
      expect(find.text('+30 XP'), findsWidgets);   // Steps + Focus
      expect(find.text('+25 XP'), findsOneWidget); // Diet
    });

    testWidgets('Tapping quick action updates XP', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Initial state: 0 XP
      expect(find.text('0 / 100 XP'), findsOneWidget);

      // Scroll down to make WORKOUT visible, then tap
      final workoutFinder = find.text('WORKOUT');
      await tester.ensureVisible(workoutFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(workoutFinder);
      await tester.pump(const Duration(milliseconds: 500));

      // XP should update to 50/100
      expect(find.text('50 / 100 XP'), findsOneWidget);
    });

    testWidgets('HomeScreen shows streak indicator', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Streak should show 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('HomeScreen shows SYSTEM message', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Complete a workout to gain +50 XP'), findsOneWidget);
    });

  });
}
