import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Glassmorphism container used throughout the app.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AgionColors.white03,
        borderRadius: borderRadius ?? AgionRadius.cardBR,
        border: Border.all(color: AgionColors.cardGlassBorder),
        boxShadow: showGlow ? AgionShadows.neonGlow : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AgionRadius.cardBR,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AgionSpacing.md),
          child: child,
        ),
      ),
    );
  }
}
