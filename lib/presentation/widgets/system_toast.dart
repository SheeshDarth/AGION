import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// System toast overlay matching spec: bottom center, 220ms fadeIn, 1800ms visible, 200ms fadeOut.
class SystemToast {
  static OverlayEntry? _currentEntry;

  static void show(BuildContext context, String message) {
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ToastWidget({required this.message, required this.onDismiss});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    // Total: 220 + 1800 + 200 = 2220ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2220),
    );

    _fadeIn = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.099, curve: Curves.easeIn), // 220ms / 2220ms
      ),
    );

    _fadeOut = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.91, 1.0, curve: Curves.easeOut), // last 200ms
      ),
    );

    _controller.forward().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final opacity = _fadeIn.value * _fadeOut.value;
          return Opacity(opacity: opacity, child: child);
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AgionSpacing.lg,
              vertical: AgionSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AgionColors.white03,
              borderRadius: AgionRadius.cardBR,
              border: Border.all(color: AgionColors.neonCyan.withValues(alpha: 0.2)),
              boxShadow: AgionShadows.neonGlow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AgionColors.accentGradient.createShader(bounds),
                  child: const Text(
                    'SYSTEM',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: AgionSpacing.sm),
                Flexible(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AgionColors.white,
                    ),
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
