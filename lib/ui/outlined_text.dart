import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  const OutlinedText({
    super.key,
    required this.text,
    required this.style,
    this.strokeWidth = 4,
    this.strokeColor = const Color(0xFF050505),
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final TextStyle style;
  final double strokeWidth;
  final Color strokeColor;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final stroke = style.copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = strokeColor,
    );
    final fill = style;

    return Stack(
      children: [
        Text(text, style: stroke, textAlign: textAlign, maxLines: maxLines),
        Text(text, style: fill, textAlign: textAlign, maxLines: maxLines),
      ],
    );
  }
}

