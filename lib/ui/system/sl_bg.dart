import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/sl/sl_colors.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — Energy Particle Network Background
//
// Replicates the exact background from the Solo Leveling STATUS
// screen: a dark navy void with floating energy nodes connected
// by faint lines, drifting very slowly.
//
// Layers (bottom → top):
//   1. Deep navy base gradient
//   2. Subtle radial bloom (center-left, like in reference image)
//   3. Particle network (nodes + connecting lines) — animated
//   4. Content
// ═══════════════════════════════════════════════════════════════

class SLBg extends StatefulWidget {
  final Widget child;
  /// 0.0 = calm (focus timer), 1.0 = full intensity (home, status)
  final double intensity;
  const SLBg({super.key, required this.child, this.intensity = 1.0});

  @override
  State<SLBg> createState() => _SLBgState();
}

class _SLBgState extends State<SLBg> with SingleTickerProviderStateMixin {
  late AnimationController _drift;
  late List<_Node> _nodes;
  late List<_Edge> _edges;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    final rand = math.Random(42); // fixed seed = consistent layout
    final nodeCount = (18 * widget.intensity).round().clamp(6, 22);
    _nodes = List.generate(nodeCount, (_) => _Node(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: rand.nextDouble() * 1.8 + 1.0,
      speed: rand.nextDouble() * 0.008 + 0.002,
      angle: rand.nextDouble() * math.pi * 2,
      opacity: rand.nextDouble() * 0.35 + 0.2,
    ));

    // Connect nodes that are "close" to each other
    _edges = [];
    for (int i = 0; i < _nodes.length; i++) {
      for (int j = i + 1; j < _nodes.length; j++) {
        final dx = _nodes[i].x - _nodes[j].x;
        final dy = _nodes[i].y - _nodes[j].y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < 0.28) {
          _edges.add(_Edge(i, j, 1.0 - (dist / 0.28)));
        }
      }
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Layer 1: Base gradient
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF040C18), // top-left: slightly lighter
              SLColors.voidBg,  // dominantly dark
              Color(0xFF020609), // bottom-right: deepest
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),

      // Layer 2: Radial bloom (matches reference — centered slightly left)
      Positioned(
        left: -80, top: -60,
        child: Container(
          width: 400, height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              SLColors.glowDim.withOpacity(0.07 * widget.intensity),
              Colors.transparent,
            ]),
          ),
        ),
      ),

      // Layer 3: Particle network (animated)
      RepaintBoundary(
        child: AnimatedBuilder(
          animation: _drift,
          builder: (_, __) => CustomPaint(
            size: Size.infinite,
            painter: _NetworkPainter(
              nodes: _nodes,
              edges: _edges,
              progress: _drift.value,
              intensity: widget.intensity,
            ),
          ),
        ),
      ),

      // Content
      widget.child,
    ]);
  }
}

// ── Data ─────────────────────────────────────────────────────────
class _Node {
  double x, y;
  final double size, speed, opacity;
  double angle;
  _Node({
    required this.x, required this.y,
    required this.size, required this.speed,
    required this.angle, required this.opacity,
  });
}

class _Edge {
  final int a, b;
  final double strength; // 0-1, based on proximity
  const _Edge(this.a, this.b, this.strength);
}

// ── Painter ───────────────────────────────────────────────────────
class _NetworkPainter extends CustomPainter {
  final List<_Node> nodes;
  final List<_Edge> edges;
  final double progress;
  final double intensity;

  const _NetworkPainter({
    required this.nodes,
    required this.edges,
    required this.progress,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Advance node positions
    for (final n in nodes) {
      final drift = progress * n.speed * math.pi * 2;
      final px = n.x + math.cos(n.angle + drift) * 0.04;
      final py = n.y + math.sin(n.angle + drift) * 0.04;
      n.x = px.clamp(0.02, 0.98);
      n.y = py.clamp(0.02, 0.98);
    }

    // Draw edges (connecting lines)
    for (final e in edges) {
      final a = nodes[e.a];
      final b = nodes[e.b];
      canvas.drawLine(
        Offset(a.x * size.width, a.y * size.height),
        Offset(b.x * size.width, b.y * size.height),
        Paint()
          ..color = SLColors.glowCore
              .withOpacity(e.strength * 0.12 * intensity)
          ..strokeWidth = 0.8,
      );
    }

    // Draw nodes
    for (final n in nodes) {
      final pos = Offset(n.x * size.width, n.y * size.height);

      // Outer soft glow
      canvas.drawCircle(pos, n.size * 3,
        Paint()
          ..color = SLColors.glowCore.withOpacity(0.04 * n.opacity * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Core dot
      canvas.drawCircle(pos, n.size,
        Paint()..color = SLColors.glowCore.withOpacity(n.opacity * intensity),
      );
    }
  }

  @override
  bool shouldRepaint(_NetworkPainter old) => old.progress != progress;
}
