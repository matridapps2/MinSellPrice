import 'package:flutter/material.dart';

class PriceRibbonPainter extends CustomPainter {
  final Color ribbonColor;
  final double ribbonHeight;
  final double ribbonWidth;
  final String priceText;

  PriceRibbonPainter({
    required this.ribbonColor,
    required this.ribbonHeight,
    required this.ribbonWidth,
    required this.priceText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint ribbonPaint = Paint()
      ..color = ribbonColor
      ..style = PaintingStyle.fill;

    final double halfWidth = ribbonWidth / 2;
    final double halfHeight = ribbonHeight / 2;

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(halfWidth, halfHeight)
      ..lineTo(ribbonWidth, 0)
      ..lineTo(ribbonWidth, ribbonHeight)
      ..lineTo(halfWidth, halfHeight)
      ..close();

    canvas.drawPath(path, ribbonPaint);

    // Draw the price text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: priceText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final double textX = (ribbonWidth - textPainter.width) / 2;
    final double textY = (ribbonHeight - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
