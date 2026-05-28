import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';
import '../system/system_text.dart';

class XPPop {
  static void show(BuildContext context, int amount, Offset globalPos) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _XPPopWidget(
        amount: amount,
        position: globalPos,
        onDone: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
  }
}

class _XPPopWidget extends StatelessWidget {
  final int amount;
  final Offset position;
  final VoidCallback onDone;

  const _XPPopWidget({
    required this.amount,
    required this.position,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 30,
      top: position.dy - 10,
      child: IgnorePointer(
        child: SLText(
          '+$amount XP',
          style: SLType.hudNum(size: 15, color: SLColors.xpBright),
          glowColor: SLColors.xpBright,
          glowRadius: 8,
        )
        .animate(onComplete: (_) => onDone())
          .moveY(begin: 0, end: -70, duration: 750.ms, curve: Curves.easeOut)
          .fade(begin: 1.0, end: 0.0, delay: 400.ms, duration: 350.ms),
      ),
    );
  }
}
