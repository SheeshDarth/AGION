import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../domain/models/quest_arc.dart';
import '../../features/quest_arcs/arc_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/xp_gain_overlay.dart';

/// Detail screen for a single Quest Arc — phases, exercises, boss fight.
class ArcDetailScreen extends ConsumerWidget {
  final QuestArc arc;
  final ArcProgress? progress;

  const ArcDetailScreen({
    super.key,
    required this.arc,
    this.progress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live progress
    final liveProgress = ref.watch(arcProgressProvider)[arc.id] ?? progress;
    final isStarted = liveProgress != null;
    final isComplete = liveProgress?.isComplete ?? false;

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _themeColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios,
                              color: AgionColors.mutedText, size: 20),
                        ),
                        const SizedBox(width: AgionSpacing.sm),
                        Expanded(
                          child: Text(
                            arc.theme.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AgionColors.mutedText,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        if (isStarted && !isComplete)
                          GestureDetector(
                            onTap: () => _confirmAbandon(context, ref),
                            child: const Text(
                              'ABANDON',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AgionColors.danger,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Hero header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AgionSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(arc.emoji, style: const TextStyle(fontSize: 42)),
                        const SizedBox(height: AgionSpacing.sm),
                        Text(
                          arc.name,
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AgionColors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: AgionSpacing.sm),
                        Text(
                          arc.description,
                          style: const TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 14,
                            color: AgionColors.mutedText,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AgionSpacing.md),
                        // Meta row
                        Row(
                          children: [
                            _metaChip('${arc.durationWeeks} weeks',
                                Icons.calendar_today),
                            const SizedBox(width: AgionSpacing.sm),
                            _metaChip(
                                '${arc.difficulty}-Rank', Icons.shield),
                            const SizedBox(width: AgionSpacing.sm),
                            _metaChip('${arc.xpMultiplier}× XP', Icons.bolt),
                          ],
                        ),
                        const SizedBox(height: AgionSpacing.lg),
                      ],
                    ),
                  ),
                ),

