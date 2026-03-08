import 'package:hive/hive.dart';
import '../../domain/models/player.dart';

/// Local data source for Player using Hive.
class PlayerLocalSource {
  static const String _boxName = 'player_box';
  static const String _playerKey = 'current_player';

  late Box<Player> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Player>(_boxName);
  }

  /// Get the current player, or null if none exists.
  Player? getPlayer() {
    return _box.get(_playerKey);
  }

  /// Save the player to local storage.
  Future<void> savePlayer(Player player) async {
    await _box.put(_playerKey, player);
  }

  /// Delete local player data.
  Future<void> deletePlayer() async {
    await _box.delete(_playerKey);
  }

  /// Check if a player exists locally.
  bool hasPlayer() {
    return _box.containsKey(_playerKey);
  }
}
