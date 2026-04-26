import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DustDotWave extends StatefulWidget {
  const DustDotWave({super.key});

  @override
  State<DustDotWave> createState() => _DustDotWaveState();
}

class _DustDotWaveState extends State<DustDotWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          children: List<Widget>.generate(10, (index) {
            final phase = ((_controller.value * 10) - index).abs();
            final opacity = (1 - (phase % 10) / 10).clamp(0.35, 1.0);
            final height = 14 + (12 * opacity);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.lime.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
