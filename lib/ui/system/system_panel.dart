import 'package:flutter/material.dart';
import 'sl_panel.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — SystemPanel: backward-compatible wrapper around SLPanel.
//
// All panels across all screens now get corner brackets and the
// canonical Solo Leveling visual style automatically.
// The old NotchClipper, BackdropFilter, and glass blur have been
// removed. useBlur is accepted but ignored (SLPanel has no blur).
// ═══════════════════════════════════════════════════════════════

/// Drop-in replacement — same API, now delegates to SLPanel.
class SystemPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final Color? glowColor;
  final double glowIntensity;
  final bool useBlur; // accepted but ignored — no glass blur in reference spec
  final VoidCallback? onTap;

  const SystemPanel({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.glowColor,
    this.glowIntensity = 0.5,
    this.useBlur = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => SLPanel(
    glowColor: glowColor,
    glowIntensity: glowIntensity,
    padding: padding,
    width: width,
    height: height,
    onTap: onTap,
    child: child,
  );
}
