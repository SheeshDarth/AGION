import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../providers/quest_provider.dart';
import '../../../providers/player_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_button.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';
import '../../hud/quest_card.dart';
import '../../../core/services/system_event_bus.dart';
import '../../../data/remote/gemini_client.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  bool _generatingQuests = false;

  Future<void> _generateQuests() async {
    final player = ref.read(playerProvider);
    if (player == null) return;
    setState(() => _generatingQuests = true);
    try {
      final client = GeminiClient();
      final quests = await client.generateQuests(
        goals: player.goals.join(', '),
        rank: 'E',
        level: 1,
      );
      await ref.read(questProvider.notifier).addFromJson(quests);
    } finally {
      if (mounted) setState(() => _generatingQuests = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayQuests = ref.watch(todayQuestsProvider);
    final player = ref.watch(playerProvider);

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final created = player?.createdDate ?? today;
    final daysSince = DateTime.now().difference(DateTime.parse(created)).inDays + 1;

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SLText('DAY $daysSince OF YOUR ASCENSION',
                          style: SLType.sysLabel(color: SLColors.textMid)),
                      SLText('◈ DAILY PLANNER', style: SLType.headline(size: 22)),
                    ],
                  ),
                ),
              ),
              // Quest generation
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: SystemButton(
                          label: '◈ GENERATE QUESTS',
                          icon: Icons.auto_awesome,
                          isLoading: _generatingQuests,
                          onTap: _generateQuests,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SystemButton(
                        label: 'FOCUS',
                        icon: Icons.timer_outlined,
                        variant: SystemButtonVariant.ghost,
                        onTap: () => context.push('/focus'),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (todayQuests.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: SystemPanel(
                      glowIntensity: 0.15,
                      child: SLText(
                        '◈ SYSTEM: No active directives. Generate quests or add manually.',
                        style: SLType.body(color: SLColors.textMid),
                        align: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final q = todayQuests[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: QuestCard(
                            quest: q,
                            onComplete: q.isCompleted ? null : () async {
                              final sz = MediaQuery.of(context).size;
                              await ref.read(questProvider.notifier).complete(q.id);
                              final center = Offset(sz.width / 2, sz.height / 2);
                              ref.read(playerProvider.notifier).addXP(q.xpReward, 'quest', center);
                              if (q.difficulty == 'boss') {
                                SystemEventBus.instance.fireBossCleared(q.title, q.xpReward);
                              }
                            },
                          ),
                        );
                      },
                      childCount: todayQuests.length,
                    ),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
