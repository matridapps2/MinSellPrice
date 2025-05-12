import 'dart:math';

import 'package:flutter/material.dart';

class VerticalWavePainter extends CustomPainter {
  final Paint _paint = Paint();
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    const numArcs = 5; // You can adjust the number of arcs
    const arcWidth = 20.0; // Width of the arcs
    const arcSpacing = 20.0; // Spacing between arcs

    for (int i = 0; i < numArcs; i++) {
      var startX = _random.nextDouble() * size.width;
      final endX = startX + arcWidth;
      final centerY = _random.nextDouble() * size.height;

      _paint.color = Colors.blue; // Change the color as needed

      // Adjust the arc radius and sweep angle for different shapes
      const arcRadius = arcWidth / 2;
      const startAngle = -pi / 2;
      const sweepAngle = pi;

      canvas.drawArc(
        Rect.fromPoints(Offset(startX, centerY - arcRadius),
            Offset(endX, centerY + arcRadius)),
        startAngle,
        sweepAngle,
        true,
        _paint,
      );

      startX += arcWidth + arcSpacing;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class RPSCustomPainter extends CustomPainter {
  final Color color;

  const RPSCustomPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paintFill0 = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;
    // final shape = RRect.fromRectAndRadius(
    //   Rect.fromLTWH(0, 0, 200, 100),
    //   Radius.circular(3),
    // );

    Path path_0 = Path();
    path_0.moveTo(0, size.height);
    path_0.quadraticBezierTo(size.width, size.height * 0.8416000,
        size.width * 0.1821500, size.height * 0.8104000);
    path_0.cubicTo(
        size.width * 0.3214000,
        size.height * 0.6935000,
        size.width * 0.7958000,
        size.height * 0.7683000,
        size.width * 0.9278000,
        size.height * 0.8656000);
    path_0.cubicTo(
        size.width * 1.0047500,
        size.height * 0.7026000,
        size.width * 1.0064500,
        size.height * 0.2001000,
        size.width,
        size.height * -0.0025000);
    path_0.quadraticBezierTo(size.width * 0.8118000, size.height * -0.0016000,
        size.width * -0.0019000, size.height * 0.0085000);

    canvas.drawPath(path_0, paintFill0);
    canvas.drawShadow(path_0.shift(const Offset(0, 1)), color, 4.0, true);

    // Layer 1

    Paint paintStroke0 = Paint()
      ..color = const Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.005
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_0, paintStroke0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}