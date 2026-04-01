import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants.dart';
import '../../features/player/player_state.dart';
import '../../features/workouts/workout_state.dart';
import '../../features/water/water_state.dart';
import '../widgets/glass_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final workouts = ref.watch(workoutListProvider);
    final waterLog = ref.watch(waterProvider);

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AgionSpacing.md),
                child: ShaderMask(
                  shaderCallback: (b) =>
                      AgionColors.accentGradient.createShader(b),
                  child: const Text(
                    'STATS',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AgionSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ─── HERO STATS GRID ──────────────────────────────
                  _buildHeroStats(player, workouts.length),

                  const SizedBox(height: AgionSpacing.md),

                  // ─── WORKOUT FREQUENCY CHART ──────────────────────
                  _sectionHeader('WORKOUT FREQUENCY (LAST 8 WEEKS)'),
                  GlassCard(
                    showGlow: true,
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: SizedBox(
                      height: 180,
                      child: _buildWorkoutBarChart(workouts),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0.0, delay: 200.ms),

                  const SizedBox(height: AgionSpacing.md),

                  // ─── XP EARNED CHART ──────────────────────────────
                  _sectionHeader('RANK PROGRESS'),
                  GlassCard(
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: _buildRankProgress(player),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0.0, delay: 300.ms),

                  const SizedBox(height: AgionSpacing.md),

                  // ─── STREAK HEATMAP ───────────────────────────────
                  _sectionHeader('ACTIVITY HEATMAP (LAST 12 WEEKS)'),
                  GlassCard(
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: _buildHeatmap(workouts),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0.0, delay: 400.ms),

                  const SizedBox(height: AgionSpacing.md),

                  // ─── TODAY'S WATER ────────────────────────────────
                  _sectionHeader('HYDRATION TODAY'),
                  GlassCard(
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: _buildWaterStat(waterLog.consumed, waterLog.target),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: AgionSpacing.md),

                  // ─── WORKOUT BREAKDOWN ────────────────────────────
                  _sectionHeader('WORKOUT BREAKDOWN'),
                  GlassCard(
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: Column(
                      children: [
                        _statPair('Total Workouts', '${workouts.length}',
                            'Total Exercises',
                            '${workouts.fold<int>(0, (s, w) => s + w.exercises.length)}'),
                        const SizedBox(height: AgionSpacing.sm),
                        _statPair(
                          'Total Sets',
                          '${workouts.fold<int>(0, (s, w) => s + w.exercises.fold<int>(0, (ss, e) => ss + e.sets.length))}',
                          'Avg per Session',
                          workouts.isEmpty
                              ? '0'
                              : '${(workouts.fold<int>(0, (s, w) => s + w.exercises.length) / workouts.length).toStringAsFixed(1)}',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: AgionSpacing.xl * 2),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HERO STATS GRID ─────────────────────────────────────────────────────

  Widget _buildHeroStats(player, int workoutCount) {
    final stats = [
      ('LV ${player.level}', '${player.rank}-Rank', AgionColors.neonCyan),
      ('${player.streak}', 'Day Streak 🔥', Colors.orange),
      ('$workoutCount', 'Workouts', AgionColors.neonViolet),
      ('${player.xp}', 'XP Earned', Colors.amber),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AgionSpacing.sm,
      crossAxisSpacing: AgionSpacing.sm,
      childAspectRatio: 2.0,
      children: stats.asMap().entries.map((e) {
        final delay = Duration(milliseconds: e.key * 80);
        return GlassCard(
          showGlow: e.key == 0,
          padding: const EdgeInsets.all(AgionSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                e.value.$1,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: e.value.$3,
                ),
              ),
              Text(
                e.value.$2,
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 12,
                  color: AgionColors.mutedText,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: delay).scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              delay: delay,
              duration: 400.ms,
              curve: Curves.elasticOut,
            );
      }).toList(),
    );
  }

  // ─── WORKOUT BAR CHART ───────────────────────────────────────────────────

  Widget _buildWorkoutBarChart(workouts) {
    // Group by week (last 8 weeks)
    final now = DateTime.now();
    final List<int> weeklyCounts = List.filled(8, 0);

    for (final w in workouts) {
      final diff = now.difference(w.date).inDays;
      final weekIndex = diff ~/ 7;
      if (weekIndex < 8) {
        weeklyCounts[7 - weekIndex]++;
      }
    }

    final bars = weeklyCounts.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            gradient: const LinearGradient(
              colors: [AgionColors.neonViolet, AgionColors.neonCyan],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: (weeklyCounts.reduce((a, b) => a > b ? a : b) + 1)
                  .toDouble()
                  .clamp(3.0, 20.0),
              color: AgionColors.white.withValues(alpha: 0.04),
            ),
          ),
        ],
      );
    }).toList();

    final maxY = (weeklyCounts.reduce((a, b) => a > b ? a : b) + 1)
        .toDouble()
        .clamp(3.0, 20.0);

    return BarChart(
      BarChartData(
        barGroups: bars,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: AgionColors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}',
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 10,
                  color: AgionColors.mutedText,
                ),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, _) {
                final weekLabel = 'W${v.toInt() + 1}';
                return Text(
                  weekLabel,
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 10,
                    color: AgionColors.mutedText,
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AgionColors.backgroundDeep,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              '${rod.toY.toInt()} workouts',
              const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 12,
                color: AgionColors.neonCyan,
              ),
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 800),
    );
  }

  // ─── RANK PROGRESS ───────────────────────────────────────────────────────

  Widget _buildRankProgress(player) {
    const ranks = ['E', 'D', 'C', 'B', 'A', 'S'];
    final currentIdx = ranks.indexOf(player.rank);

    return Column(
      children: ranks.asMap().entries.map((e) {
        final rank = e.value;
        final isReached = e.key <= currentIdx;
        final isCurrent = e.key == currentIdx;
        final threshold = RankConfig.rankThresholds[rank] ?? 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  rank,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isCurrent
                        ? AgionColors.neonCyan
                        : isReached
                            ? Colors.green
                            : AgionColors.mutedText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: isReached ? 1.0 : 0.0,
                    minHeight: 6,
                    backgroundColor: AgionColors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCurrent
                          ? AgionColors.neonCyan
                          : isReached
                              ? Colors.green
                              : Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LV $threshold',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 10,
                  color: isReached
                      ? AgionColors.mutedText
                      : AgionColors.mutedText.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── HEATMAP ─────────────────────────────────────────────────────────────

  Widget _buildHeatmap(workouts) {
    final now = DateTime.now();
    final Map<String, int> dayMap = {};

    for (final w in workouts) {
      final key = '${w.date.year}-${w.date.month}-${w.date.day}';
      dayMap[key] = (dayMap[key] ?? 0) + 1;
    }

    // Generate 12 weeks × 7 days
    final cells = <Widget>[];
    for (int week = 11; week >= 0; week--) {
      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: week * 7 + day));
        final key = '${date.year}-${date.month}-${date.day}';
        final count = dayMap[key] ?? 0;
        final intensity = count == 0
            ? 0.0
            : count == 1
                ? 0.35
                : count == 2
                    ? 0.65
                    : 1.0;
        cells.add(Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: intensity == 0
                ? AgionColors.white.withValues(alpha: 0.05)
                : AgionColors.neonCyan.withValues(alpha: intensity),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Less',
                style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 10,
                    color: AgionColors.mutedText)),
            const SizedBox(width: 4),
            ...const [0.0, 0.35, 0.65, 1.0].map((a) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: a == 0
                        ? AgionColors.white.withValues(alpha: 0.05)
                        : AgionColors.neonCyan.withValues(alpha: a),
                  ),
                )),
            const SizedBox(width: 4),
            const Text('More',
                style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 10,
                    color: AgionColors.mutedText)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          direction: Axis.vertical,
          children: cells,
        ),
      ],
    );
  }

  // ─── WATER STAT ──────────────────────────────────────────────────────────

  Widget _buildWaterStat(int consumed, int target) {
    final progress = (consumed / target).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('💧 Today',
                style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 16,
                    color: AgionColors.white)),
            Text(
              '$consumed / $target ml',
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AgionColors.neonCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AgionColors.white.withValues(alpha: 0.08),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AgionColors.neonCyan),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% of daily goal',
          style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 13,
              color: AgionColors.mutedText),
        ),
      ],
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.only(bottom: AgionSpacing.sm),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AgionColors.mutedText,
            letterSpacing: 2,
          ),
        ),
      );

  Widget _statPair(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(child: _miniStatCard(l1, v1)),
        const SizedBox(width: AgionSpacing.sm),
        Expanded(child: _miniStatCard(l2, v2)),
      ],
    );
  }

  Widget _miniStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AgionSpacing.sm),
      decoration: BoxDecoration(
        color: AgionColors.white.withValues(alpha: 0.03),
        borderRadius: AgionRadius.smallBR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AgionColors.neonCyan,
              )),
          Text(label,
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 11,
                color: AgionColors.mutedText,
              )),
        ],
      ),
    );
  }
}
