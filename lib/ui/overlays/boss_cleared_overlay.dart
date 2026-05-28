import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';
import '../system/system_text.dart';
import '../system/system_panel.dart';

class BossClearedOverlay extends StatelessWidget {
  final String questTitle;
  final int xpAwarded;
  final VoidCallback onDismiss;

  const BossClearedOverlay({
    super.key,
    required this.questTitle,
    required this.xpAwarded,
    required this.onDismiss,
  });

  static OverlayEntry show(BuildContext context, String title, int xp) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => BossClearedOverlay(
        questTitle: title,
        xpAwarded: xp,
        onDismiss: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.88),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SystemPanel(
            glowColor: SLColors.danger,
            glowIntensity: 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SLText('◈ BOSS ELIMINATED',
                    style: SLType.sysLabel(size: 12, color: SLColors.danger),
                    align: TextAlign.center),
                const SizedBox(height: 16),
                SLText(questTitle,
                    style: SLType.headline(size: 20, color: SLColors.textBright),
                    align: TextAlign.center,
                    maxLines: 2),
                const SizedBox(height: 16),
                SLText('+$xpAwarded XP',
                    style: SLType.display(size: 36, color: SLColors.xpBright),
                    glowColor: SLColors.xpBright,
                    glowRadius: 16,
                    align: TextAlign.center),
                const SizedBox(height: 24),
                SLText('TAP TO CONTINUE',
                    style: SLType.sysLabel(size: 9, color: SLColors.textDim),
                    align: TextAlign.center),
              ],
            ),
          ).animate()
            .fade(duration: 200.ms)
            .scale(begin: const Offset(0.9, 0.9), duration: 300.ms),
        ),
      ),
    );
  }
}
