import 'package:hive/hive.dart';
import '../../domain/models/workout.dart';

/// Local data source for workouts using Hive.
class WorkoutLocalSource {
  static const String _boxName = 'workout_box';

  late Box<Workout> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Workout>(_boxName);
  }

  List<Workout> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Workout? getById(String id) {
    try {
      return _box.values.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Workout workout) async {
    await _box.put(workout.id, workout);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Get workouts for a specific week.
  List<Workout> getForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return getAll()
        .where((w) =>
            w.date.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
            w.date.isBefore(weekEnd))
        .toList();
  }
}
