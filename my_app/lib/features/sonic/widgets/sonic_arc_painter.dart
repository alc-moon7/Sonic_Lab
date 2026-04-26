import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SonicArcPainter extends CustomPainter {
  const SonicArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 16;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = 160 * math.pi / 180;
    const totalSweep = 220 * math.pi / 180;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = AppColors.controlSurface;
    canvas.drawArc(rect, startAngle, totalSweep, false, track);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [AppColors.waterBase, AppColors.water, AppColors.waterBase],
      ).createShader(rect);
    canvas.drawArc(
      rect,
      startAngle,
      totalSweep * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SonicArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
