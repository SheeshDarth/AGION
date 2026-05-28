import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../core/engine/xp_engine.dart';
import '../../../core/services/system_event_bus.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/quest_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_nav.dart';
import '../../system/system_text.dart';
import '../../system/system_panel.dart';
import '../../hud/xp_ring.dart';
import '../../hud/stat_panel.dart';
import '../../hud/streak_bar.dart';
import '../../hud/quest_card.dart';
import '../../hud/rank_diamond.dart';
import '../../overlays/level_up_overlay.dart';
import '../../overlays/rank_up_overlay.dart';
import '../../overlays/boss_cleared_overlay.dart';
import '../../overlays/xp_pop.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  late StreamSubscription _levelSub;
  late StreamSubscription _rankSub;
  late StreamSubscription _bossSub;
  late StreamSubscription _xpSub;

  @override
  void initState() {
    super.initState();
    _levelSub = SystemEventBus.instance.onLevelUp.listen((e) {
      if (mounted) LevelUpOverlay.show(context, e.level, e.rank);
    });
    _rankSub = SystemEventBus.instance.onRankUp.listen((e) {
      if (mounted) RankUpOverlay.show(context, e.oldRank, e.newRank);
    });
    _bossSub = SystemEventBus.instance.onBossCleared.listen((e) {
      if (mounted) BossClearedOverlay.show(context, e.title, e.xp);
    });
    _xpSub = SystemEventBus.instance.onXP.listen((e) {
      if (mounted) XPPop.show(context, e.amount, e.pos);
    });
    Future.microtask(() => ref.read(playerProvider.notifier).updateStreak());
  }

  @override
  void dispose() {
    _levelSub.cancel();
    _rankSub.cancel();
    _bossSub.cancel();
    _xpSub.cancel();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1: context.push('/workout'); break;
      case 2: context.push('/nutrition'); break;
      case 3: context.push('/finance'); break;
      case 4: context.push('/ai'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    if (player == null) return const _LoadingView();

    final (level, xpIn, xpNeeded) = XPEngine.progress(player.totalXP);
    final rank = XPEngine.rank(level);
    final todayQuests = ref.watch(todayQuestsProvider);

    final created = player.createdDate;
    final daysSince = DateTime.now().difference(DateTime.parse(created)).inDays + 1;

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── STATUS BAR ────────────────────────────────────────
              SliverToBoxAdapter(child: _buildStatusBar(player.name, rank, player.streakDays, level)),

              // ─── STREAK BANNER ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: StreakBar(
                    streakDays: player.streakDays,
                    todayXP: 0,
                    dailyXPTarget: 500,
                    daysSinceStart: daysSince,
                  ),
                ),
              ),

              // ─── XP RING ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Center(
                        child: XPRing(
                          currentXP: xpIn,
                          xpForLevel: xpNeeded,
                          level: level,
                          rank: rank,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SLText(
                        'NEXT LEVEL IN ${xpNeeded - xpIn} XP',
                        style: SLType.body(size: 12, color: SLColors.textMid),
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // ─── STAT GRID ─────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: StatPanel(label: 'STR', value: XPEngine.strength(0), color: SLColors.rankS)),
                      const SizedBox(width: 8),
                      Expanded(child: StatPanel(label: 'AGI', value: XPEngine.agility(0), color: SLColors.rankD)),
                      const SizedBox(width: 8),
                      Expanded(child: StatPanel(label: 'INT', value: XPEngine.intelligence(0), color: SLColors.rankC)),
                    ],
                  ),
                ),
              ),

              // ─── ACTIVE QUESTS ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: SLText('◈ ACTIVE QUESTS', style: SLType.sysLabel(color: SLColors.glowCore)),
                ),
              ),
              if (todayQuests.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: SystemPanel(
                      glowIntensity: 0.2,
                      child: Center(
                        child: SLText(
                          'NO QUESTS ACTIVE — TAP AI TO GENERATE',
                          style: SLType.body(size: 12, color: SLColors.textMid),
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: QuestCard(
                          quest: todayQuests[i],
                          onComplete: () async {
                            final q = todayQuests[i];
                            final sz = MediaQuery.of(context).size;
                            await ref.read(questProvider.notifier).complete(q.id);
                            final center = Offset(sz.width / 2, sz.height / 2);
                            ref.read(playerProvider.notifier).addXP(q.xpReward, 'quest', center);
                            if (q.difficulty == 'boss') {
                              SystemEventBus.instance.fireBossCleared(q.title, q.xpReward);
                            }
                          },
                        ),
                      ),
                      childCount: todayQuests.length,
                    ),
                  ),
                ),

              // ─── QUICK ACTIONS ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: SLText('◈ QUICK ACTIONS', style: SLType.sysLabel(color: SLColors.glowCore)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildListDelegate([
                    _QuickTile(icon: Icons.bolt, label: 'WORKOUT', xp: 50, color: SLColors.rankS,
                        onTap: () => _awardXP(50, 'workout')),
                    _QuickTile(icon: Icons.water_drop_outlined, label: 'WATER', xp: 20, color: SLColors.rankC,
                        onTap: () => _awardXP(20, 'hydration')),
                    _QuickTile(icon: Icons.restaurant_outlined, label: 'NUTRITION', xp: 25, color: SLColors.success,
                        onTap: () { _awardXP(25, 'nutrition'); context.push('/nutrition'); }),
                    _QuickTile(icon: Icons.directions_walk_outlined, label: 'STEPS', xp: 30, color: SLColors.rankD,
                        onTap: () => _awardXP(30, 'steps')),
                    _QuickTile(icon: Icons.timer_outlined, label: 'FOCUS', xp: 30, color: SLColors.rankB,
                        onTap: () { _awardXP(30, 'deepFocus'); context.push('/focus'); }),
                    _QuickTile(icon: Icons.check_circle_outline, label: 'DISCIPLINE', xp: 20, color: SLColors.xpBright,
                        onTap: () => _awardXP(20, 'discipline')),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SystemNav(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }

  void _awardXP(int amount, String source) {
    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 3,
    );
    ref.read(playerProvider.notifier).addXP(amount, source, center);
  }

  Widget _buildStatusBar(String name, String rank, int streak, int level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          RankDiamond(rank: rank, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SLText('◈ AGION  ·  SYSTEM ONLINE', style: SLType.sysLabel(color: SLColors.textMid)),
                SLText(name.toUpperCase(), style: SLType.headline(size: 14, color: SLColors.textBright)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/planner'),
            child: const Icon(Icons.calendar_today_outlined, color: SLColors.textMid, size: 20),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/analytics'),
            child: const Icon(Icons.bar_chart, color: SLColors.textMid, size: 20),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: const Icon(Icons.person_outline, color: SLColors.textMid, size: 20),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: const Icon(Icons.settings_outlined, color: SLColors.textMid, size: 20),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int xp;
  final Color color;
  final VoidCallback onTap;

  const _QuickTile({required this.icon, required this.label, required this.xp,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SystemPanel(
      glowColor: color,
      glowIntensity: 0.35,
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          SLText(label, style: SLType.sysLabel(size: 8, color: SLColors.textBright), align: TextAlign.center),
          const SizedBox(height: 4),
          SLText('+$xp XP', style: SLType.tag(size: 9, color: color)),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: Center(
        child: SLText('◈ SYSTEM LOADING...', style: SLType.sysLabel(color: SLColors.glowCore)),
      ),
    );
  }
}
