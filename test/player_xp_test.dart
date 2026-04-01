import 'package:flutter_test/flutter_test.dart';
import 'package:agion/domain/models/player.dart';
import 'package:agion/core/constants.dart';

void main() {
  group('XpConfig — Long-term progression', () {
    test('xpForLevel returns 500 for level 1', () {
      expect(XpConfig.xpForLevel(1), 500);
    });

    test('xpForLevel returns 615 for level 2', () {
      // 500 + 100*(1) + 15*(1)^2 = 500 + 100 + 15 = 615
      expect(XpConfig.xpForLevel(2), 615);
    });

    test('xpForLevel follows quadratic formula', () {
      for (int n = 1; n <= 10; n++) {
        final expected = 500 + 100 * (n - 1) + (15 * (n - 1) * (n - 1)).round();
        expect(XpConfig.xpForLevel(n), expected);
      }
    });

    test('xpForLevel grows significantly at higher levels', () {
      // L10: 500 + 900 + 15*81 = 500+900+1215 = 2615
      expect(XpConfig.xpForLevel(10), 2615);
      // Must be a real grind at high levels
      expect(XpConfig.xpForLevel(50) > 30000, true);
    });

    test('Level 1→2 requires ~10 workouts', () {
      final xpNeeded = XpConfig.xpForLevel(1);
      final workoutsNeeded = (xpNeeded / XpConfig.workoutXp).ceil();
      expect(workoutsNeeded, 10);
    });
  });

  group('Player.addXp — new formula', () {
    late Player player;

    setUp(() {
      player = Player.newPlayer(uid: 'test_uid');
    });

    test('starts at level 1 with 0 XP', () {
      expect(player.level, 1);
      expect(player.xp, 0);
      expect(player.rank, 'E');
    });

    test('adding XP below threshold does not level up', () {
      final updated = player.addXp(200);
      expect(updated.level, 1);
      expect(updated.xp, 200);
    });

    test('adding XP at exact threshold levels up', () {
      final updated = player.addXp(500); // xpForLevel(1) = 500
      expect(updated.level, 2);
      expect(updated.xp, 0);
    });

    test('adding XP above threshold levels up with overflow', () {
      final updated = player.addXp(530); // 500 needed, 30 overflow
      expect(updated.level, 2);
      expect(updated.xp, 30);
    });

    test('multi-level up with large XP gain', () {
      // Level 1 needs 500, Level 2 needs 615 → total 1115 for 2 level-ups
      final updated = player.addXp(1125);
      expect(updated.level, 3);
      expect(updated.xp, 10); // 1125 - 500 - 615 = 10
    });

    test('xpProgress returns correct fraction', () {
      final updated = player.addXp(250);
      // Level 1 needs 500 XP, so 250/500 = 0.5
      expect(updated.xpProgress, 0.5);
    });

    test('xpToNextLevel is correct at level 1', () {
      expect(player.xpToNextLevel, 500);
    });

    test('xpToNextLevel increases after level up', () {
      final updated = player.addXp(500); // level up to 2
      expect(updated.xpToNextLevel, 615);
    });
  });

  group('RankConfig — long-term thresholds', () {
    test('rank is E for level 1-7', () {
      expect(RankConfig.rankForLevel(1), 'E');
      expect(RankConfig.rankForLevel(7), 'E');
    });

    test('rank is D for level 8-19', () {
      expect(RankConfig.rankForLevel(8), 'D');
      expect(RankConfig.rankForLevel(19), 'D');
    });

    test('rank is C for level 20-34', () {
      expect(RankConfig.rankForLevel(20), 'C');
      expect(RankConfig.rankForLevel(34), 'C');
    });

    test('rank is B for level 35-54', () {
      expect(RankConfig.rankForLevel(35), 'B');
      expect(RankConfig.rankForLevel(54), 'B');
    });

    test('rank is A for level 55-74', () {
      expect(RankConfig.rankForLevel(55), 'A');
      expect(RankConfig.rankForLevel(74), 'A');
    });

    test('rank is S for level 75+', () {
      expect(RankConfig.rankForLevel(75), 'S');
      expect(RankConfig.rankForLevel(100), 'S');
    });

    test('Player.addXp updates rank at D threshold (level 8)', () {
      var p = Player.newPlayer(uid: 'test');
      // Sum of xpForLevel(1..7) to reach level 8
      int totalXp = 0;
      for (int i = 1; i <= 7; i++) {
        totalXp += XpConfig.xpForLevel(i);
      }
      p = p.addXp(totalXp);
      expect(p.level, 8);
      expect(p.rank, 'D');
    });
  });

  group('Player streak', () {
    test('updateStreak increments on qualification', () {
      final p = Player.newPlayer(uid: 'test');
      final updated = p.updateStreak(qualified: true);
      expect(updated.streak, 1);
    });

    test('updateStreak resets on disqualification', () {
      final p = Player.newPlayer(uid: 'test').copyWith(streak: 5);
      final updated = p.updateStreak(qualified: false);
      expect(updated.streak, 0);
    });

    test('consecutive qualifications accumulate', () {
      var p = Player.newPlayer(uid: 'test');
      p = p.updateStreak(qualified: true);
      p = p.updateStreak(qualified: true);
      p = p.updateStreak(qualified: true);
      expect(p.streak, 3);
    });
  });

  group('Player titles', () {
    test('default title is Awakened', () {
      final p = Player.newPlayer(uid: 'test');
      expect(p.title, 'Awakened');
    });

    test('title updates to Apprentice at D-rank (level 8)', () {
      var p = Player.newPlayer(uid: 'test');
      int totalXp = 0;
      for (int i = 1; i <= 7; i++) {
        totalXp += XpConfig.xpForLevel(i);
      }
      p = p.addXp(totalXp);
      expect(p.rank, 'D');
      expect(p.title, 'Apprentice');
    });
  });
}
