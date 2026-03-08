import 'package:flutter_test/flutter_test.dart';
import 'package:agion/domain/models/player.dart';
import 'package:agion/core/constants.dart';

void main() {
  group('XpConfig', () {
    test('xpForLevel returns 100 for level 1', () {
      expect(XpConfig.xpForLevel(1), 100);
    });

    test('xpForLevel returns 150 for level 2', () {
      expect(XpConfig.xpForLevel(2), 150);
    });

    test('xpForLevel returns 200 for level 3', () {
      expect(XpConfig.xpForLevel(3), 200);
    });

    test('xpForLevel follows linear formula baseXP + (n-1)*50', () {
      for (int n = 1; n <= 20; n++) {
        expect(XpConfig.xpForLevel(n), 100 + (n - 1) * 50);
      }
    });
  });

  group('Player.addXp', () {
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
      final updated = player.addXp(50);
      expect(updated.level, 1);
      expect(updated.xp, 50);
    });

    test('adding XP at exact threshold levels up', () {
      final updated = player.addXp(100); // xpForLevel(1) = 100
      expect(updated.level, 2);
      expect(updated.xp, 0);
    });

    test('adding XP above threshold levels up with overflow', () {
      final updated = player.addXp(120); // 100 needed, 20 overflow
      expect(updated.level, 2);
      expect(updated.xp, 20);
    });

    test('multi-level up with large XP gain', () {
      // Level 1 needs 100, Level 2 needs 150 → total 250 for 2 level-ups
      final updated = player.addXp(260);
      expect(updated.level, 3);
      expect(updated.xp, 10); // 260 - 100 - 150 = 10
    });

    test('xpProgress returns correct fraction', () {
      final updated = player.addXp(50);
      // Level 1 needs 100 XP, so 50/100 = 0.5
      expect(updated.xpProgress, 0.5);
    });

    test('xpToNextLevel is correct at level 1', () {
      expect(player.xpToNextLevel, 100);
    });

    test('xpToNextLevel increases after level up', () {
      final updated = player.addXp(100); // level up to 2
      expect(updated.xpToNextLevel, 150);
    });
  });

  group('RankConfig', () {
    test('rank is E for level 1-4', () {
      expect(RankConfig.rankForLevel(1), 'E');
      expect(RankConfig.rankForLevel(4), 'E');
    });

    test('rank is D for level 5-9', () {
      expect(RankConfig.rankForLevel(5), 'D');
      expect(RankConfig.rankForLevel(9), 'D');
    });

    test('rank is C for level 10-19', () {
      expect(RankConfig.rankForLevel(10), 'C');
      expect(RankConfig.rankForLevel(19), 'C');
    });

    test('rank is B for level 20-34', () {
      expect(RankConfig.rankForLevel(20), 'B');
      expect(RankConfig.rankForLevel(34), 'B');
    });

    test('rank is A for level 35-49', () {
      expect(RankConfig.rankForLevel(35), 'A');
      expect(RankConfig.rankForLevel(49), 'A');
    });

    test('rank is S for level 50+', () {
      expect(RankConfig.rankForLevel(50), 'S');
      expect(RankConfig.rankForLevel(100), 'S');
    });

    test('Player.addXp updates rank at D threshold', () {
      var p = Player.newPlayer(uid: 'test');
      // Accumulate enough XP to reach level 5
      // L1: 100, L2: 150, L3: 200, L4: 250 → total 700
      p = p.addXp(700);
      expect(p.level, 5);
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

    test('title updates to Apprentice at D-rank', () {
      var p = Player.newPlayer(uid: 'test');
      p = p.addXp(700); // reach level 5 → D rank
      expect(p.title, 'Apprentice');
    });
  });
}
