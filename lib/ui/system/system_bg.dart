import 'package:flutter/material.dart';
import 'sl_bg.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — SystemBg: backward-compatible wrapper around SLBg.
//
// All screens that import SystemBg automatically get the
// energy particle network background from the reference spec.
// The old grid/scanline/particle painters have been removed.
// ═══════════════════════════════════════════════════════════════

/// Drop-in replacement — same API as before, now delegates to SLBg.
class SystemBg extends StatelessWidget {
  final Widget child;
  final double intensity;
  const SystemBg({super.key, required this.child, this.intensity = 1.0});

  @override
  Widget build(BuildContext context) => SLBg(intensity: intensity, child: child);
}
