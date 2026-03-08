import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Animated rank badge with pulsing glow aura.
class RankBadgeWidget extends StatefulWidget {
  final String rank;
  final double size;

  const RankBadgeWidget({
    super.key,
    required this.rank,
    this.size = 40,
  });

  @override
  State<RankBadgeWidget> createState() => _RankBadgeWidgetState();
}

class _RankBadgeWidgetState extends State<RankBadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _rankColor {
    switch (widget.rank) {
      case 'S':
        return const Color(0xFFFFD700); // Gold
      case 'A':
        return AgionColors.neonViolet;
      case 'B':
        return AgionColors.neonCyan;
      case 'C':
        return const Color(0xFF4CAF50);
      case 'D':
        return const Color(0xFFFF9800);
      default:
        return AgionColors.mutedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _rankColor.withValues(alpha: 0.3 * _pulseAnimation.value),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _rankColor.withValues(alpha: 0.3 * _pulseAnimation.value),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.72,
              height: widget.size * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AgionColors.backgroundDeep,
                border: Border.all(color: _rankColor, width: 2),
              ),
              child: Center(
                child: Text(
                  widget.rank,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: widget.size * 0.3,
                    fontWeight: FontWeight.w700,
                    color: _rankColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
