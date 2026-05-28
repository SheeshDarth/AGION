import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../core/engine/xp_engine.dart';
import '../../../core/engine/body_engine.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/quest_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_text.dart';
import '../../system/sl_panel.dart';
import '../../system/sl_bar.dart';
import '../../system/sl_stat_row.dart';
import '../../hud/rank_diamond.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — Hunter Profile (STATUS Screen)
//
// 1:1 replica of the Solo Leveling STATUS window from the anime.
// Layout:
//   SLPanel(title: 'STATUS')
//   ├── Level row: big number | JOB / TITLE text
//   ├── SLDivider
//   ├── SLSubPanel: HP bar | MP bar | FATIGUE
//   ├── SLDivider
//   └── SLSubPanel: SLStatGrid(STR/AGI/PER/VIT/INT)
//   Biometric sub-panel below (outside STATUS frame)
//   Quest stats row below that
// ═══════════════════════════════════════════════════════════════

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    if (player == null) {
      return Scaffold(
        backgroundColor: SLColors.voidBg,
        body: Center(
          child: SLText(
            'NO PLAYER DATA',
            style: SLType.body(color: SLColors.textMid),
          ),
        ),
      );
    }

    final (level, xpIn, xpNeeded) = XPEngine.progress(player.totalXP);
    final rank = XPEngine.rank(level);
    final allQuests = ref.watch(questProvider);
    final completed = allQuests.where((q) => q.isCompleted).length;

    // ── Derived stats from XP engine ───────────────────────────
    final str  = XPEngine.strength(0);
    final agi  = XPEngine.agility(0);
    final per  = XPEngine.endurance(player.streakDays);
    final vit  = XPEngine.vitality(0);
    final int_ = XPEngine.intelligence(0);

    // ── HP / MP / Fatigue derived from player data ──────────────
    // HP = endurance proxy (streak × 150, max 9999)
    // MP = energy reserve (totalXP ÷ 10, max 9999)
    // Fatigue = inverse streak health (0 streak = 7 fatigue max)
    final hpMax  = 9999;
    final hp     = math.min(player.streakDays * 150, hpMax);
    final mpMax  = 9999;
    final mp     = math.min(player.totalXP ~/ 10, mpMax);
    final fatigue = math.max(0, 7 - player.streakDays).clamp(0, 100);

    // ── Biometrics ─────────────────────────────────────────────
    double? bmi;
    if (player.weightKg != null && player.heightCm != null) {
      bmi = BodyEngine.bmi(weightKg: player.weightKg!, heightCm: player.heightCm!);
    }

    // ── Derive JOB and TITLE from rank and activity ─────────────
    final job = player.activityLevel != null
        ? player.activityLevel!.toUpperCase()
        : 'NONE';
    final title = '$rank-RANK HUNTER';

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Page header (nav back)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back, color: SLColors.textMid, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text('◈ HUNTER PROFILE', style: SLType.headline(size: 16)),
                    ],
                  ),
                ),
              ),

              // ═══════════════════════════════════════════════════
              // STATUS WINDOW — the main Solo Leveling panel
              // ═══════════════════════════════════════════════════
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: SLPanel(
                    title: 'STATUS',
                    glowColor: SLColors.rankColor(rank),
                    glowIntensity: 0.6,
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // ── Level + Job Row ─────────────────────
                        _LevelJobRow(
                          level: level,
                          rank: rank,
                          job: job,
                          title: title,
                        ),

                        const SLDivider(),

                        // ── HP / MP / Fatigue ───────────────────
                        SLSubPanel(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              SLBarAnimated(
                                value: hpMax > 0 ? hp / hpMax : 0.0,
                                type: SLBarType.hp,
                                label: 'HP',
                                valueText: '$hp/$hpMax',
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  size: 16,
                                  color: SLColors.hpBright,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SLBarAnimated(
                                value: mpMax > 0 ? mp / mpMax : 0.0,
                                type: SLBarType.mp,
                                label: 'MP',
                                valueText: '$mp/$mpMax',
                                icon: Icon(
                                  Icons.water_drop_outlined,
                                  size: 16,
                                  color: SLColors.mpBright,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.blur_on,
                                      size: 14,
                                      color: SLColors.textMid,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'FATIGUE: ',
                                      style: TextStyle(
                                        fontFamily: 'Rajdhani',
                                        fontSize: 11,
                                        color: SLColors.textMid,
                                        letterSpacing: 2.5,
                                      ),
                                    ),
                                    Text(
                                      '$fatigue',
                                      style: TextStyle(
                                        fontFamily: 'Orbitron',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: fatigue > 50
                                            ? SLColors.danger
                                            : SLColors.textBright,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SLDivider(),

                        // ── Stats Grid ──────────────────────────
                        SLSubPanel(
                          padding: const EdgeInsets.all(14),
                          child: SLStatGrid(
                            str: str,
                            agi: agi,
                            per: per,
                            vit: vit,
                            int_: int_,
                            availPoints: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Biometrics sub-panel ─────────────────────────
              if (player.heightCm != null || player.weightKg != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: SLPanel(
                      title: 'BIOMETRIC',
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (player.heightCm != null)
                            _InfoRow(label: 'HEIGHT', value: '${player.heightCm} CM'),
                          if (player.weightKg != null)
                            _InfoRow(label: 'WEIGHT', value: '${player.weightKg} KG'),
                          if (bmi != null)
                            _InfoRow(
                              label: 'BMI',
                              value: '${bmi.toStringAsFixed(1)}  ${BodyEngine.bmiCategory(bmi).toUpperCase()}',
                            ),
                          if (player.activityLevel != null)
                            _InfoRow(
                              label: 'ACTIVITY',
                              value: player.activityLevel!.toUpperCase(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Quest stats row ──────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverToBoxAdapter(
                  child: SLPanel(
                    title: 'MISSION LOG',
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatBlock(
                          label: 'QUESTS\nCOMPLETED',
                          value: '$completed',
                          color: SLColors.success,
                        ),
                        _StatBlock(
                          label: 'TOTAL\nQUESTS',
                          value: '${allQuests.length}',
                          color: SLColors.glowCore,
                        ),
                        _StatBlock(
                          label: 'TOTAL\nXP',
                          value: '${player.totalXP}',
                          color: SLColors.xpBright,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Level + Job Row ───────────────────────────────────────────────
class _LevelJobRow extends StatelessWidget {
  final int level;
  final String rank;
  final String job;
  final String title;

  const _LevelJobRow({
    required this.level,
    required this.rank,
    required this.job,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Big level number (dominant visual element)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$level',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 68,
                  fontWeight: FontWeight.w600,
                  color: SLColors.textBright,
                  height: 1.0,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: SLColors.glowCore.withOpacity(0.6),
                      blurRadius: 20,
                    ),
                    Shadow(
                      color: SLColors.glowCore.withOpacity(0.25),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'LEVEL',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: SLColors.textMid,
                  letterSpacing: 5.0,
                ),
              ),
              const SizedBox(height: 6),
              RankDiamond(rank: rank, size: 28),
            ],
          ),

          const SizedBox(width: 20),

          // Vertical separator
          Container(
            width: 1,
            height: 80,
            color: SLColors.panelLine,
          ),

          const SizedBox(width: 20),

          // ── Job + Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _JobLine(label: 'JOB', value: job),
                const SizedBox(height: 8),
                _JobLine(label: 'TITLE', value: title),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JobLine extends StatelessWidget {
  final String label;
  final String value;
  const _JobLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 12,
              color: SLColors.textMid,
              letterSpacing: 1.5,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SLColors.textBright,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info row (biometrics) ─────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 11,
              color: SLColors.textMid,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: SLColors.textBright,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat block (mission log) ──────────────────────────────────────
class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBlock({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 1.0,
            shadows: [
              Shadow(color: color.withOpacity(0.7), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 9,
            color: SLColors.textMid,
            letterSpacing: 1.5,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