                // Progress bar if started
                if (isStarted && !isComplete)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AgionSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'PROGRESS',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AgionColors.mutedText,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                '${liveProgress.completedDays} workouts done',
                                style: const TextStyle(
                                  fontFamily: 'Rajdhani',
                                  fontSize: 12,
                                  color: AgionColors.neonCyan,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AgionSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: liveProgress.progressFraction,
                              minHeight: 8,
                              backgroundColor:
                                  AgionColors.white.withValues(alpha: 0.1),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_themeColor),
                            ),
                          ),
                          const SizedBox(height: AgionSpacing.lg),
                        ],
                      ),
                    ),
                  ),

                // Phases
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AgionSpacing.md),
                    child: const Text(
                      'PHASES',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AgionColors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AgionSpacing.sm),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AgionSpacing.md, 0, AgionSpacing.md,
                          AgionSpacing.md),
                      child: _buildPhaseCard(
                          arc.phases[index], index, liveProgress),
                    ),
                    childCount: arc.phases.length,
                  ),
                ),

                // Boss fight
                if (arc.bossFight != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AgionSpacing.md, AgionSpacing.sm,
                          AgionSpacing.md, AgionSpacing.md),
                      child:
                          _buildBossFightCard(arc.bossFight!, liveProgress),
                    ),
                  ),

                // Start / Complete day button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: _buildActionButton(context, ref, isStarted,
                        isComplete, liveProgress),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AgionSpacing.xl * 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(
      ArcPhase phase, int index, ArcProgress? progress) {
    final isCurrentPhase = progress != null && progress.currentPhase == index;
    final isPast =
        progress != null && index < progress.currentPhase;

    return GlassCard(
      showGlow: isCurrentPhase,
      padding: const EdgeInsets.all(AgionSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPast
                      ? Colors.green.withValues(alpha: 0.3)
                      : isCurrentPhase
                          ? _themeColor.withValues(alpha: 0.3)
                          : AgionColors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: isPast
                        ? Colors.green
                        : isCurrentPhase
                            ? _themeColor
                            : AgionColors.mutedText.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: isPast
                      ? const Icon(Icons.check, size: 16, color: Colors.green)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isCurrentPhase
                                ? _themeColor
                                : AgionColors.mutedText,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AgionSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.name,
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AgionColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Week ${phase.weekNumber}+ • ${phase.daysPerWeek} days/wk',
                      style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 11,
                        color: AgionColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentPhase)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _themeColor.withValues(alpha: 0.15),
                    borderRadius: AgionRadius.smallBR,
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: _themeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AgionSpacing.sm),
          Text(
            phase.description,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 12,
              color: AgionColors.mutedText,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AgionSpacing.sm),
          // Exercise list
          ...phase.exercises.map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      _exerciseIcon(ex.type),
                      size: 14,
                      color: _themeColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: AgionSpacing.sm),
                    Expanded(
                      child: Text(
                        ex.name,
                        style: const TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AgionColors.white,
                        ),
                      ),
                    ),
                    Text(
                      ex.type == 'cardio' || ex.type == 'flexibility'
                          ? ex.instruction.split('.').first
                          : '${ex.sets}×${ex.reps}',
                      style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 12,
                        color: AgionColors.mutedText,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBossFightCard(BossFight boss, ArcProgress? progress) {
    final bossDefeated = progress?.bossDefeated ?? false;
    return Container(
      padding: const EdgeInsets.all(AgionSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AgionColors.danger.withValues(alpha: 0.12),
            AgionColors.neonViolet.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: AgionRadius.cardBR,
        border:
            Border.all(color: AgionColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏴', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AgionSpacing.sm),
              Expanded(
                child: Text(
                  'BOSS: ${boss.name}',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AgionColors.danger,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (bossDefeated)
                const Text('✅',
                    style: TextStyle(fontSize: 18)),
              if (!bossDefeated)
                Text(
                  '+${boss.bonusXp} XP',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AgionSpacing.sm),
          Text(
            boss.description,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 13,
              color: AgionColors.mutedText,
            ),
          ),
          const SizedBox(height: AgionSpacing.sm),
          ...boss.challenges.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      '${c.name}: ${c.instruction}',
                      style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AgionColors.white,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref,
      bool isStarted, bool isComplete, ArcProgress? progress) {
    if (isComplete) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AgionSpacing.md),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: AgionRadius.cardBR,
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Text(
            '🏆 ARC COMPLETED',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.green,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    if (!isStarted) {
      return GestureDetector(
        onTap: () {
          ref.read(arcProgressProvider.notifier).startArc(arc.id);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AgionSpacing.md),
          decoration: BoxDecoration(
            gradient: AgionColors.accentGradient,
            borderRadius: AgionRadius.cardBR,
          ),
          child: const Center(
            child: Text(
              'START THIS ARC',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AgionColors.backgroundDeep,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      );
    }

    // Active — show complete day / boss fight button
    final allPhasesComplete =
        progress != null && progress.currentPhase >= arc.phases.length - 1;
    final canFightBoss =
        allPhasesComplete && arc.bossFight != null && !progress.bossDefeated;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.read(arcProgressProvider.notifier).completeDay(arc.id);
            // Show XP animation
            final xp = (XpConfig.workoutXp * arc.xpMultiplier).round();
            XpGainOverlay.show(context, xp);
          },
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: AgionSpacing.md),
            decoration: BoxDecoration(
              gradient: AgionColors.accentGradient,
              borderRadius: AgionRadius.cardBR,
            ),
            child: const Center(
              child: Text(
                'COMPLETE TODAY\'S WORKOUT',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AgionColors.backgroundDeep,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
        if (canFightBoss) ...[
          const SizedBox(height: AgionSpacing.md),
          GestureDetector(
            onTap: () {
              ref
                  .read(arcProgressProvider.notifier)
                  .completeBoss(arc.id);
              XpGainOverlay.show(context, arc.bossFight!.bonusXp);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: AgionSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AgionColors.danger,
                    AgionColors.neonViolet,
                  ],
                ),
                borderRadius: AgionRadius.cardBR,
              ),
              child: Center(
                child: Text(
                  '🏴 FIGHT BOSS: ${arc.bossFight!.name.toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color get _themeColor {
    switch (arc.difficulty) {
      case 'S':
        return Colors.red;
      case 'A':
        return Colors.orange;
      case 'B':
        return AgionColors.neonViolet;
      case 'C':
        return AgionColors.neonCyan;
      default:
        return Colors.green;
    }
  }

  IconData _exerciseIcon(String type) {
    switch (type) {
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      case 'endurance':
        return Icons.timer;
      default:
        return Icons.fitness_center;
    }
  }

  Widget _metaChip(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AgionColors.mutedText),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AgionColors.mutedText,
          ),
        ),
      ],
    );
  }

  void _confirmAbandon(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AgionColors.backgroundDeep,
        title: const Text(
          'Abandon Arc?',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AgionColors.white,
          ),
        ),
        content: const Text(
          'All progress will be lost. Are you sure?',
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 14,
            color: AgionColors.mutedText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(color: AgionColors.mutedText)),
          ),
          TextButton(
            onPressed: () {
              ref.read(arcProgressProvider.notifier).abandonArc(arc.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('ABANDON',
                style: TextStyle(color: AgionColors.danger)),
          ),
        ],
      ),
    );
  }
}
