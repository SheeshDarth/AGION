import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/quest_model.dart';
import '../core/services/hive_service.dart';
import '../core/engine/xp_engine.dart';

final questProvider = StateNotifierProvider<QuestNotifier, List<QuestModel>>((ref) {
  return QuestNotifier();
});

final todayQuestsProvider = Provider<List<QuestModel>>((ref) {
  final quests = ref.watch(questProvider);
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return quests.where((q) => q.date == today).toList();
});

class QuestNotifier extends StateNotifier<List<QuestModel>> {
  QuestNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.questBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<QuestModel> add({
    required String title,
    required String category,
    required String difficulty,
    String? description,
    String? arc,
    bool isRecurring = false,
  }) async {
    final xp = XPEngine.actionXP['quest${difficulty[0].toUpperCase()}${difficulty.substring(1)}'] ??
        XPEngine.actionXP['questMedium']!;
    final quest = QuestModel()
      ..id = const Uuid().v4()
      ..title = title
      ..category = category
      ..difficulty = difficulty
      ..xpReward = xp
      ..date = DateTime.now().toIso8601String().substring(0, 10)
      ..description = description
      ..arc = arc
      ..isRecurring = isRecurring;
    await HiveService.questBox.put(quest.id, quest);
    _load();
    return quest;
  }

  Future<void> complete(String id) async {
    final quest = HiveService.questBox.get(id);
    if (quest == null || quest.isCompleted) return;
    quest.isCompleted = true;
    quest.completedAt = DateTime.now().toIso8601String();
    // Use box.put() not object.save() — .save() fails on non-tracked objects
    // (e.g., Hive on web deserializes fresh copies from IndexedDB)
    await HiveService.questBox.put(id, quest);
    _load();
  }

  Future<void> addFromJson(List<Map<String, dynamic>> quests) async {
    for (final q in quests) {
      await add(
        title: q['title'] as String,
        category: q['category'] as String? ?? 'habit',
        difficulty: q['difficulty'] as String? ?? 'medium',
        description: q['description'] as String?,
      );
    }
  }

  Future<void> clearAll() async {
    await HiveService.questBox.clear();
    state = [];
  }
}
