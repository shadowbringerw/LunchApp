import 'package:flutter/material.dart';

class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({
    super.key,
    required this.assetPath,
    this.alignment = Alignment.bottomRight,
    this.height = 500,
  });

  final String assetPath;
  final Alignment alignment;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: SizedBox(
          height: height,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading asset $assetPath: $error');
              // Fallback to a stylish placeholder if asset is missing
              return _StylishPlaceholder(height: height);
            },
          ),
        ),
      ),
    );
  }
}

class _StylishPlaceholder extends StatelessWidget {
  const _StylishPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    // A stylized silhouette placeholder
    return Container(
      height: height,
      width: height * 0.6,
      margin: const EdgeInsets.only(right: 20),
      child: CustomPaint(
        painter: _SilhouettePainter(),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1a1a1a).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw a rough anime character silhouette
    path.moveTo(size.width * 0.5, 0); // Head top
    path.cubicTo(
      size.width * 0.8, size.height * 0.1, 
      size.width * 0.9, size.height * 0.2, 
      size.width * 0.5, size.height * 0.3 // Neck
    );
    path.cubicTo(
      size.width * 1.2, size.height * 0.4, 
      size.width, size.height, 
      size.width * 0.8, size.height // Right shoulder down
    );
    path.lineTo(size.width * 0.2, size.height); // Bottom
    path.cubicTo(
      0, size.height, 
      -size.width * 0.2, size.height * 0.4, 
      size.width * 0.5, size.height * 0.3 // Left shoulder up to neck
    );
    path.close();

    canvas.drawPath(path, paint);

    // Add some "JOKER" text overlay
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'JOKER',
        style: TextStyle(
          color: const Color(0xFFEF4444).withOpacity(0.8),
          fontSize: 40,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.7);
    canvas.rotate(-0.2);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
