import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../domain/models/player.dart';
import '../../features/player/player_state.dart';
import '../widgets/xp_ring_widget.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/rank_badge_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/system_toast.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _previousLevel = 1;

  @override
  void initState() {
    super.initState();
    // Initialize player state from Hive
    Future.microtask(() {
      ref.read(playerProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final xpProgress = ref.watch(xpProgressProvider);
    final xpDisplay = ref.watch(xpDisplayProvider);

    // Detect level-up
    if (player.level > _previousLevel && _previousLevel > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLevelUpEffect(player.level, player.rank);
      });
    }
    _previousLevel = player.level;

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            // ─── TOP STATUS BAR ──────────────────────────────────────
            _buildStatusBar(player),

            // ─── MAIN CONTENT ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AgionSpacing.md,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AgionSpacing.lg),

                    // XP Ring
                    Center(
                      child: XpRingWidget(
                        progress: xpProgress,
                        level: player.level,
                        rank: player.rank,
                        xpText: xpDisplay,
                        size: 220,
                        onTap: () => _showPlayerDetails(player),
                      ),
                    ),

                    const SizedBox(height: AgionSpacing.sm),

                    // Title text
                    Text(
                      player.title.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AgionColors.neonCyan.withValues(alpha: 0.7),
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: AgionSpacing.xl),

                    // System message
                    _buildSystemMessage(),

                    const SizedBox(height: AgionSpacing.lg),

                    // ─── QUICK ACTION GRID (2×3) ─────────────────────
                    _buildQuickActionGrid(),

                    const SizedBox(height: AgionSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATUS BAR ───────────────────────────────────────────────────────

  Widget _buildStatusBar(Player player) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(
        AgionSpacing.md,
        AgionSpacing.sm,
        AgionSpacing.md,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AgionSpacing.md,
        vertical: AgionSpacing.sm,
      ),
      child: Row(
        children: [
          RankBadgeWidget(rank: player.rank, size: 36),
          const SizedBox(width: AgionSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AgionColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'LV ${player.level} • ${player.rank}-Rank',
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AgionColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          // Streak indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AgionSpacing.sm,
              vertical: AgionSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AgionColors.white06,
              borderRadius: AgionRadius.smallBR,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${player.streak}',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AgionColors.neonCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SYSTEM MESSAGE ──────────────────────────────────────────────────

  Widget _buildSystemMessage() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AgionSpacing.md,
        vertical: AgionSpacing.sm,
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AgionColors.accentGradient.createShader(bounds),
            child: const Text(
              'SYSTEM',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: AgionSpacing.sm),
          const Expanded(
            child: Text(
              'Complete a workout to gain +50 XP',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AgionColors.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── QUICK ACTION GRID ──────────────────────────────────────────────

  Widget _buildQuickActionGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AgionSpacing.sm,
      crossAxisSpacing: AgionSpacing.sm,
      childAspectRatio: 0.92,
      children: QuickAction.values.map((action) {
        return QuickActionButton(
          action: action,
          onTap: () => _onQuickAction(action),
        );
      }).toList(),
    );
  }



  // ─── ACTIONS ─────────────────────────────────────────────────────────

  void _onQuickAction(QuickAction action) {
    ref.read(playerProvider.notifier).awardXp(action);
    SystemToast.show(
      context,
      '${action.label} complete! +${action.xpReward} XP',
    );
  }

  void _showLevelUpEffect(int level, String rank) {
    SystemToast.show(context, 'LEVEL UP! You are now LV $level ($rank-Rank)');
  }

  void _showPlayerDetails(Player player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlayerDetailSheet(player: player),
    );
  }
}

// ─── PLAYER DETAIL BOTTOM SHEET ────────────────────────────────────────────

class _PlayerDetailSheet extends StatelessWidget {
  final Player player;

  const _PlayerDetailSheet({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AgionSpacing.lg),
      decoration: const BoxDecoration(
        color: AgionColors.backgroundDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AgionColors.neonCyan, width: 0.5),
          left: BorderSide(color: AgionColors.neonCyan, width: 0.5),
          right: BorderSide(color: AgionColors.neonCyan, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AgionColors.mutedText,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AgionSpacing.lg),
          Text(
            'PLAYER STATUS',
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AgionColors.neonCyan,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AgionSpacing.lg),
          _infoRow('Name', player.displayName),
          _infoRow('Level', 'LV ${player.level}'),
          _infoRow('Rank', '${player.rank}-Rank'),
          _infoRow('Title', player.title),
          _infoRow('XP', '${player.xp} / ${player.xpToNextLevel}'),
          _infoRow('Streak', '${player.streak} days'),
          _infoRow('Water Goal', '${player.dailyWaterTarget} ml'),
          _infoRow('Step Goal', '${player.stepGoal} steps'),
          const SizedBox(height: AgionSpacing.lg),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AgionSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AgionColors.mutedText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AgionColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
