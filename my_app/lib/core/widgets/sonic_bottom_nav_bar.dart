import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class SonicBottomNavBar extends StatelessWidget {
  const SonicBottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onSelected,
  });

  final int activeIndex;
  final ValueChanged<int> onSelected;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(Icons.water_drop, 'WATER', AppColors.water),
    _NavItem(Icons.air, 'DUST', AppColors.lime),
    _NavItem(Icons.vibration, 'SONIC', AppColors.water),
    _NavItem(Icons.settings, 'LABS', AppColors.water),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: AppConstants.navHeight,
        color: AppColors.navBar,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == activeIndex;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onSelected(index),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (selected)
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: item.activeColor.withOpacity(0.42),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color:
                              selected ? item.activeColor : AppColors.inactive,
                          size: 26,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: selected
                              ? Padding(
                                  key: ValueKey(item.label),
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: item.activeColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label, this.activeColor);

  final IconData icon;
  final String label;
  final Color activeColor;
}
