import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'fitness_profile.g.dart';

/// User fitness profile — drives adaptive arc scaling and personalized goals.
@HiveType(typeId: 11)
class FitnessProfile extends Equatable {
  @HiveField(0)
  final String fitnessLevel; // beginner, intermediate, advanced

  @HiveField(1)
  final String primaryGoal; // fat_loss, muscle_gain, strength, endurance, general

  @HiveField(2)
  final String equipment; // bodyweight, minimal, full_gym

  @HiveField(3)
  final int workoutDaysPerWeek; // 3–7

  @HiveField(4)
  final int workoutMinutes; // preferred session length

  @HiveField(5)
  final double bodyWeight; // kg

  @HiveField(6)
  final int age;

  @HiveField(7)
  final String gender; // male, female, other

  @HiveField(8)
  final int targetWeeks; // how long the user wants to train (for arc adaptation)

  const FitnessProfile({
    this.fitnessLevel = 'beginner',
    this.primaryGoal = 'general',
    this.equipment = 'bodyweight',
    this.workoutDaysPerWeek = 5,
    this.workoutMinutes = 45,
    this.bodyWeight = 70.0,
    this.age = 20,
    this.gender = 'male',
    this.targetWeeks = 8,
  });

  /// Scaling factor for reps/sets based on fitness level.
  double get intensityMultiplier {
    switch (fitnessLevel) {
      case 'advanced':
        return 1.3;
      case 'intermediate':
        return 1.0;
      default: // beginner
        return 0.6;
    }
  }

  /// Duration scaling — adjusts arc weeks based on user's target.
  double get durationMultiplier {
    if (targetWeeks <= 4) return 0.6;
    if (targetWeeks <= 6) return 0.8;
    if (targetWeeks <= 8) return 1.0;
    if (targetWeeks <= 12) return 1.3;
    return 1.5; // 12+ weeks
  }

  FitnessProfile copyWith({
    String? fitnessLevel,
    String? primaryGoal,
    String? equipment,
    int? workoutDaysPerWeek,
    int? workoutMinutes,
    double? bodyWeight,
    int? age,
    String? gender,
    int? targetWeeks,
  }) {
    return FitnessProfile(
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      equipment: equipment ?? this.equipment,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      workoutMinutes: workoutMinutes ?? this.workoutMinutes,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      targetWeeks: targetWeeks ?? this.targetWeeks,
    );
  }

  @override
  List<Object?> get props => [
        fitnessLevel,
        primaryGoal,
        equipment,
        workoutDaysPerWeek,
        workoutMinutes,
        bodyWeight,
        age,
        gender,
        targetWeeks,
      ];
}
