import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DustBadge extends StatelessWidget {
  const DustBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lime.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lime.withOpacity(0.35)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speaker, color: AppColors.lime, size: 14),
          SizedBox(width: 8),
          Text(
            'SONIC DUST REMOVAL',
            style: TextStyle(
              color: AppColors.lime,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
