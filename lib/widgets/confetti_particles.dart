import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiParticles extends StatefulWidget {
  final bool trigger;
  final Widget child;

  const ConfettiParticles({
    super.key,
    required this.trigger,
    required this.child,
  });

  @override
  State<ConfettiParticles> createState() => _ConfettiParticlesState();
}

class _ConfettiParticlesState extends State<ConfettiParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant ConfettiParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _spawnParticles();
      _controller.forward(from: 0.0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    const colors = [
      Color(0xFFFFD700), // Gold
      Color(0xFFFF6B6B), // Coral
      Color(0xFF4ECDC4), // Teal
      Color(0xFF45B7D1), // Sky
      Color(0xFF96CEB4), // Mint
      Color(0xFFFFBE0B), // Amber
      Color(0xFF8338EC), // Purple
      Color(0xFF3A86FF), // Blue
    ];

    for (int i = 0; i < 48; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 120.0 + _random.nextDouble() * 220.0;
      final size = 5.0 + _random.nextDouble() * 7.0;
      final color = colors[_random.nextInt(colors.length)];
      final rotationSpeed = (_random.nextDouble() - 0.5) * 8.0;

      _particles.add(_Particle(
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 60.0, // slight upward boost
        size: size,
        color: color,
        rotationSpeed: rotationSpeed,
        isCircle: _random.nextBool(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(
                  progress: _controller.value,
                  particles: _particles,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotationSpeed;
  final bool isCircle;

  _Particle({
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ParticlePainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.40);
    final gravity = 280.0 * progress * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final x = center.dx + p.vx * progress;
      final y = center.dy + p.vy * progress + gravity;
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed * math.pi);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
