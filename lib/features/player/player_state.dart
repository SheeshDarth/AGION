import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../domain/models/player.dart';
import '../../data/local/player_local_source.dart';
import '../../data/repositories/player_repository.dart';

// ─── PROVIDERS ─────────────────────────────────────────────────────────────

/// Provider for the local source (lazy singleton).
final playerLocalSourceProvider = Provider<PlayerLocalSource>((ref) {
  return PlayerLocalSource();
});

/// Provider for the repository.
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository(ref.read(playerLocalSourceProvider));
});

/// Main player state notifier provider.
final playerProvider =
    NotifierProvider<PlayerNotifier, Player>(PlayerNotifier.new);

/// Derived: XP progress fraction (0.0 – 1.0).
final xpProgressProvider = Provider<double>((ref) {
  final player = ref.watch(playerProvider);
  return player.xpProgress;
});

/// Derived: XP text display.
final xpDisplayProvider = Provider<String>((ref) {
  final player = ref.watch(playerProvider);
  return '${player.xp} / ${player.xpToNextLevel} XP';
});

// ─── NOTIFIER ──────────────────────────────────────────────────────────────

class PlayerNotifier extends Notifier<Player> {
  @override
  Player build() {
    return Player.newPlayer(uid: 'loading');
  }

  /// Initialize: load from Hive or create new.
  Future<void> init() async {
    final repo = ref.read(playerRepositoryProvider);
    await repo.init();
    final player = await repo.loadOrCreatePlayer();
    state = player;
  }

  /// Award XP for a quick action.
  void awardXp(QuickAction action) {
    final updated = state.addXp(action.xpReward);
    state = updated;
    _persist();
  }

  /// Award arbitrary XP amount.
  void addXp(int amount) {
    final updated = state.addXp(amount);
    state = updated;
    _persist();
  }

  /// Update display name.
  void setDisplayName(String name) {
    state = state.copyWith(displayName: name);
    _persist();
  }

  /// Update daily water target.
  void setWaterTarget(int ml) {
    state = state.copyWith(dailyWaterTarget: ml);
    _persist();
  }

  /// Update step goal.
  void setStepGoal(int steps) {
    state = state.copyWith(stepGoal: steps);
    _persist();
  }

  /// Increment streak.
  void qualifyStreak() {
    state = state.updateStreak(qualified: true);
    _persist();
  }

  /// Reset streak.
  void breakStreak() {
    state = state.updateStreak(qualified: false);
    _persist();
  }

  Future<void> _persist() async {
    final repo = ref.read(playerRepositoryProvider);
    await repo.savePlayer(state);
  }
}
