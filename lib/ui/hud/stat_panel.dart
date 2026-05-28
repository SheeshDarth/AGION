import 'package:flutter/material.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';
import '../system/system_panel.dart';
import '../system/system_text.dart';

class StatPanel extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  const StatPanel({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? SLColors.glowCore;
    return SystemPanel(
      glowColor: c,
      glowIntensity: 0.4,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SLText(
            '$value',
            style: SLType.hudNum(size: 20, color: c),
            glowColor: c,
            glowRadius: 8,
          ),
          const SizedBox(height: 4),
          SLText(label, style: SLType.sysLabel(size: 9, color: SLColors.textMid)),
        ],
      ),
    );
  }
}
