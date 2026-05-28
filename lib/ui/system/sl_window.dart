import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sl_panel.dart';
import '../../core/sl/sl_colors.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — SLWindow: The Solo Leveling System Notification Window
//
// This is the floating quest popup seen in the anime when Jin-Woo
// receives a quest or notification. It appears as an overlay.
//
// Usage:
//   SLWindow.show(context, SLWindowConfig(
//     type: SLWindowType.quest,
//     title: 'DAILY QUEST ASSIGNED',
//     body: 'Complete 10,000 steps today.',
//     xpReward: 30,
//   ));
// ═══════════════════════════════════════════════════════════════

enum SLWindowType {
  quest,
  questComplete,
  levelUp,
  warning,
  reward,
  system,
}

class SLWindowConfig {
  final SLWindowType type;
  final String title;
  final String? subtitle;
  final String? body;
  final int? xpReward;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const SLWindowConfig({
    required this.type,
    required this.title,
    this.subtitle,
    this.body,
    this.xpReward,
    this.primaryLabel,
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
  });
}

class SLWindow extends StatelessWidget {
  final SLWindowConfig config;
  const SLWindow({super.key, required this.config});

  Color get _accent {
    switch (config.type) {
      case SLWindowType.questComplete: return SLColors.success;
      case SLWindowType.levelUp:       return SLColors.glowCore;
      case SLWindowType.warning:       return SLColors.danger;
      case SLWindowType.reward:        return SLColors.xpBright;
      default:                         return SLColors.glowCore;
    }
  }

  String get _typeLabel {
    switch (config.type) {
      case SLWindowType.quest:         return 'QUEST';
      case SLWindowType.questComplete: return 'QUEST COMPLETE';
      case SLWindowType.levelUp:       return 'LEVEL UP';
      case SLWindowType.warning:       return 'WARNING';
      case SLWindowType.reward:        return 'REWARD';
      default:                         return 'SYSTEM';
    }
  }

  static OverlayEntry show(BuildContext context, SLWindowConfig config) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SLWindowOverlay(
        config: config,
        onDismiss: entry.remove,
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  Widget build(BuildContext context) {
    return SLPanel(
      glowColor: _accent,
      glowIntensity: 0.85,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              border: Border(
                bottom: BorderSide(color: _accent.withOpacity(0.3), width: 1),
              ),
            ),
            child: Row(children: [
              Text(
                '◈ SYSTEM  ·  $_typeLabel',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _accent,
                  letterSpacing: 2.5,
                  shadows: [Shadow(color: _accent.withOpacity(0.7), blurRadius: 6)],
                ),
              ),
              const Spacer(),
              Text(
                _timestamp(),
                style: GoogleFonts.exo2(
                  fontSize: 9,
                  color: SLColors.textDim,
                  letterSpacing: 0.5,
                ),
              ),
            ]),
          ),

          // ── Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  config.title.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: SLColors.textBright,
                    letterSpacing: 2.0,
                    shadows: [Shadow(color: _accent.withOpacity(0.5), blurRadius: 8)],
                  ),
                ),
                if (config.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    config.subtitle!,
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 13,
                      color: _accent,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
                if (config.body != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    config.body!,
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 14,
                      color: SLColors.textMid,
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                  ),
                ],
                // XP reward badge
                if (config.xpReward != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SLColors.xpDark.withOpacity(0.3),
                      border: Border.all(
                        color: SLColors.xpBright.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'REWARD: +${config.xpReward} XP',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: SLColors.xpBright,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(color: SLColors.xpBright.withOpacity(0.6), blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ],
                // Action buttons
                if (config.primaryLabel != null) ...[
                  const SizedBox(height: 14),
                  Row(children: [
                    if (config.secondaryLabel != null) ...[
                      Expanded(child: _WinButton(
                        label: config.secondaryLabel!,
                        color: SLColors.textMid,
                        onTap: config.onSecondary,
                      )),
                      const SizedBox(width: 10),
                    ],
                    Expanded(child: _WinButton(
                      label: config.primaryLabel!,
                      color: _accent,
                      onTap: config.onPrimary,
                    )),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
           '${now.minute.toString().padLeft(2, '0')}';
  }
}

// ── Window Button ─────────────────────────────────────────────────
class _WinButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _WinButton({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.6), width: 1),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.12), blurRadius: 8),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );
  }
}

// ── Overlay wrapper with animation ───────────────────────────────
class _SLWindowOverlay extends StatefulWidget {
  final SLWindowConfig config;
  final VoidCallback onDismiss;
  const _SLWindowOverlay({required this.config, required this.onDismiss});

  @override
  State<_SLWindowOverlay> createState() => _SLWindowOverlayState();
}

class _SLWindowOverlayState extends State<_SLWindowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale   = Tween(begin: 0.93, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.config.primaryLabel == null ? _dismiss : null,
      child: Material(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SLWindow(config: widget.config),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
