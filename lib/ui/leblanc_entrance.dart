import 'package:flutter/material.dart';
import 'character_portrait.dart';
import 'lebanc_background.dart';
import 'outlined_text.dart';

class LeblancEntrancePage extends StatefulWidget {
  const LeblancEntrancePage({super.key, required this.onEnter});

  final VoidCallback onEnter;

  @override
  State<LeblancEntrancePage> createState() => _LeblancEntrancePageState();
}

class _LeblancEntrancePageState extends State<LeblancEntrancePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onEnter,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/卢布朗咖啡馆.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6), // Darken it a bit
              colorBlendMode: BlendMode.darken,
            ),
          ),
          
          // Character Portrait with Fade Mask (Attempt to blend JPG)
          // Removed as per user request


          // Main Title
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: -0.1,
                  child: Transform(
                    transform: Matrix4.skewX(-0.2),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const OutlinedText(
                        text: 'CAFE LEBLANC',
                        strokeWidth: 4,
                        strokeColor: Colors.black,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.black.withOpacity(0.55),
                    ),
                    child: const Text(
                      'TAP TO ENTER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dialogue box style text at bottom
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.92),
                  border: Border(
                    left: BorderSide(color: scheme.primary, width: 6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
                  child: const Text(
                    '“欢迎回来。饿了吗？我可以给你做咖喱，或者你也可以点点别的。”',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Menlo',
                      fontFamilyFallback: [
                        'PingFang SC',
                        'Hiragino Sans GB',
                        'Heiti SC',
                        'Microsoft YaHei',
                        'NotoSansSC',
                        'sans-serif',
                      ],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
