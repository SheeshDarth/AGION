import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'quest_arc.g.dart';

// ─── QUEST ARC ─────────────────────────────────────────────────────────────

@HiveType(typeId: 6)
class QuestArc extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String theme; // anime/series name

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String emoji;

  @HiveField(5)
  final int durationWeeks;

  @HiveField(6)
  final List<ArcPhase> phases;

  @HiveField(7)
  final double xpMultiplier;

  @HiveField(8)
  final BossFight? bossFight;

  @HiveField(9)
  final String difficulty; // E, D, C, B, A, S

  const QuestArc({
    required this.id,
    required this.name,
    required this.theme,
    required this.description,
    required this.emoji,
    required this.durationWeeks,
    required this.phases,
    this.xpMultiplier = 1.5,
    this.bossFight,
    this.difficulty = 'D',
  });

  int get totalExercises =>
      phases.fold<int>(0, (sum, p) => sum + p.exercises.length);

  @override
  List<Object?> get props => [id, name, theme];
}

// ─── PHASE ─────────────────────────────────────────────────────────────────

@HiveType(typeId: 7)
class ArcPhase extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final int weekNumber;

  @HiveField(3)
  final List<ArcExercise> exercises;

  @HiveField(4)
  final int daysPerWeek;

  const ArcPhase({
    required this.name,
    required this.description,
    required this.weekNumber,
    required this.exercises,
    this.daysPerWeek = 5,
  });

  @override
  List<Object?> get props => [name, weekNumber];
}

// ─── EXERCISE ──────────────────────────────────────────────────────────────

@HiveType(typeId: 8)
class ArcExercise extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int sets;

  @HiveField(2)
  final int reps;

  @HiveField(3)
  final double weight; // 0 for bodyweight

  @HiveField(4)
  final int restSeconds;

  @HiveField(5)
  final String type; // strength, cardio, flexibility, endurance

  @HiveField(6)
  final String instruction; // form cue

  const ArcExercise({
    required this.name,
    this.sets = 3,
    this.reps = 10,
    this.weight = 0,
    this.restSeconds = 60,
    this.type = 'strength',
    this.instruction = '',
  });

  @override
  List<Object?> get props => [name, sets, reps];
}

// ─── BOSS FIGHT ────────────────────────────────────────────────────────────

@HiveType(typeId: 9)
class BossFight extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final List<ArcExercise> challenges;

  @HiveField(3)
  final int bonusXp;

  const BossFight({
    required this.name,
    required this.description,
    required this.challenges,
    this.bonusXp = 200,
  });

  @override
  List<Object?> get props => [name];
}

// ─── ARC PROGRESS ──────────────────────────────────────────────────────────

@HiveType(typeId: 10)
class ArcProgress extends Equatable {
  @HiveField(0)
  final String arcId;

  @HiveField(1)
  final int currentPhase;

  @HiveField(2)
  final int currentDay;

  @HiveField(3)
  final int completedDays;

  @HiveField(4)
  final bool bossDefeated;

  @HiveField(5)
  final DateTime startedAt;

  @HiveField(6)
  final DateTime? completedAt;

  @HiveField(7)
  final List<DateTime> workoutDates;

  const ArcProgress({
    required this.arcId,
    this.currentPhase = 0,
    this.currentDay = 0,
    this.completedDays = 0,
    this.bossDefeated = false,
    required this.startedAt,
    this.completedAt,
    this.workoutDates = const [],
  });

  bool get isComplete => completedAt != null;

  double get progressFraction {
    if (completedDays == 0) return 0;
    // Rough estimate based on typical 5 days/week
    return (completedDays / 40).clamp(0.0, 1.0);
  }

  ArcProgress copyWith({
    int? currentPhase,
    int? currentDay,
    int? completedDays,
    bool? bossDefeated,
    DateTime? completedAt,
    List<DateTime>? workoutDates,
  }) {
    return ArcProgress(
      arcId: arcId,
      currentPhase: currentPhase ?? this.currentPhase,
      currentDay: currentDay ?? this.currentDay,
      completedDays: completedDays ?? this.completedDays,
      bossDefeated: bossDefeated ?? this.bossDefeated,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      workoutDates: workoutDates ?? this.workoutDates,
    );
  }

  @override
  List<Object?> get props => [arcId, currentPhase, completedDays];
}
