import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Quick action button with glassmorphism and neon glow on press.
///
/// Animations: scale 0.97 over 80ms, bounce back 120ms as per spec.
class QuickActionButton extends StatefulWidget {
  final QuickAction action;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.action,
    required this.onTap,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.97)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.97, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 120,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.forward(from: 0);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AgionColors.white03,
            borderRadius: AgionRadius.cardBR,
            border: Border.all(
              color: _isPressed
                  ? AgionColors.neonCyan.withValues(alpha: 0.3)
                  : AgionColors.cardGlassBorder,
            ),
            boxShadow: _isPressed ? AgionShadows.neonGlowStrong : AgionShadows.neonGlow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AgionSpacing.md,
              horizontal: AgionSpacing.sm,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.action.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: AgionSpacing.sm),
                Text(
                  widget.action.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AgionColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AgionSpacing.xs),
                Text(
                  '+${widget.action.xpReward} XP',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AgionColors.neonCyan.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
