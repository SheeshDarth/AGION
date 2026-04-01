import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/remote/firestore_sync_service.dart';
import '../auth/auth_state.dart';
import '../player/player_state.dart';

/// Sync status enum.
enum SyncStatus { idle, syncing, synced, error, offline }

/// Sync state.
class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncAt;
  final String? errorMsg;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncAt,
    this.errorMsg,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncAt,
    String? errorMsg,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      errorMsg: errorMsg,
    );
  }
}

// ─── PROVIDER ──────────────────────────────────────────────────────────────

final syncProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => const SyncState();

  /// Sync all data to Firestore.
  Future<void> syncAll() async {
    final auth = ref.read(authProvider);
    if (!auth.isSignedIn || auth.isGuest) return;
    if (!FirestoreSyncService.isAvailable) return;

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      state = state.copyWith(status: SyncStatus.offline);
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing);
    try {
      final uid = auth.uid!;
      final player = ref.read(playerProvider);
      await FirestoreSyncService.syncPlayer(uid, player);
      state = SyncState(
        status: SyncStatus.synced,
        lastSyncAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMsg: 'Sync failed',
      );
    }
  }

  /// Pull player data from Firestore and merge.
  Future<void> pullFromCloud() async {
    final auth = ref.read(authProvider);
    if (!auth.isSignedIn || auth.isGuest) return;
    if (!FirestoreSyncService.isAvailable) return;

    try {
      final cloudPlayer =
          await FirestoreSyncService.fetchPlayer(auth.uid!);
      if (cloudPlayer != null) {
        final localPlayer = ref.read(playerProvider);
        // Cloud wins if higher level/XP
        if (cloudPlayer.level > localPlayer.level ||
            (cloudPlayer.level == localPlayer.level &&
                cloudPlayer.xp > localPlayer.xp)) {
          ref.read(playerProvider.notifier).mergeFromCloud(cloudPlayer);
        }
      }
    } catch (_) {
      // Silently fail
    }
  }
}
