import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'outlined_text.dart';

class ResultReveal extends StatefulWidget {
  const ResultReveal({
    super.key,
    required this.text,
  });

  final String text;

  @override
  State<ResultReveal> createState() => _ResultRevealState();
}

class _ResultRevealState extends State<ResultReveal>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void didUpdateWidget(covariant ResultReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text && widget.text.isNotEmpty) {
      _play();
    }
  }

  Future<void> _play() async {
    await _scaleController.forward(from: 0);
    await _shakeController.forward(from: 0);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 1.0, end: 1.16).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _scaleController,
        _shakeController,
      ]),
      builder: (context, _) {
        final t = _shakeController.value;
        final shakeX = math.sin(t * math.pi * 10) * (1 - t) * 10;
        final shakeY = math.cos(t * math.pi * 8) * (1 - t) * 4;

        return Transform.translate(
          offset: Offset(shakeX, shakeY),
          child: Transform.scale(
            scale: scale.value,
            child: OutlinedText(
              text: widget.text,
              textAlign: TextAlign.center,
              strokeWidth: 5,
              strokeColor: const Color(0xFF050505),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: const Color(0xFFFDE68A),
                  ) ??
                  const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xFFFDE68A),
                  ),
            ),
          ),
        );
      },
    );
  }
}
