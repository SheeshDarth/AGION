import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../providers/workout_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_button.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';

class WorkoutHubScreen extends ConsumerWidget {
  const WorkoutHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(workoutProvider);

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
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(Icons.arrow_back, color: SLColors.textMid, size: 20),
                    ),
                    const SizedBox(width: 12),
                    SLText('◈ COMBAT RECORDS', style: SLType.headline(size: 18, color: SLColors.textBright)),
                  ],
                ),
              ),
              Expanded(
                child: sessions.isEmpty
                    ? Center(
                        child: SLText(
                          'NO COMBAT RECORDS.',
                          style: SLType.body(color: SLColors.textMid),
                          align: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final s = sessions[i];
                          final date = DateTime.parse(s.date);
                          return SystemPanel(
                            glowColor: SLColors.rankS,
                            glowIntensity: 0.3,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SLText(s.title, style: SLType.questTitle(size: 15)),
                                      const SizedBox(height: 4),
                                      SLText(
                                        DateFormat('MMM d · HH:mm').format(date),
                                        style: SLType.body(size: 12, color: SLColors.textMid),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SLText('${s.durationMinutes}m',
                                        style: SLType.hudNum(size: 16, color: SLColors.glowCore)),
                                    SLText('${s.totalVolumeKg.round()}kg vol',
                                        style: SLType.body(size: 11, color: SLColors.textMid)),
                                    SLText('+${s.xpEarned} XP',
                                        style: SLType.tag(size: 10, color: SLColors.xpBright)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SystemButton(
                  label: '◈ BEGIN SESSION',
                  variant: SystemButtonVariant.primary,
                  icon: Icons.bolt,
                  onTap: () => context.push('/workout/session'),
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
