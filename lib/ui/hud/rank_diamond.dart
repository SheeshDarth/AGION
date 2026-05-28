import 'package:flutter/material.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';
import '../system/system_text.dart';

class RankDiamond extends StatelessWidget {
  final String rank;
  final double size;

  const RankDiamond({super.key, required this.rank, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = SLColors.rankColor(rank);
    return CustomPaint(
      size: Size(size, size),
      painter: _DiamondPainter(color: color),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: SLText(
            rank,
            style: SLType.sysLabel(size: size * 0.35, color: color),
            glowColor: color,
            glowRadius: 8,
          ),
        ),
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  final Color color;
  const _DiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(path, Paint()..color = color.withOpacity(0.08));
    canvas.drawPath(path, Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 4));
    canvas.drawPath(path, Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(_DiamondPainter old) => old.color != color;
}
