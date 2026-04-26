import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import 'sonic_bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: child,
      bottomNavigationBar: SonicBottomNavBar(
        activeIndex: _activeIndex(location),
        onSelected: (index) => _goToIndex(context, index),
      ),
    );
  }

  int _activeIndex(String location) {
    if (location.startsWith('/dust')) {
      return AppConstants.bottomNavDustIndex;
    }
    if (location.startsWith('/sonic')) {
      return AppConstants.bottomNavSonicIndex;
    }
    if (location.startsWith('/settings')) {
      return AppConstants.bottomNavSettingsIndex;
    }
    return AppConstants.bottomNavWaterIndex;
  }

  void _goToIndex(BuildContext context, int index) {
    switch (index) {
      case AppConstants.bottomNavWaterIndex:
        context.goNamed(AppRoutes.water);
      case AppConstants.bottomNavDustIndex:
        context.goNamed(AppRoutes.dust);
      case AppConstants.bottomNavSonicIndex:
        context.goNamed(AppRoutes.sonic);
      case AppConstants.bottomNavSettingsIndex:
        context.goNamed(AppRoutes.settings);
    }
  }
}
