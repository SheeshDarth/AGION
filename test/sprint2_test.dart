import 'package:flutter_test/flutter_test.dart';
import 'package:agion/domain/models/workout.dart';
import 'package:agion/domain/models/water_log.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════
  // WORKOUT MODEL TESTS
  // ═══════════════════════════════════════════════════════════════════════

  group('Workout Model Tests', () {
    test('New workout has empty exercises', () {
      final now = DateTime.now();
      final workout = Workout(
        id: 'w1',
        date: now,
        createdAt: now,
        updatedAt: now,
      );
      expect(workout.exercises, isEmpty);
      expect(workout.duration, 0);
      expect(workout.notes, '');
      expect(workout.synced, false);
    });

    test('copyWith creates new workout with updated fields', () {
      final now = DateTime.now();
      final workout = Workout(
        id: 'w1',
        date: now,
        createdAt: now,
        updatedAt: now,
      );
      final updated = workout.copyWith(duration: 3600, notes: 'Great session');
      expect(updated.duration, 3600);
      expect(updated.notes, 'Great session');
      expect(updated.id, 'w1'); // unchanged
    });

    test('Exercise with sets tracks correctly', () {
      const exercise = Exercise(
        name: 'Bench Press',
        sets: [
          ExerciseSet(reps: 10, weight: 60),
          ExerciseSet(reps: 8, weight: 70),
          ExerciseSet(reps: 6, weight: 80),
        ],
      );
      expect(exercise.sets.length, 3);
      expect(exercise.sets[0].reps, 10);
      expect(exercise.sets[2].weight, 80);
    });

    test('ExerciseSet copyWith updates correctly', () {
      const set = ExerciseSet(reps: 10, weight: 60);
      final updated = set.copyWith(reps: 12);
      expect(updated.reps, 12);
      expect(updated.weight, 60); // unchanged
    });

    test('Workout with exercises calculates total sets', () {
      final now = DateTime.now();
      final workout = Workout(
        id: 'w1',
        date: now,
        createdAt: now,
        updatedAt: now,
        exercises: const [
          Exercise(name: 'Squat', sets: [
            ExerciseSet(reps: 5, weight: 100),
            ExerciseSet(reps: 5, weight: 100),
            ExerciseSet(reps: 5, weight: 100),
          ]),
          Exercise(name: 'Deadlift', sets: [
            ExerciseSet(reps: 3, weight: 140),
          ]),
        ],
      );
      final totalSets =
          workout.exercises.fold<int>(0, (sum, e) => sum + e.sets.length);
      expect(totalSets, 4);
      expect(workout.exercises.length, 2);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // WATER LOG MODEL TESTS
  // ═══════════════════════════════════════════════════════════════════════

  group('WaterLog Model Tests', () {
    test('New water log starts at 0 consumed', () {
      final log = WaterLog.today();
      expect(log.consumed, 0);
      expect(log.target, 3000);
      expect(log.progress, 0.0);
      expect(log.goalReached, false);
      expect(log.entries, isEmpty);
    });

    test('Custom target water log', () {
      final log = WaterLog.today(target: 4000);
      expect(log.target, 4000);
    });

    test('addWater increments consumed and adds entry', () {
      var log = WaterLog.today();
      log = log.addWater(500);
      expect(log.consumed, 500);
      expect(log.entries.length, 1);
      expect(log.entries.first.amount, 500);
    });

    test('Multiple addWater calls accumulate', () {
      var log = WaterLog.today();
      log = log.addWater(250);
      log = log.addWater(500);
      log = log.addWater(750);
      expect(log.consumed, 1500);
      expect(log.entries.length, 3);
    });

    test('progress clamps to 1.0 at 100%', () {
      var log = WaterLog.today(target: 1000);
      log = log.addWater(1500); // over goal
      expect(log.progress, 1.0);
      expect(log.consumed, 1500);
    });

    test('goalReached returns true when consumed >= target', () {
      var log = WaterLog.today(target: 1000);
      log = log.addWater(1000);
      expect(log.goalReached, true);
    });

    test('goalReached returns false when consumed < target', () {
      var log = WaterLog.today(target: 3000);
      log = log.addWater(2999);
      expect(log.goalReached, false);
    });

    test('progress calculates fraction correctly', () {
      var log = WaterLog.today(target: 2000);
      log = log.addWater(500);
      expect(log.progress, closeTo(0.25, 0.01));
    });

    test('date key format is YYYY-MM-DD', () {
      final log = WaterLog.today();
      expect(log.date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });

    test('copyWith preserves unmodified fields', () {
      var log = WaterLog.today(target: 3000);
      log = log.addWater(500);
      final updated = log.copyWith(target: 4000);
      expect(updated.consumed, 500); // kept
      expect(updated.target, 4000); // changed
      expect(updated.entries.length, 1); // kept
    });
  });
}
