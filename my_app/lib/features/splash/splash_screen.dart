import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/duration_constants.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/animated_waveform_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(DurationConstants.splashDuration, _navigate);
  }

  void _navigate() {
    if (!mounted) {
      return;
    }
    final settings = ref.read(settingsProvider);
    context.goNamed(
      settings.hasCompletedOnboarding ? AppRoutes.water : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedWaveformLogo(),
                const SizedBox(height: 18),
                Text(
                  'SONIC_LAB',
                  style: AppTextStyles.wordmark.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Audio Cleaning Technology',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: DurationConstants.splashLogoEntrance)
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: DurationConstants.splashLogoEntrance,
                ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(34, 0, 34, 24),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: DurationConstants.splashDuration,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 2,
                      backgroundColor: AppColors.controlSurface,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.water),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
