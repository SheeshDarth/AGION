import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/water_log.dart';
import '../../data/local/water_local_source.dart';
import '../player/player_state.dart';
import '../../core/constants.dart';

// ─── PROVIDERS ─────────────────────────────────────────────────────────────

final waterLocalSourceProvider = Provider<WaterLocalSource>((ref) {
  return WaterLocalSource();
});

final waterProvider =
    NotifierProvider<WaterNotifier, WaterLog>(WaterNotifier.new);

/// Derived: progress fraction.
final waterProgressProvider = Provider<double>((ref) {
  return ref.watch(waterProvider).progress;
});

/// Derived: goal reached.
final waterGoalReachedProvider = Provider<bool>((ref) {
  return ref.watch(waterProvider).goalReached;
});

// ─── NOTIFIER ──────────────────────────────────────────────────────────────

class WaterNotifier extends Notifier<WaterLog> {
  bool _goalAlreadyRewarded = false;

  @override
  WaterLog build() => WaterLog.today();

  Future<void> init() async {
    final source = ref.read(waterLocalSourceProvider);
    await source.init();
    final playerState = ref.read(playerProvider);
    final log = source.getOrCreateToday(target: playerState.dailyWaterTarget);
    _goalAlreadyRewarded = log.goalReached;
    state = log;
  }

  /// Add water intake in ml.
  Future<void> addWater(int ml) async {
    final wasGoalReached = state.goalReached;
    state = state.addWater(ml);

    // Persist
    final source = ref.read(waterLocalSourceProvider);
    await source.save(state);

    // Award XP when goal first reached
    if (!wasGoalReached && state.goalReached && !_goalAlreadyRewarded) {
      _goalAlreadyRewarded = true;
      ref.read(playerProvider.notifier).awardXp(QuickAction.water);
    }
  }

  /// Reset for a new day (called on app open if date changed).
  Future<void> checkDayReset() async {
    final source = ref.read(waterLocalSourceProvider);
    final playerState = ref.read(playerProvider);
    final today = source.getOrCreateToday(target: playerState.dailyWaterTarget);
    if (today.date != state.date) {
      _goalAlreadyRewarded = today.goalReached;
      state = today;
    }
  }
}
