import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/workout.dart';
import '../../data/local/workout_local_source.dart';
import '../player/player_state.dart';
import '../../core/constants.dart';

// ─── PROVIDERS ─────────────────────────────────────────────────────────────

final workoutLocalSourceProvider = Provider<WorkoutLocalSource>((ref) {
  return WorkoutLocalSource();
});

final workoutListProvider =
    NotifierProvider<WorkoutListNotifier, List<Workout>>(
        WorkoutListNotifier.new);

/// The workout currently being edited/created.
final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutNotifier, Workout?>(
        ActiveWorkoutNotifier.new);

// ─── WORKOUT LIST NOTIFIER ─────────────────────────────────────────────────

class WorkoutListNotifier extends Notifier<List<Workout>> {
  @override
  List<Workout> build() => [];

  Future<void> init() async {
    final source = ref.read(workoutLocalSourceProvider);
    await source.init();
    state = source.getAll();
  }

  Future<void> saveWorkout(Workout workout) async {
    final source = ref.read(workoutLocalSourceProvider);
    await source.save(workout);
    state = source.getAll();

    // Award XP for logging a workout
    ref.read(playerProvider.notifier).awardXp(QuickAction.workout);
  }

  Future<void> deleteWorkout(String id) async {
    final source = ref.read(workoutLocalSourceProvider);
    await source.delete(id);
    state = source.getAll();
  }

  Future<void> refresh() async {
    final source = ref.read(workoutLocalSourceProvider);
    state = source.getAll();
  }
}

// ─── ACTIVE WORKOUT NOTIFIER (editor state) ─────────────────────────────

class ActiveWorkoutNotifier extends Notifier<Workout?> {
  @override
  Workout? build() => null;

  /// Start a new workout session.
  void startNew() {
    final now = DateTime.now();
    state = Workout(
      id: '${now.millisecondsSinceEpoch}',
      date: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Load an existing workout for editing.
  void loadExisting(Workout workout) {
    state = workout;
  }

  /// Duplicate a previous workout as a new session.
  void duplicate(Workout source) {
    final now = DateTime.now();
    state = source.copyWith(
      id: '${now.millisecondsSinceEpoch}',
      date: now,
      createdAt: now,
      updatedAt: now,
      synced: false,
    );
  }

  /// Add an exercise to the active workout.
  void addExercise(String name) {
    if (state == null) return;
    final exercises = [...state!.exercises, Exercise(name: name)];
    state = state!.copyWith(exercises: exercises, updatedAt: DateTime.now());
  }

  /// Remove an exercise by index.
  void removeExercise(int index) {
    if (state == null) return;
    final exercises = [...state!.exercises]..removeAt(index);
    state = state!.copyWith(exercises: exercises, updatedAt: DateTime.now());
  }

  /// Add a set to an exercise.
  void addSet(int exerciseIndex, {int reps = 0, double weight = 0}) {
    if (state == null) return;
    final exercises = [...state!.exercises];
    final exercise = exercises[exerciseIndex];
    final sets = [...exercise.sets, ExerciseSet(reps: reps, weight: weight)];
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);
    state = state!.copyWith(exercises: exercises, updatedAt: DateTime.now());
  }

  /// Update a specific set.
  void updateSet(int exerciseIndex, int setIndex,
      {int? reps, double? weight}) {
    if (state == null) return;
    final exercises = [...state!.exercises];
    final exercise = exercises[exerciseIndex];
    final sets = [...exercise.sets];
    sets[setIndex] = sets[setIndex].copyWith(reps: reps, weight: weight);
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);
    state = state!.copyWith(exercises: exercises, updatedAt: DateTime.now());
  }

  /// Remove a set.
  void removeSet(int exerciseIndex, int setIndex) {
    if (state == null) return;
    final exercises = [...state!.exercises];
    final exercise = exercises[exerciseIndex];
    final sets = [...exercise.sets]..removeAt(setIndex);
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);
    state = state!.copyWith(exercises: exercises, updatedAt: DateTime.now());
  }

  /// Update notes.
  void setNotes(String notes) {
    if (state == null) return;
    state = state!.copyWith(notes: notes, updatedAt: DateTime.now());
  }

  /// Update duration.
  void setDuration(int seconds) {
    if (state == null) return;
    state = state!.copyWith(duration: seconds, updatedAt: DateTime.now());
  }

  /// Clear the active workout.
  void clear() => state = null;
}
