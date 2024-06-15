import 'dart:math' as math;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../src/theme/ecg_chart_theme.dart' hide ECGChartTheme;

class ECGChartPainter extends CustomPainter {
  ECGChartPainter({
    required this.latestPoints,
    required this.oldPoints,
    this.themeData,
  })  : pointsGap = themeData?.pointsGap ?? kPointsGap,
        smooth = themeData?.smooth ?? kSmooth;

  final List<double> latestPoints;
  final List<double> oldPoints;
  final ECGChartThemeData? themeData;
  final double pointsGap;
  final double smooth;

  late final Paint _linePaint = Paint()
    ..color = themeData?.lineColor ?? kLineColor
    ..strokeWidth = themeData?.lineWidth ?? kLineWidth
    ..style = PaintingStyle.stroke;

  late final Paint _indicatorPaint = Paint()
    ..color = themeData?.indicatorColor ?? kIndicatorColor
    ..style = PaintingStyle.fill
    ..maskFilter = themeData?.indicatorMaskFilter;

  @override
  void paint(Canvas canvas, Size size) {
    Path latestPointsPath = Path();

    Offset? indicator;

    if (latestPoints.isNotEmpty) {
      latestPointsPath = _drawLine(
        path: Path()..moveTo(0, latestPoints.first),
        points: latestPoints,
        calculateX: (int index) => index * pointsGap,
      );

      indicator = Offset(
        (latestPoints.length - 1) * pointsGap,
        latestPoints.last,
      );
    }

    Path oldPointsPath = Path();

    if (oldPoints.isNotEmpty) {
      final List<double> points = <double>[...oldPoints];

      if (latestPoints.isEmpty) {
        indicator = Offset(
          (oldPoints.length - 1) * pointsGap,
          oldPoints.last,
        );
      } else {
        points.add(latestPoints.first);
      }

      oldPointsPath = _drawLine(
        path: Path()
          ..moveTo(
            latestPoints.length * pointsGap,
            oldPoints.first,
          ),
        points: points,
        calculateX: (int index) => (latestPoints.length + index) * pointsGap,
      );
    }

    canvas
      ..drawPath(latestPointsPath, _linePaint..shader = null)
      ..drawPath(
        oldPointsPath,
        _linePaint
          ..shader = LinearGradient(
            colors: <Color>[
              _linePaint.color.withOpacity(0),
              _linePaint.color.withOpacity(0),
              _linePaint.color,
              _linePaint.color,
            ],
            stops: <double>[
              0.0,
              2 / oldPoints.length,
              8 / oldPoints.length,
              1.0,
            ],
          ).createShader(
            oldPointsPath.getBounds(),
          ),
      );

    if (indicator != null) {
      final double radius = themeData?.indicatorRadius ?? kIndicatorRadius;

      canvas.drawOval(
        Rect.fromCircle(
          center: indicator,
          radius: radius,
        ),
        _indicatorPaint,
      );
    }
  }

  Path _drawLine({
    required Path path,
    required List<double> points,
    required double Function(int index) calculateX,
  }) {
    // By https://github.com/apache/echarts/blob/master/src/chart/line/poly.ts
    if (smooth > 0.0) {
      // Is first coordinate
      Offset controlPoint0 = Offset(calculateX(0), points.first);
      Offset prev = Offset(calculateX(0), points.first);

      Offset controlPoint1;

      for (int index = 1; index < points.length - 1; index++) {
        final Offset current = Offset(calculateX(index), points[index]);
        final Offset next = Offset(calculateX(index + 1), points[index + 1]);

        double ratio = 0.5;
        Offset vector = Offset.zero;
        Offset nextControlPoint0;

        vector = Offset(next.dx - prev.dx, next.dy - prev.dy);

        final Offset d0 = Offset(current.dx - prev.dx, current.dy - prev.dy);
        final Offset d1 = Offset(next.dx - current.dx, next.dy - current.dy);

        final double lenPrevSeg = d0.distance;
        final double lenNextSeg = d1.distance;

        // Use ratio of segment length.
        ratio = lenNextSeg / (lenNextSeg + lenPrevSeg);

        controlPoint1 = Offset(
          current.dx - vector.dx * smooth * (1 - ratio),
          current.dy - vector.dy * smooth * (1 - ratio),
        );

        // controlPoint0 of next segment.
        nextControlPoint0 = Offset(
          current.dx + vector.dx * smooth * ratio,
          current.dy + vector.dy * smooth * ratio,
        );

        // Smooth constraint between point and next point.
        // Avoid exceeding extreme after smoothing.
        nextControlPoint0 = Offset(
          nextControlPoint0.dx.clamp(
            math.min(next.dx, current.dx),
            math.max(next.dx, current.dx),
          ),
          nextControlPoint0.dy.clamp(
            math.min(next.dy, current.dy),
            math.max(next.dy, current.dy),
          ),
        );

        // Recalculate controlPoint1 based on the adjusted controlPoint0 of next
        // segment.
        vector = Offset(
          nextControlPoint0.dx - current.dx,
          nextControlPoint0.dy - current.dy,
        );

        controlPoint1 = Offset(
          current.dx - vector.dx * lenPrevSeg / lenNextSeg,
          current.dy - vector.dy * lenPrevSeg / lenNextSeg,
        );

        // Smooth constraint between point and pre point.
        // Avoid exceeding extreme after smoothing.
        controlPoint1 = Offset(
          controlPoint1.dx.clamp(
            math.min(prev.dx, current.dx),
            math.max(prev.dx, current.dx),
          ),
          controlPoint1.dy.clamp(
            math.min(prev.dy, current.dy),
            math.max(prev.dy, current.dy),
          ),
        );

        // Adjust nextControlPoint0 again.
        vector = Offset(
          current.dx - controlPoint1.dx,
          current.dy - controlPoint1.dy,
        );
        nextControlPoint0 = Offset(
          current.dx + vector.dx * lenNextSeg / lenPrevSeg,
          current.dy + vector.dy * lenNextSeg / lenPrevSeg,
        );

        path.cubicTo(
          controlPoint0.dx,
          controlPoint0.dy,
          controlPoint1.dx,
          controlPoint1.dy,
          current.dx,
          current.dy,
        );

        controlPoint0 = Offset(nextControlPoint0.dx, nextControlPoint0.dy);
        prev = Offset(current.dx, current.dy);
      }

      // Is last coordinate
      final Offset last = Offset(calculateX(points.length - 1), points.last);
      path.cubicTo(
        controlPoint0.dx,
        controlPoint0.dy,
        last.dx,
        last.dy,
        last.dx,
        last.dy,
      );
    } else {
      path = points.foldIndexed(
        path,
        (int index, Path path, double value) =>
            path..lineTo(calculateX(index), value),
      );
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
