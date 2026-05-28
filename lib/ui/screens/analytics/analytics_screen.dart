import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../core/engine/xp_engine.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final sessions = ref.watch(workoutProvider);

    if (player == null) return const _AnalyticsLoading();

    final (level, xpIn, xpNeeded) = XPEngine.progress(player.totalXP);
    final rank = XPEngine.rank(level);

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(),
                      child: Icon(Icons.arrow_back, color: SLColors.textMid, size: 20)),
                    const SizedBox(width: 12),
                    SLText('◈ ANALYTICS', style: SLType.headline(size: 18)),
                  ],
                ),
              ),
              TabBar(
                controller: _tabs,
                indicatorColor: SLColors.glowCore,
                labelStyle: SLType.sysLabel(size: 9, color: SLColors.glowCore),
                unselectedLabelStyle: SLType.sysLabel(size: 9, color: SLColors.textMid),
                tabs: const [
                  Tab(text: 'OVERVIEW'),
                  Tab(text: 'COMBAT'),
                  Tab(text: 'STATS'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _OverviewTab(player: player, level: level, xpIn: xpIn, xpNeeded: xpNeeded, rank: rank),
                    _CombatTab(sessions: sessions),
                    _StatsTab(player: player, level: level),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final dynamic player;
  final int level, xpIn, xpNeeded;
  final String rank;

  const _OverviewTab({required this.player, required this.level, required this.xpIn,
    required this.xpNeeded, required this.rank});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SystemPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SLText('ASCENSION OVERVIEW', style: SLType.sysLabel(color: SLColors.textMid)),
              const SizedBox(height: 16),
              Row(children: [
                _statItem('LEVEL', '$level', SLColors.glowCore),
                _statItem('RANK', rank, SLColors.rankColor(rank)),
                _statItem('XP', '${player.totalXP}', SLColors.xpBright),
                _statItem('STREAK', '${player.streakDays}d', SLColors.rankS),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SystemPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SLText('XP PROGRESS', style: SLType.sysLabel(color: SLColors.textMid)),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: xpNeeded > 0 ? xpIn / xpNeeded : 0,
                backgroundColor: SLColors.textDim.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(SLColors.glowCore),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SLText('$xpIn XP', style: SLType.body(size: 12, color: SLColors.textMid)),
                  SLText('$xpNeeded XP NEEDED', style: SLType.body(size: 12, color: SLColors.textMid)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color) => Expanded(
    child: Column(
      children: [
        SLText(value, style: SLType.hudNum(size: 18, color: color), glowColor: color, glowRadius: 6),
        SLText(label, style: SLType.sysLabel(size: 8, color: SLColors.textMid)),
      ],
    ),
  );
}

class _CombatTab extends StatelessWidget {
  final List sessions;
  const _CombatTab({required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(child: SLText('NO COMBAT DATA.', style: SLType.body(color: SLColors.textMid)));
    }
    final last7 = sessions.take(7).toList().reversed.toList();
    final bars = last7.asMap().entries.map((e) => BarChartGroupData(
      x: e.key,
      barRods: [BarChartRodData(
        toY: e.value.totalVolumeKg,
        color: SLColors.rankS,
        width: 12,
        borderRadius: BorderRadius.zero,
      )],
    )).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SystemPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SLText('VOLUME — LAST 7 SESSIONS', style: SLType.sysLabel(color: SLColors.textMid)),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: BarChart(BarChartData(
                  barGroups: bars,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  backgroundColor: Colors.transparent,
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SystemPanel(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _citem('SESSIONS', '${sessions.length}', SLColors.glowCore),
              _citem('TOTAL VOL', '${sessions.fold(0.0, (s, e) => s + e.totalVolumeKg).round()}kg', SLColors.rankS),
            ],
          ),
        ),
      ],
    );
  }

  Widget _citem(String label, String value, Color color) => Column(
    children: [
      SLText(value, style: SLType.hudNum(size: 20, color: color)),
      SLText(label, style: SLType.sysLabel(size: 8, color: SLColors.textMid)),
    ],
  );
}

class _StatsTab extends StatelessWidget {
  final dynamic player;
  final int level;
  const _StatsTab({required this.player, required this.level});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('STR', XPEngine.strength(0), SLColors.rankS),
      ('AGI', XPEngine.agility(0), SLColors.rankD),
      ('INT', XPEngine.intelligence(0), SLColors.rankC),
      ('VIT', XPEngine.vitality(0), SLColors.success),
      ('END', XPEngine.endurance(player.streakDays), SLColors.rankB),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: stats.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SystemPanel(
          glowColor: s.$3,
          glowIntensity: 0.3,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 40, child: SLText(s.$1, style: SLType.sysLabel(size: 11, color: s.$3))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (s.$2 / 9999).clamp(0.0, 1.0),
                    backgroundColor: SLColors.textDim.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(s.$3),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(width: 48,
                child: SLText('${s.$2}', style: SLType.hudNum(size: 14, color: s.$3), align: TextAlign.right)),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _AnalyticsLoading extends StatelessWidget {
  const _AnalyticsLoading();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SLColors.voidBg,
    body: Center(child: SLText('◈ LOADING...', style: SLType.sysLabel(color: SLColors.glowCore))),
  );
}
