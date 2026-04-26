import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class VolumeTipIllustration extends StatelessWidget {
  const VolumeTipIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.water.withOpacity(0.12),
              border: Border.all(color: AppColors.water.withOpacity(0.35)),
            ),
          ),
          const Icon(Icons.volume_up_rounded, color: AppColors.water, size: 76),
          Positioned(
            right: 42,
            top: 30,
            child: Transform.rotate(
              angle: -0.7,
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: AppColors.lime,
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
