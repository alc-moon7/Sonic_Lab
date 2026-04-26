import 'package:flutter/material.dart';

import '../../../core/constants/duration_constants.dart';
import '../../../core/theme/app_colors.dart';

class PhoneScanIllustration extends StatefulWidget {
  const PhoneScanIllustration({super.key});

  @override
  State<PhoneScanIllustration> createState() => _PhoneScanIllustrationState();
}

class _PhoneScanIllustrationState extends State<PhoneScanIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DurationConstants.scanSweep,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 210,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _PhoneScanPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _PhoneScanPainter extends CustomPainter {
  const _PhoneScanPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(42, 8, size.width - 84, size.height - 16),
      const Radius.circular(26),
    );
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = AppColors.water;
    final glass = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.water.withOpacity(0.05);
    canvas.drawRRect(phoneRect, glass);
    canvas.drawRRect(phoneRect, outline);

    final scanX = phoneRect.left + (phoneRect.width * progress);
    final scanPaint = Paint()
      ..strokeWidth = 3
      ..color = AppColors.water.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(
      Offset(scanX, phoneRect.top + 16),
      Offset(scanX, phoneRect.bottom - 16),
      scanPaint,
    );

    final speakerPaint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.textSecondary;
    canvas.drawLine(
      Offset(size.width / 2 - 16, phoneRect.top + 16),
      Offset(size.width / 2 + 16, phoneRect.top + 16),
      speakerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PhoneScanPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
