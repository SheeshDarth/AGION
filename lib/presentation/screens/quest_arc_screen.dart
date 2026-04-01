import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../domain/models/quest_arc.dart';
import '../../features/quest_arcs/arc_state.dart';
import '../widgets/glass_card.dart';
import 'arc_detail_screen.dart';

/// Quest Arc browser — shows all available arcs and active progress.
class QuestArcScreen extends ConsumerStatefulWidget {
  const QuestArcScreen({super.key});

  @override
  ConsumerState<QuestArcScreen> createState() => _QuestArcScreenState();
}

class _QuestArcScreenState extends ConsumerState<QuestArcScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(arcProgressProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(arcCatalogProvider);
    final progress = ref.watch(arcProgressProvider);
    final activeArc = ref.watch(activeArcProvider);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AgionColors.accentGradient.createShader(bounds),
                      child: const Text(
                        'QUEST ARCS',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Themed workout programs. Pick your arc.',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 14,
                        color: AgionColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active arc banner
            if (activeArc != null)
              SliverToBoxAdapter(
                child: _buildActiveArcBanner(activeArc, catalog),
              ),

            // Arc grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AgionSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final arc = catalog[index];
                    final arcProgress = progress[arc.id];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AgionSpacing.md),
                      child: _buildArcCard(arc, arcProgress),
                    );
                  },
                  childCount: catalog.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AgionSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveArcBanner(
      ArcProgress activeArc, List<QuestArc> catalog) {
    final arc = catalog.firstWhere((a) => a.id == activeArc.arcId);
    final phase = arc.phases[activeArc.currentPhase];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AgionSpacing.md, 0, AgionSpacing.md, AgionSpacing.md),
      child: GestureDetector(
        onTap: () => _openArcDetail(arc, activeArc),
        child: Container(
          padding: const EdgeInsets.all(AgionSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AgionColors.neonViolet.withValues(alpha: 0.15),
                AgionColors.neonCyan.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: AgionRadius.cardBR,
            border:
                Border.all(color: AgionColors.neonCyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AgionSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AgionColors.neonCyan.withValues(alpha: 0.2),
                      borderRadius: AgionRadius.smallBR,
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AgionColors.neonCyan,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${arc.emoji} ${arc.theme}',
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 12,
                      color: AgionColors.mutedText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AgionSpacing.sm),
              Text(
                arc.name,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AgionColors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Phase: ${phase.name} • Day ${activeArc.completedDays + 1}',
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AgionColors.neonCyan,
                ),
              ),
              const SizedBox(height: AgionSpacing.sm),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: activeArc.progressFraction,
                  minHeight: 6,
                  backgroundColor: AgionColors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AgionColors.neonCyan),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(activeArc.progressFraction * 100).toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 11,
                      color: AgionColors.mutedText,
                    ),
                  ),
                  Text(
                    '${arc.xpMultiplier}× XP',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArcCard(QuestArc arc, ArcProgress? arcProgress) {
    final isActive = arcProgress != null && !arcProgress.isComplete;
    final isComplete = arcProgress?.isComplete ?? false;

    return GestureDetector(
      onTap: () => _openArcDetail(arc, arcProgress),
      child: GlassCard(
        showGlow: isActive,
        padding: const EdgeInsets.all(AgionSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: emoji + theme + difficulty
            Row(
              children: [
                Text(arc.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: AgionSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arc.name,
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AgionColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        arc.theme,
                        style: const TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 12,
                          color: AgionColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDifficultyBadge(arc.difficulty),
              ],
            ),

            const SizedBox(height: AgionSpacing.sm),

            // Description
            Text(
              arc.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 13,
                color: AgionColors.mutedText,
                height: 1.3,
              ),
            ),

            const SizedBox(height: AgionSpacing.md),

            // Stats row
            Row(
              children: [
                _buildStatChip(
                    '${arc.durationWeeks}w', Icons.calendar_today, 10),
                const SizedBox(width: AgionSpacing.sm),
                _buildStatChip(
                    '${arc.phases.length} phases', Icons.layers, 10),
                const SizedBox(width: AgionSpacing.sm),
                _buildStatChip(
                    '${arc.xpMultiplier}× XP', Icons.bolt, 10),
                const Spacer(),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: AgionRadius.smallBR,
                    ),
                    child: const Text(
                      '✅ COMPLETE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (arc.bossFight != null && !isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AgionColors.danger.withValues(alpha: 0.15),
                      borderRadius: AgionRadius.smallBR,
                    ),
                    child: Text(
                      '🏴 BOSS +${arc.bossFight!.bonusXp}XP',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: AgionColors.danger,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    final color = _difficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AgionRadius.smallBR,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$difficulty-Rank',
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'S':
        return Colors.red;
      case 'A':
        return Colors.orange;
      case 'B':
        return AgionColors.neonViolet;
      case 'C':
        return AgionColors.neonCyan;
      case 'D':
        return Colors.green;
      default:
        return AgionColors.mutedText;
    }
  }

  Widget _buildStatChip(String label, IconData icon, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AgionColors.mutedText),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AgionColors.mutedText,
          ),
        ),
      ],
    );
  }

  void _openArcDetail(QuestArc arc, ArcProgress? progress) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArcDetailScreen(arc: arc, progress: progress),
      ),
    );
  }
}
