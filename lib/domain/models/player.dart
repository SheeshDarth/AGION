import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../../core/constants.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends Equatable {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final int level;

  @HiveField(2)
  final int xp;

  @HiveField(3)
  final String rank;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final int streak;

  @HiveField(6)
  final DateTime lastActive;

  @HiveField(7)
  final String displayName;

  @HiveField(8)
  final int dailyWaterTarget; // ml

  @HiveField(9)
  final int stepGoal;

  const Player({
    required this.uid,
    this.level = 1,
    this.xp = 0,
    this.rank = 'E',
    this.title = 'Awakened',
    this.streak = 0,
    required this.lastActive,
    this.displayName = 'Hunter',
    this.dailyWaterTarget = 3000,
    this.stepGoal = 8000,
  });

  /// XP required to go from current [level] to next level.
  int get xpToNextLevel => XpConfig.xpForLevel(level);

  /// Progress fraction 0.0 → 1.0 within current level.
  double get xpProgress => xp / xpToNextLevel;

  /// Returns a new Player instance with XP added.
  /// Handles level-ups and rank recalculation.
  Player addXp(int amount) {
    int newXp = xp + amount;
    int newLevel = level;
    String newRank = rank;
    String newTitle = title;

    // Process all possible level-ups
    while (newXp >= XpConfig.xpForLevel(newLevel)) {
      newXp -= XpConfig.xpForLevel(newLevel);
      newLevel++;
    }

    // Recalculate rank
    newRank = RankConfig.rankForLevel(newLevel);

    // Update title based on rank
    newTitle = _titleForRank(newRank, newLevel);

    return copyWith(
      xp: newXp,
      level: newLevel,
      rank: newRank,
      title: newTitle,
    );
  }

  /// Update streak: increment if qualified today, reset if missed.
  Player updateStreak({required bool qualified}) {
    if (qualified) {
      return copyWith(
        streak: streak + 1,
        lastActive: DateTime.now(),
      );
    }
    return copyWith(streak: 0, lastActive: DateTime.now());
  }

  Player copyWith({
    String? uid,
    int? level,
    int? xp,
    String? rank,
    String? title,
    int? streak,
    DateTime? lastActive,
    String? displayName,
    int? dailyWaterTarget,
    int? stepGoal,
  }) {
    return Player(
      uid: uid ?? this.uid,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      rank: rank ?? this.rank,
      title: title ?? this.title,
      streak: streak ?? this.streak,
      lastActive: lastActive ?? this.lastActive,
      displayName: displayName ?? this.displayName,
      dailyWaterTarget: dailyWaterTarget ?? this.dailyWaterTarget,
      stepGoal: stepGoal ?? this.stepGoal,
    );
  }

  static String _titleForRank(String rank, int level) {
    switch (rank) {
      case 'S':
        return 'Shadow Monarch';
      case 'A':
        return 'National Level';
      case 'B':
        return 'Elite Hunter';
      case 'C':
        return 'Veteran';
      case 'D':
        return 'Apprentice';
      default:
        return 'Awakened';
    }
  }

  /// Factory to create a default new player.
  factory Player.newPlayer({required String uid, String displayName = 'Hunter'}) {
    return Player(
      uid: uid,
      lastActive: DateTime.now(),
      displayName: displayName,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        level,
        xp,
        rank,
        title,
        streak,
        lastActive,
        displayName,
        dailyWaterTarget,
        stepGoal,
      ];
}
