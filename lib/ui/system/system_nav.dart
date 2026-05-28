import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/sl/sl_colors.dart';
import '../../core/sl/sl_type.dart';

class SystemNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SystemNav({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.hexagon_outlined,     label: 'HOME'),
    _NavItem(icon: Icons.bolt_outlined,        label: 'TRAIN'),
    _NavItem(icon: Icons.science_outlined,     label: 'FUEL'),
    _NavItem(icon: Icons.diamond_outlined,     label: 'FINANCE'),
    _NavItem(icon: Icons.all_inclusive_rounded, label: 'AI'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: SLColors.panelDeep,
        border: Border(top: BorderSide(color: SLColors.glowCore.withOpacity(0.2))),
        boxShadow: [BoxShadow(
          color: SLColors.glowCore.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, -4),
        )],
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _items[i].icon,
                    color: active ? SLColors.glowCore : SLColors.textDim,
                    size: active ? 22 : 20,
                  ).animate(target: active ? 1 : 0)
                    .scaleXY(begin: 1.0, end: 1.2, duration: 180.ms),
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    opacity: active ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      _items[i].label,
                      style: SLType.sysLabel(size: 8, color: SLColors.glowCore),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
