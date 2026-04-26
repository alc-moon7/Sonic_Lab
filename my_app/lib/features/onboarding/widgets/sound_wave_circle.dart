import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SoundWaveCircle extends StatefulWidget {
  const SoundWaveCircle({super.key});

  @override
  State<SoundWaveCircle> createState() => _SoundWaveCircleState();
}

class _SoundWaveCircleState extends State<SoundWaveCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 190,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(190),
                painter: _SoundWaveCirclePainter(progress: _controller.value),
              ),
              const Icon(
                Icons.graphic_eq,
                color: AppColors.background,
                size: 38,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SoundWaveCirclePainter extends CustomPainter {
  const _SoundWaveCirclePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var i = 0; i < 4; i += 1) {
      final local = (progress + (i * 0.22)) % 1;
      final radius = 34 + (local * 68);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.water.withOpacity((1 - local) * 0.55);
      canvas.drawCircle(center, radius, paint);
    }
    final inner = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF74F6FF), AppColors.water],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(center, 42 + math.sin(progress * math.pi * 2) * 4, inner);
  }

  @override
  bool shouldRepaint(covariant _SoundWaveCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
