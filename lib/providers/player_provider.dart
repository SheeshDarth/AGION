import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/player_model.dart';
import '../core/services/hive_service.dart';
import '../core/services/system_event_bus.dart';
import '../core/engine/xp_engine.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerModel?>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<PlayerModel?> {
  PlayerNotifier() : super(null) {
    _load();
  }

  // ── Load from box using the named key (not index) ──────────────
  void _load() {
    state = HiveService.playerBox.get('player');
  }

  // ── Persist to box and force a UI rebuild ───────────────────────
  // Never call object.save() — it fails for non-tracked objects
  // (e.g., on web where Hive deserializes fresh copies from IndexedDB).
  // Always use box.put() which works regardless of tracking state.
  Future<void> _persist(PlayerModel player) async {
    await HiveService.playerBox.put('player', player);
    // Force Riverpod rebuild: create a new reference so == check triggers
    state = _copy(player);
  }

  // ── Shallow copy for state (new reference = Riverpod sees a change) ──
  PlayerModel _copy(PlayerModel p) => PlayerModel()
    ..id = p.id
    ..name = p.name
    ..totalXP = p.totalXP
    ..streakDays = p.streakDays
    ..lastActiveDate = p.lastActiveDate
    ..heightCm = p.heightCm
    ..weightKg = p.weightKg
    ..age = p.age
    ..gender = p.gender
    ..activityLevel = p.activityLevel
    ..goals = List<String>.from(p.goals)
    ..createdDate = p.createdDate;

  // ── Public API ──────────────────────────────────────────────────

  Future<void> createPlayer(PlayerModel p) async {
    await HiveService.playerBox.put('player', p);
    _load();
  }

  Future<void> addXP(int amount, String source, Offset tapPos) async {
    // Always read from box to get the authoritative stored version
    final stored = HiveService.playerBox.get('player') ?? state;
    if (stored == null) return;

    final oldLevel = XPEngine.progress(stored.totalXP).$1;
    final oldRank  = XPEngine.rank(oldLevel);

    stored.totalXP += amount;
    await _persist(stored);

    SystemEventBus.instance.fireXP(amount, source, tapPos);

    final newLevel = XPEngine.progress(stored.totalXP).$1;
    final newRank = XPEngine.rank(newLevel);

    if (newLevel > oldLevel) {
      SystemEventBus.instance.fireLevelUp(newLevel, newRank);
      if (newRank != oldRank) {
        SystemEventBus.instance.fireRankUp(oldRank, newRank);
      }
    }
  }

  Future<void> updateStreak() async {
    final stored = HiveService.playerBox.get('player') ?? state;
    if (stored == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (stored.lastActiveDate == today) return;
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);
    stored.streakDays = stored.lastActiveDate == yesterday
        ? stored.streakDays + 1
        : 1;
    stored.lastActiveDate = today;
    await _persist(stored);
  }

  Future<void> updateBiometrics({
    double? heightCm,
    double? weightKg,
    int? age,
    String? gender,
    String? activityLevel,
    List<String>? goals,
  }) async {
    final stored = HiveService.playerBox.get('player') ?? state;
    if (stored == null) return;
    if (heightCm != null) stored.heightCm = heightCm;
    if (weightKg != null) stored.weightKg = weightKg;
    if (age != null) stored.age = age;
    if (gender != null) stored.gender = gender;
    if (activityLevel != null) stored.activityLevel = activityLevel;
    if (goals != null) stored.goals = goals;
    await _persist(stored);
  }
}
