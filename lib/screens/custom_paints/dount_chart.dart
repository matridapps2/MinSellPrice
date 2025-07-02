import 'dart:math';

import 'package:flutter/material.dart';

import 'package:minsellprice/screens/widgets/price_proposition_chart.dart';
import 'package:minsellprice/size.dart';

const List<double> points = [.3, .4, .15, .1, .05];

class DountChart extends CustomPainter {
  final List<PricePropositionColor> chartData;

  DountChart({required this.chartData});

  /*Paints*/

  final linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.white
    ..strokeWidth = 2.0;

  final midPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final centerPoint = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width * .9;
    final rect =
        Rect.fromCenter(center: centerPoint, width: radius, height: radius);
    double startAngle = 0.0;

    /*Drawing Segments*/

    _drawingSectors(canvas, rect, startAngle);

    /*Drawing Lines*/
    startAngle = 0.0;
    _drawingLines(radius, startAngle, centerPoint, canvas);

    /*Drawing Labels*/
    startAngle = 0.0;
    _drawingLabels(canvas, centerPoint, startAngle, radius);
  }

  void _drawingLabels(
      Canvas canvas, Offset centerPoint, double startAngle, double radius) {
    for (var element in chartData) {
      double sweepAngle = returnPercentage(model: element) * 360 * pi / 180;

      drawLabels(
          canvas: canvas,
          centerPoint: centerPoint,
          startingAngle: startAngle,
          sweepAngle: sweepAngle,
          radius: radius,
          labelValue: element.value.toString());

      startAngle += sweepAngle;
    }
  }

  void _drawingLines(
      double radius, double startAngle, Offset centerPoint, Canvas canvas) {
    for (var element in chartData) {
      double sweepAngle = returnPercentage(model: element) * 360 * pi / 180;

      // drawSectors(element, canvas, rect, startAngle);

      drawLines(radius, startAngle, sweepAngle, centerPoint, canvas);
      canvas.drawCircle(centerPoint, radius * .3, midPaint);
      startAngle += sweepAngle;
    }
  }

  void _drawingSectors(Canvas canvas, Rect rect, double startAngle) {
    for (var element in chartData) {
      double sweepAngle = returnPercentage(model: element) * 360 * pi / 180;
      drawSectors(returnPercentage(model: element), canvas, rect, startAngle,
          element.color);

      // drawLines(radius, startAngle, sweepAngle, centerPoint, canvas);
      startAngle += sweepAngle;
    }
  }

  /*Painting Methods*/
  void drawLines(double radius, double startAngle, double sweepAngle,
      Offset centerPoint, Canvas canvas) {
    final dx = radius / 2.0 * cos(startAngle);
    final dy = radius / 2.0 * sin(startAngle);
    final p2 = centerPoint + Offset(dx, dy);

    canvas.drawLine(centerPoint, p2, linePaint);
  }

  double drawSectors(double element, Canvas canvas, Rect rect,
      double startAngle, Color color) {
    final sweepAngle = element * 360.0 * pi / 180;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
    return sweepAngle;
  }

  TextPainter measureText(
      {required String value,
      TextStyle? style,
      double? maxWidth,
      TextAlign? textAlignment}) {
    final textSpan = TextSpan(
        text: value,
        style: style ?? TextStyle(fontSize: w * .035, color: Colors.black));
    final textPainter = TextPainter(
        text: textSpan,
        textAlign: textAlignment ?? TextAlign.center,
        textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: 50);

    return textPainter;
  }

  void drawLabels(
      {required Canvas canvas,
      required Offset centerPoint,
      required double startingAngle,
      required double sweepAngle,
      required String labelValue,
      required double radius}) {
    final r = radius * .4;
    final dx = r * cos(startingAngle + sweepAngle / 2);
    final dy = r * sin(startingAngle + sweepAngle / 2);
    final textPosition = centerPoint + Offset(dx, dy);
    drawCenteredText(
      canvas: canvas,
      position: textPosition,
      dataValue: labelValue,
    );
  }

  Size drawCenteredText(
      {required Canvas canvas,
      required String dataValue,
      required Offset position}) {
    final tp = measureText(value: dataValue);
    final pos = position + Offset(-tp.width / 2, -tp.height / 2);
    tp.paint(canvas, pos);
    return tp.size;
  }

  double returnPercentage({required PricePropositionColor model}) {
    double percentage = 0.0;

    double totalProducts = 0;

    for (PricePropositionColor element in chartData) {
      totalProducts = totalProducts + element.value;
    }

    percentage = model.value / totalProducts;

    print(percentage);
    return percentage;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
