import 'dart:math' as math;

import 'package:flutter/material.dart';

class LeblancBackground extends StatelessWidget {
  const LeblancBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _GradientLayer()),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _NoiseAndStripesPainter(seed: 13),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GradientLayer extends StatelessWidget {
  const _GradientLayer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF080707),
            const Color(0xFF120C0B),
            const Color(0xFF090A0C),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _NoiseAndStripesPainter extends CustomPainter {
  _NoiseAndStripesPainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);

    final stripes = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFB91C1C).withOpacity(0.08);

    final diagonalStep = 14.0;
    for (double x = -size.height; x < size.width + size.height; x += diagonalStep) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), stripes);
    }

    final dots = Paint()..color = Colors.white.withOpacity(0.03);
    for (var i = 0; i < 180; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.2 + 0.2;
      canvas.drawCircle(Offset(dx, dy), r, dots);
    }

    final stains = Paint()..color = const Color(0xFFB45309).withOpacity(0.05);
    for (var i = 0; i < 10; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final rx = rng.nextDouble() * 120 + 60;
      final ry = rng.nextDouble() * 90 + 40;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: rx, height: ry),
        stains,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NoiseAndStripesPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

