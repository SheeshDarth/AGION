import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'workout.g.dart';

@HiveType(typeId: 1)
class Workout extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int duration; // seconds

  @HiveField(3)
  final List<Exercise> exercises;

  @HiveField(4)
  final String notes;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final bool synced;

  const Workout({
    required this.id,
    required this.date,
    this.duration = 0,
    this.exercises = const [],
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  Workout copyWith({
    String? id,
    DateTime? date,
    int? duration,
    List<Exercise>? exercises,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return Workout(
      id: id ?? this.id,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props =>
      [id, date, duration, exercises, notes, createdAt, updatedAt, synced];
}

@HiveType(typeId: 2)
class Exercise extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<ExerciseSet> sets;

  const Exercise({
    required this.name,
    this.sets = const [],
  });

  Exercise copyWith({String? name, List<ExerciseSet>? sets}) {
    return Exercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
    );
  }

  @override
  List<Object?> get props => [name, sets];
}

@HiveType(typeId: 3)
class ExerciseSet extends Equatable {
  @HiveField(0)
  final int reps;

  @HiveField(1)
  final double weight; // kg

  const ExerciseSet({
    this.reps = 0,
    this.weight = 0,
  });

  ExerciseSet copyWith({int? reps, double? weight}) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  @override
  List<Object?> get props => [reps, weight];
}
