import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../domain/models/quest_arc.dart';
import '../../domain/catalog/quest_arc_catalog.dart';
import '../../data/local/arc_local_source.dart';
import '../../features/profile/fitness_profile_state.dart';
import '../player/player_state.dart';
import 'adaptive_arc_engine.dart';

// ─── PROVIDERS ─────────────────────────────────────────────────────────────

/// All available Quest Arcs, adaptively scaled to user's fitness profile.
final arcCatalogProvider = Provider<List<QuestArc>>((ref) {
  final profile = ref.watch(fitnessProfileProvider);
  return QuestArcCatalog.all
      .map((arc) => AdaptiveArcEngine.scaleArc(arc, profile))
      .toList();
});

/// Local source for arc progress persistence.
final arcLocalSourceProvider = Provider<ArcLocalSource>((ref) {
  return ArcLocalSource();
});

/// Main arc progress state: `Map<arcId, ArcProgress>`.
final arcProgressProvider =
    NotifierProvider<ArcProgressNotifier, Map<String, ArcProgress>>(
        ArcProgressNotifier.new);

/// Derived: currently active arc (first non-complete arc).
final activeArcProvider = Provider<ArcProgress?>((ref) {
  final allProgress = ref.watch(arcProgressProvider);
  try {
    return allProgress.values.firstWhere((p) => !p.isComplete);
  } catch (_) {
    return null;
  }
});

// ─── NOTIFIER ──────────────────────────────────────────────────────────────

class ArcProgressNotifier extends Notifier<Map<String, ArcProgress>> {
  @override
  Map<String, ArcProgress> build() => {};

  /// Load all arc progress from Hive.
  Future<void> init() async {
    final source = ref.read(arcLocalSourceProvider);
    final allProgress = await source.getAllProgress();
    state = {for (final p in allProgress) p.arcId: p};
  }

  /// Start a new Quest Arc.
  Future<void> startArc(String arcId) async {
    final progress = ArcProgress(
      arcId: arcId,
      startedAt: DateTime.now(),
    );
    state = {...state, arcId: progress};
    await ref.read(arcLocalSourceProvider).saveProgress(progress);
  }

  /// Complete a workout day in the active arc.
  Future<void> completeDay(String arcId) async {
    final current = state[arcId];
    if (current == null || current.isComplete) return;

    // Find the arc to determine phases
    final catalog = ref.read(arcCatalogProvider);
    final arc = catalog.firstWhere((a) => a.id == arcId);

    final newCompletedDays = current.completedDays + 1;
    final currentPhase = current.currentPhase;
    final phase = arc.phases[currentPhase];
    final newDay = current.currentDay + 1;

    // Check if we need to advance to next phase
    int nextPhase = currentPhase;
    int nextDay = newDay;
    if (newDay >= phase.daysPerWeek *
        (currentPhase < arc.phases.length - 1
            ? (arc.phases[currentPhase + 1].weekNumber -
                arc.phases[currentPhase].weekNumber)
            : 2)) {
      // Advance phase if not at last
      if (currentPhase < arc.phases.length - 1) {
        nextPhase = currentPhase + 1;
        nextDay = 0;
      }
    }

    final updated = current.copyWith(
      currentPhase: nextPhase,
      currentDay: nextDay,
      completedDays: newCompletedDays,
      workoutDates: [...current.workoutDates, DateTime.now()],
    );

    state = {...state, arcId: updated};
    await ref.read(arcLocalSourceProvider).saveProgress(updated);

    // Award XP with multiplier
    final xpEarned = (XpConfig.workoutXp * arc.xpMultiplier).round();
    ref.read(playerProvider.notifier).addXp(xpEarned);
  }

  /// Complete the boss fight.
  Future<void> completeBoss(String arcId) async {
    final current = state[arcId];
    if (current == null) return;

    final catalog = ref.read(arcCatalogProvider);
    final arc = catalog.firstWhere((a) => a.id == arcId);

    final updated = current.copyWith(
      bossDefeated: true,
      completedAt: DateTime.now(),
    );

    state = {...state, arcId: updated};
    await ref.read(arcLocalSourceProvider).saveProgress(updated);

    // Award boss XP
    if (arc.bossFight != null) {
      ref.read(playerProvider.notifier).addXp(arc.bossFight!.bonusXp);
    }
  }

  /// Abandon/reset an arc.
  Future<void> abandonArc(String arcId) async {
    final newState = Map<String, ArcProgress>.from(state);
    newState.remove(arcId);
    state = newState;
    await ref.read(arcLocalSourceProvider).deleteProgress(arcId);
  }
}
