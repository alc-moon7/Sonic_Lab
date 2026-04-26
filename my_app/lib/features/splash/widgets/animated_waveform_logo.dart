import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/duration_constants.dart';
import '../../../core/theme/app_colors.dart';

class AnimatedWaveformLogo extends StatefulWidget {
  const AnimatedWaveformLogo({super.key});

  @override
  State<AnimatedWaveformLogo> createState() => _AnimatedWaveformLogoState();
}

class _AnimatedWaveformLogoState extends State<AnimatedWaveformLogo>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List<AnimationController>.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: DurationConstants.splashBarPulse,
        lowerBound: 0.3,
        upperBound: 1,
      ),
    );
    for (var i = 0; i < _controllers.length; i += 1) {
      Timer(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List<Widget>.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controllers[index],
            builder: (context, child) {
              return Transform.scale(
                scaleY: _controllers[index].value,
                child: child,
              );
            },
            child: Container(
              width: 7,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.water,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.water.withOpacity(0.3),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
