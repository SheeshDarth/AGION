import 'package:hive/hive.dart';
import '../../domain/models/quest_arc.dart';

/// Local persistence for Quest Arc progress using Hive.
class ArcLocalSource {
  static const _boxName = 'arc_progress';

  Future<Box<ArcProgress>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return Hive.openBox<ArcProgress>(_boxName);
    }
    return Hive.box<ArcProgress>(_boxName);
  }

  /// Get progress for a specific arc.
  Future<ArcProgress?> getProgress(String arcId) async {
    final box = await _openBox();
    return box.get(arcId);
  }

  /// Get all active arc progress entries.
  Future<List<ArcProgress>> getAllProgress() async {
    final box = await _openBox();
    return box.values.toList();
  }

  /// Save or update progress.
  Future<void> saveProgress(ArcProgress progress) async {
    final box = await _openBox();
    await box.put(progress.arcId, progress);
  }

  /// Delete progress (abandon arc).
  Future<void> deleteProgress(String arcId) async {
    final box = await _openBox();
    await box.delete(arcId);
  }
}
