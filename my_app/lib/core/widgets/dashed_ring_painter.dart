import 'dart:math' as math;

import 'package:flutter/material.dart';

class DashedRingPainter extends CustomPainter {
  const DashedRingPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = color;
    const dashCount = 34;
    const gapRadians = 0.065;
    const sweep = (math.pi * 2 / dashCount) - gapRadians;
    for (var i = 0; i < dashCount; i += 1) {
      final start = i * math.pi * 2 / dashCount;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
