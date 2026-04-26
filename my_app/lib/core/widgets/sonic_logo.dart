import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SonicLogo extends StatelessWidget {
  const SonicLogo({
    super.key,
    this.dimmed = false,
    this.centered = false,
    this.showWordmark = true,
  });

  final bool dimmed;
  final bool centered;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final color = dimmed ? AppColors.controlSurface : AppColors.water;
    final children = <Widget>[
      WaveformMark(color: color),
      if (showWordmark) ...[
        const SizedBox(width: 10),
        Text(
          'SONIC_LAB',
          style: AppTextStyles.wordmark.copyWith(
            color: color,
            fontSize: dimmed ? 20 : 16,
          ),
        ),
      ],
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: children,
    );
  }
}

class WaveformMark extends StatelessWidget {
  const WaveformMark({super.key, required this.color, this.size = 22});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final widths = <double>[2, 2, 2, 2, 2];
    final heights = <double>[12, 20, 28, 20, 12];
    return SizedBox(
      width: size,
      height: size + 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List<Widget>.generate(widths.length, (index) {
          return Container(
            width: widths[index],
            height: heights[index] * (size / 22),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
