import 'package:flutter/material.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';
import '../../data/models/quest_model.dart';
import '../system/system_panel.dart';
import '../system/system_text.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  const QuestCard({
    super.key,
    required this.quest,
    this.onComplete,
    this.onTap,
  });

  Color get _categoryColor {
    switch (quest.category) {
      case 'workout':    return SLColors.rankS;
      case 'nutrition':  return SLColors.success;
      case 'finance':    return SLColors.xpBright;
      case 'study':      return SLColors.rankC;
      case 'habit':      return SLColors.rankB;
      case 'boss':       return SLColors.danger;
      default:           return SLColors.glowCore;
    }
  }

  Color get _difficultyColor {
    switch (quest.difficulty) {
      case 'boss':   return SLColors.danger;
      case 'hard':   return SLColors.rankA;
      case 'medium': return SLColors.rankC;
      default:       return SLColors.rankD;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemPanel(
      glowColor: _categoryColor,
      glowIntensity: quest.difficulty == 'boss' ? 0.9 : 0.4,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 48,
            color: _categoryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SLText(
                  quest.title,
                  style: SLType.questTitle(size: 14, color: SLColors.textBright),
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    SLText(
                      quest.category.toUpperCase(),
                      style: SLType.tag(size: 9, color: _categoryColor),
                    ),
                    const SizedBox(width: 8),
                    SLText(
                      quest.difficulty.toUpperCase(),
                      style: SLType.tag(size: 9, color: _difficultyColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SLText(
                '+${quest.xpReward} XP',
                style: SLType.hudNum(size: 13, color: SLColors.xpBright),
                glowColor: SLColors.xpBright,
                glowRadius: 4,
              ),
              if (!quest.isCompleted && onComplete != null)
                GestureDetector(
                  onTap: onComplete,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: SLColors.glowCore.withOpacity(0.5)),
                    ),
                    child: SLText('DONE', style: SLType.sysLabel(size: 8, color: SLColors.glowCore)),
                  ),
                )
              else if (quest.isCompleted)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: SLColors.success.withOpacity(0.5)),
                  ),
                  child: SLText('✓', style: SLType.sysLabel(size: 8, color: SLColors.success)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
