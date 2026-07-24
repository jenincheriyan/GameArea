import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Plays once when a bomb is cut: a bright flash, a burst of colored
/// shrapnel shards, and a few soft smoke puffs that drift up and fade.
/// Pair this with a screen-shake at the screen level for full impact.
class ExplosionEffect extends StatefulWidget {
  const ExplosionEffect({super.key});

  @override
  State<ExplosionEffect> createState() => _ExplosionEffectState();
}

class _ExplosionEffectState extends State<ExplosionEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Shard> _shards;
  late final List<_Smoke> _smokes;

  static const _shardColors = [
    Color(0xFFFFC93F),
    Color(0xFFFF7A3D),
    Color(0xFFFF4D4D),
  ];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..forward();

    final rand = math.Random();
    _shards = List.generate(10, (i) {
      final angle = (i / 10) * math.pi * 2 + rand.nextDouble() * 0.3;
      return _Shard(
        angle: angle,
        speed: 50 + rand.nextDouble() * 40,
        length: 10 + rand.nextDouble() * 10,
        color: _shardColors[i % _shardColors.length],
      );
    });
    _smokes = List.generate(5, (i) {
      final angle = rand.nextDouble() * math.pi * 2;
      return _Smoke(
        angle: angle,
        speed: 12 + rand.nextDouble() * 18,
        size: 26 + rand.nextDouble() * 20,
        delay: rand.nextDouble() * 0.25,
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final flashT = (t / 0.18).clamp(0.0, 1.0);
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              for (final s in _smokes) _buildSmoke(s, t),
              for (final s in _shards) _buildShard(s, t),
              if (t < 0.18)
                Opacity(
                  opacity: 1 - flashT,
                  child: Container(
                    width: 120 * (0.6 + flashT * 0.8),
                    height: 120 * (0.6 + flashT * 0.8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShard(_Shard s, double t) {
    final dist = s.speed * t;
    final dx = math.cos(s.angle) * dist;
    final dy = math.sin(s.angle) * dist;
    final fade = (1 - t).clamp(0.0, 1.0);
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.rotate(
        angle: s.angle,
        child: Opacity(
          opacity: fade,
          child: Container(
            width: s.length,
            height: 4,
            decoration: BoxDecoration(
              color: s.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmoke(_Smoke s, double t) {
    final local = ((t - s.delay) / (1 - s.delay)).clamp(0.0, 1.0);
    if (local <= 0) return const SizedBox.shrink();
    final dist = s.speed * local;
    final dx = math.cos(s.angle) * dist * 0.4;
    final dy = math.sin(s.angle) * dist * 0.4 - dist; // drift upward
    final scale = 0.5 + local * 0.9;
    final fade = (1 - local).clamp(0.0, 1.0) * 0.5;
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: fade,
        child: Container(
          width: s.size * scale,
          height: s.size * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade600.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _Shard {
  final double angle;
  final double speed;
  final double length;
  final Color color;
  const _Shard({
    required this.angle,
    required this.speed,
    required this.length,
    required this.color,
  });
}

class _Smoke {
  final double angle;
  final double speed;
  final double size;
  final double delay;
  const _Smoke({
    required this.angle,
    required this.speed,
    required this.size,
    required this.delay,
  });
}
