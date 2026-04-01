import '../../domain/models/quest_arc.dart';
import '../../domain/models/fitness_profile.dart';

/// Scales Quest Arc exercises/phases based on the user's FitnessProfile.
class AdaptiveArcEngine {
  AdaptiveArcEngine._();

  /// Returns a copy of [arc] with exercises scaled to user profile.
  static QuestArc scaleArc(QuestArc arc, FitnessProfile profile) {
    final intensityMul = profile.intensityMultiplier;
    final daysPW = profile.workoutDaysPerWeek;

    final scaledPhases = arc.phases.map((phase) {
      final scaledExercises = phase.exercises.map((ex) {
        return ArcExercise(
          name: ex.name,
          sets: _scaleInt(ex.sets, intensityMul),
          reps: _scaleInt(ex.reps, intensityMul),
          weight: ex.weight,
          restSeconds: _scaleRest(ex.restSeconds, intensityMul),
          type: ex.type,
          instruction: ex.instruction,
        );
      }).toList();

      return ArcPhase(
        name: phase.name,
        description: phase.description,
        weekNumber: phase.weekNumber,
        exercises: scaledExercises,
        daysPerWeek: daysPW.clamp(3, 7),
      );
    }).toList();

    // Scale total weeks based on user target
    final scaledWeeks =
        (arc.durationWeeks * profile.durationMultiplier).round().clamp(2, 16);

    return QuestArc(
      id: arc.id,
      name: arc.name,
      theme: arc.theme,
      description: arc.description,
      emoji: arc.emoji,
      durationWeeks: scaledWeeks,
      phases: scaledPhases,
      xpMultiplier: arc.xpMultiplier,
      bossFight: arc.bossFight != null
          ? _scaleBoss(arc.bossFight!, intensityMul)
          : null,
      difficulty: arc.difficulty,
    );
  }

  static BossFight _scaleBoss(BossFight boss, double mul) {
    return BossFight(
      name: boss.name,
      description: boss.description,
      bonusXp: boss.bonusXp,
      challenges: boss.challenges.map((ex) {
        return ArcExercise(
          name: ex.name,
          sets: _scaleInt(ex.sets, mul),
          reps: _scaleInt(ex.reps, mul),
          weight: ex.weight,
          restSeconds: _scaleRest(ex.restSeconds, mul),
          type: ex.type,
          instruction: ex.instruction,
        );
      }).toList(),
    );
  }

  /// Scale reps/sets: beginners do fewer, advanced do more.
  static int _scaleInt(int value, double mul) {
    return (value * mul).round().clamp(1, 999);
  }

  /// Scale rest: beginners get more rest, advanced gets less.
  static int _scaleRest(int rest, double mul) {
    if (rest == 0) return 0;
    // Invert: beginners need MORE rest, advanced needs LESS
    final scaledRest = (rest / mul).round();
    return scaledRest.clamp(10, 300);
  }
}
