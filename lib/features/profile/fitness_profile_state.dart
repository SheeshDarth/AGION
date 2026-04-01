import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/models/fitness_profile.dart';

/// Provider for the user's fitness profile.
final fitnessProfileProvider =
    NotifierProvider<FitnessProfileNotifier, FitnessProfile>(
        FitnessProfileNotifier.new);

class FitnessProfileNotifier extends Notifier<FitnessProfile> {
  static const _boxName = 'fitness_profile';
  static const _key = 'profile';

  @override
  FitnessProfile build() => const FitnessProfile();

  /// Load from Hive.
  Future<void> init() async {
    final box = await Hive.openBox<FitnessProfile>(_boxName);
    final saved = box.get(_key);
    if (saved != null) state = saved;
  }

  /// Update the profile and persist.
  Future<void> update(FitnessProfile profile) async {
    state = profile;
    final box = await Hive.openBox<FitnessProfile>(_boxName);
    await box.put(_key, profile);
  }

  Future<void> updateField({
    String? fitnessLevel,
    String? primaryGoal,
    String? equipment,
    int? workoutDaysPerWeek,
    int? workoutMinutes,
    double? bodyWeight,
    int? age,
    String? gender,
    int? targetWeeks,
  }) async {
    final updated = state.copyWith(
      fitnessLevel: fitnessLevel,
      primaryGoal: primaryGoal,
      equipment: equipment,
      workoutDaysPerWeek: workoutDaysPerWeek,
      workoutMinutes: workoutMinutes,
      bodyWeight: bodyWeight,
      age: age,
      gender: gender,
      targetWeeks: targetWeeks,
    );
    await update(updated);
  }
}
