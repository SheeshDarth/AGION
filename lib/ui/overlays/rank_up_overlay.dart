import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';
import '../system/system_text.dart';
import '../system/system_panel.dart';

class RankUpOverlay extends StatelessWidget {
  final String oldRank;
  final String newRank;
  final VoidCallback onDismiss;

  const RankUpOverlay({
    super.key,
    required this.oldRank,
    required this.newRank,
    required this.onDismiss,
  });

  static OverlayEntry show(BuildContext context, String oldRank, String newRank) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => RankUpOverlay(
        oldRank: oldRank,
        newRank: newRank,
        onDismiss: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  Widget build(BuildContext context) {
    final newColor = SLColors.rankColor(newRank);
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SystemPanel(
            glowColor: newColor,
            glowIntensity: 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SLText(
                  '◈ RANK UP',
                  style: SLType.sysLabel(size: 12, color: newColor),
                  align: TextAlign.center,
                ).animate().fade(duration: 300.ms),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SLText(oldRank, style: SLType.display(size: 40, color: SLColors.rankColor(oldRank))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SLText('→', style: SLType.headline(size: 24, color: SLColors.textMid)),
                    ),
                    SLText(newRank,
                      style: SLType.display(size: 56, color: newColor),
                      glowColor: newColor,
                      glowRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SLText(
                  'RANK ADVANCEMENT',
                  style: SLType.questTitle(size: 16, color: SLColors.textMid),
                  align: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SLText('TAP TO CONTINUE',
                    style: SLType.sysLabel(size: 9, color: SLColors.textDim),
                    align: TextAlign.center),
              ],
            ),
          ).animate()
            .fade(duration: 200.ms)
            .scale(begin: const Offset(0.9, 0.9), duration: 300.ms, curve: Curves.easeOut),
        ),
      ),
    );
  }
}
