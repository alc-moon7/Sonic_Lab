import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingDotIndicator extends StatelessWidget {
  const OnboardingDotIndicator({
    super.key,
    required this.currentIndex,
    required this.length,
  });

  final int currentIndex;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(length, (index) {
        final selected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: selected ? AppColors.water : AppColors.controlSurface,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
