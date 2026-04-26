import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List<Widget>.generate(children.length, (index) {
          final child = children[index];
          if (index == 0) {
            return child;
          }
          return Column(
            children: [
              Divider(
                color: AppColors.controlSurface.withOpacity(0.35),
                height: 1,
              ),
              child,
            ],
          );
        }),
      ),
    );
  }
}
