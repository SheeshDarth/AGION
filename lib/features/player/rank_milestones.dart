/// Milestone-based ranking — ranks earned through REAL, measurable progress.
/// Not just XP grinding — actual consistency, volume, and transformation.
class RankMilestones {
  RankMilestones._();

  /// Check all milestone criteria and return the highest earned rank.
  static String calculateRank({
    required int totalWorkouts,
    required int longestStreak,
    required int totalArcDays,
    required int bossesDefeated,
    required int consecutiveWeeks,
    required int totalWaterDays,
  }) {
    // S-Rank: The Shadow Monarch
    // 1+ year of real dedication
    if (totalWorkouts >= 300 &&
        longestStreak >= 60 &&
        bossesDefeated >= 5 &&
        consecutiveWeeks >= 48 &&
        totalArcDays >= 200) {
      return 'S';
    }

    // A-Rank: National Level
    // ~10 months of serious training
    if (totalWorkouts >= 200 &&
        longestStreak >= 45 &&
        bossesDefeated >= 3 &&
        consecutiveWeeks >= 36 &&
        totalArcDays >= 120) {
      return 'A';
    }

    // B-Rank: Elite Hunter
    // ~6 months of consistent training
    if (totalWorkouts >= 120 &&
        longestStreak >= 30 &&
        bossesDefeated >= 2 &&
        consecutiveWeeks >= 20 &&
        totalArcDays >= 60) {
      return 'B';
    }

    // C-Rank: Veteran
    // ~3 months of real work
    if (totalWorkouts >= 60 &&
        longestStreak >= 14 &&
        consecutiveWeeks >= 10 &&
        totalArcDays >= 30) {
      return 'C';
    }

    // D-Rank: Apprentice
    // ~1 month of building habit
    if (totalWorkouts >= 20 &&
        longestStreak >= 7 &&
        consecutiveWeeks >= 3) {
      return 'D';
    }

    // E-Rank: Awakened
    return 'E';
  }

  /// Get human-readable requirements for each rank.
  static List<RankRequirement> requirements(String rank) {
    switch (rank) {
      case 'S':
        return [
          RankRequirement('Total Workouts', 300, '300+ sessions'),
          RankRequirement('Longest Streak', 60, '60-day streak'),
          RankRequirement('Bosses Defeated', 5, '5 boss fights won'),
          RankRequirement('Consistent Weeks', 48, '48+ active weeks'),
          RankRequirement('Arc Training Days', 200, '200+ days in arcs'),
        ];
      case 'A':
        return [
          RankRequirement('Total Workouts', 200, '200+ sessions'),
          RankRequirement('Longest Streak', 45, '45-day streak'),
          RankRequirement('Bosses Defeated', 3, '3 boss fights won'),
          RankRequirement('Consistent Weeks', 36, '36+ active weeks'),
          RankRequirement('Arc Training Days', 120, '120+ days in arcs'),
        ];
      case 'B':
        return [
          RankRequirement('Total Workouts', 120, '120+ sessions'),
          RankRequirement('Longest Streak', 30, '30-day streak'),
          RankRequirement('Bosses Defeated', 2, '2 boss fights won'),
          RankRequirement('Consistent Weeks', 20, '20+ active weeks'),
          RankRequirement('Arc Training Days', 60, '60+ days in arcs'),
        ];
      case 'C':
        return [
          RankRequirement('Total Workouts', 60, '60+ sessions'),
          RankRequirement('Longest Streak', 14, '14-day streak'),
          RankRequirement('Consistent Weeks', 10, '10+ active weeks'),
          RankRequirement('Arc Training Days', 30, '30+ days in arcs'),
        ];
      case 'D':
        return [
          RankRequirement('Total Workouts', 20, '20+ sessions'),
          RankRequirement('Longest Streak', 7, '7-day streak'),
          RankRequirement('Consistent Weeks', 3, '3+ active weeks'),
        ];
      default: // E
        return [
          RankRequirement('Just Start', 1, 'Complete your first workout'),
        ];
    }
  }

  /// Get the next rank the user should aim for.
  static String nextRank(String currentRank) {
    const order = ['E', 'D', 'C', 'B', 'A', 'S'];
    final idx = order.indexOf(currentRank);
    if (idx >= order.length - 1) return 'S';
    return order[idx + 1];
  }
}

class RankRequirement {
  final String label;
  final int target;
  final String description;

  const RankRequirement(this.label, this.target, this.description);
}
