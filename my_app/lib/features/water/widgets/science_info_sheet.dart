import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ScienceInfoSheet extends StatelessWidget {
  const ScienceInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How the Sound Works',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Low-frequency tones move the speaker membrane with enough displacement to push trapped droplets outward. Dust mode uses a safer high-frequency sweep to loosen particles from mesh and port edges.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
