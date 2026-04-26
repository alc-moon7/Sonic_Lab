import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'sonic_arc_painter.dart';

class SonicDialCard extends StatelessWidget {
  const SonicDialCard({
    super.key,
    required this.progress,
    required this.sliderValue,
    required this.onSliderChanged,
    required this.onToggleSweep,
    required this.isManual,
  });

  final double progress;
  final double sliderValue;
  final ValueChanged<double> onSliderChanged;
  final VoidCallback onToggleSweep;
  final bool isManual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress),
            duration: const Duration(milliseconds: 220),
            builder: (context, value, child) {
              return SizedBox.square(
                dimension: AppConstants.sonicDialSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size.square(AppConstants.sonicDialSize),
                      painter: SonicArcPainter(progress: value),
                    ),
                    Container(
                      width: 138,
                      height: 138,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF22232C),
                      ),
                    ),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.vibration, color: AppColors.water, size: 42),
                        SizedBox(height: 12),
                        Text('SINE WAVE', style: AppTextStyles.eyebrow),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 34),
          Row(
            children: [
              const Text('RANGE CONTROL', style: AppTextStyles.eyebrow),
              const Spacer(),
              TextButton(
                onPressed: onToggleSweep,
                child: Text(
                  isManual ? 'MANUAL SWEEP' : 'AUTO SWEEP',
                  style: AppTextStyles.eyebrow.copyWith(
                    color: AppColors.water,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.water,
              inactiveTrackColor: const Color(0xFF050507),
              thumbColor: AppColors.textPrimary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayColor: AppColors.water.withOpacity(0.15),
            ),
            child: Slider(
              value: sliderValue,
              onChanged: onSliderChanged,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Text('20HZ', style: _SliderLabelStyle()),
                Spacer(),
                Text('10KHZ', style: _SliderLabelStyle()),
                Spacer(),
                Text('20KHZ', style: _SliderLabelStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderLabelStyle extends TextStyle {
  const _SliderLabelStyle()
      : super(
          color: AppColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        );
}
