import 'package:flutter/material.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';
import '../system/system_panel.dart';
import '../system/system_text.dart';

class StreakBar extends StatelessWidget {
  final int streakDays;
  final int todayXP;
  final int dailyXPTarget;
  final int daysSinceStart;

  const StreakBar({
    super.key,
    required this.streakDays,
    required this.todayXP,
    required this.dailyXPTarget,
    required this.daysSinceStart,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (todayXP / dailyXPTarget.clamp(1, dailyXPTarget)).clamp(0.0, 1.0);

    return SystemPanel(
      glowColor: SLColors.xpBright,
      glowIntensity: 0.35,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SLText(
                '🔥 $streakDays DAY ASCENSION STREAK',
                style: SLType.sysLabel(size: 10, color: SLColors.xpBright),
              ),
              const Spacer(),
              SLText(
                'DAY $daysSinceStart',
                style: SLType.sysLabel(size: 9, color: SLColors.textMid),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Sharp-cornered progress bar (no ClipRRect — per spec, zero border radius)
          SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(color: SLColors.textDim.withOpacity(0.3)),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: SLColors.xpBright),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SLText(
            '$todayXP / $dailyXPTarget XP TODAY',
            style: SLType.body(size: 11, color: SLColors.textMid),
          ),
        ],
      ),
    );
  }
}
