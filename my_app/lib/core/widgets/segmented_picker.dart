import 'package:flutter/material.dart';

import '../constants/duration_constants.dart';
import '../theme/app_colors.dart';

class SegmentedPicker extends StatelessWidget {
  const SegmentedPicker({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.onChanged,
    this.activeColor = AppColors.water,
    this.showOuterBackground = true,
  });

  final List<int> values;
  final int selectedValue;
  final ValueChanged<int> onChanged;
  final Color activeColor;
  final bool showOuterBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: showOuterBackground
            ? const Color(0xFF050507)
            : AppColors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: values.map((value) {
          final selected = value == selectedValue;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TextButton(
                onPressed: () => onChanged(value),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  backgroundColor: selected
                      ? AppColors.controlSurface
                      : AppColors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  '${value}s',
                  style: TextStyle(
                    color: selected ? activeColor : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  static List<int> get standardValues =>
      DurationConstants.cleaningDurationsSeconds;
}
