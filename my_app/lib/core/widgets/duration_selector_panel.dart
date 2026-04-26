import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'segmented_picker.dart';

class DurationSelectorPanel extends StatelessWidget {
  const DurationSelectorPanel({
    super.key,
    required this.selectedSeconds,
    required this.onChanged,
    this.activeColor = AppColors.water,
    this.showAutomaticPill = true,
  });

  final int selectedSeconds;
  final FutureOr<void> Function(int seconds) onChanged;
  final Color activeColor;
  final bool showAutomaticPill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('DURATION', style: AppTextStyles.eyebrow),
              const Spacer(),
              if (showAutomaticPill)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: activeColor.withOpacity(0.35)),
                  ),
                  child: Text(
                    'Automatic Mode',
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedPicker(
            values: SegmentedPicker.standardValues,
            selectedValue: selectedSeconds,
            activeColor: activeColor,
            onChanged: (value) async => onChanged(value),
          ),
        ],
      ),
    );
  }
}
