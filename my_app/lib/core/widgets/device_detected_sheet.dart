import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/phone_profile.dart';
import '../theme/app_colors.dart';

class DeviceDetectedSheet extends StatelessWidget {
  const DeviceDetectedSheet({
    super.key,
    required this.profile,
    required this.onApply,
    required this.onUseDefaults,
  });

  final PhoneProfile profile;
  final FutureOr<void> Function() onApply;
  final FutureOr<void> Function() onUseDefaults;

  @override
  Widget build(BuildContext context) {
    final initial =
        profile.brand.isEmpty ? '?' : profile.brand[0].toUpperCase();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.water.withOpacity(0.18),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.water,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '${profile.brand} ${profile.model} Detected',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.speakerInfo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.water,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                await onApply();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Apply Optimised Settings',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await onUseDefaults();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Use Defaults'),
          ),
        ],
      ),
    );
  }
}
