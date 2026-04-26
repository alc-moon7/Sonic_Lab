import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import 'sonic_logo.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.actions,
    this.logoColor,
  });

  final List<Widget> actions;
  final Color? logoColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.horizontalPadding,
        right: AppConstants.horizontalPadding,
        top: AppConstants.screenTopPadding,
      ),
      child: Row(
        children: [
          const SonicLogo(),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}

class TopIconButton extends StatelessWidget {
  const TopIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.textSecondary,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppConstants.iconButtonSize,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
