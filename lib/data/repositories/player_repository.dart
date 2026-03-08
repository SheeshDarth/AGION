import '../../domain/models/player.dart';
import '../local/player_local_source.dart';

/// Repository for Player data.
/// Currently wraps local source; will add remote (Firestore) source later.
class PlayerRepository {
  final PlayerLocalSource _localSource;

  PlayerRepository(this._localSource);

  Future<void> init() => _localSource.init();

  Player? getPlayer() => _localSource.getPlayer();

  Future<void> savePlayer(Player player) => _localSource.savePlayer(player);

  Future<void> deletePlayer() => _localSource.deletePlayer();

  bool hasPlayer() => _localSource.hasPlayer();

  /// Load existing player or create a new one.
  Future<Player> loadOrCreatePlayer({String? uid, String? displayName}) async {
    final existing = getPlayer();
    if (existing != null) return existing;

    final newPlayer = Player.newPlayer(
      uid: uid ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
      displayName: displayName ?? 'Hunter',
    );
    await savePlayer(newPlayer);
    return newPlayer;
  }
}
