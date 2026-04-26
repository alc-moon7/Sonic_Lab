import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/onboarding_dot_indicator.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/phone_scan_illustration.dart';
import 'widgets/sound_wave_circle.dart';
import 'widgets/volume_tip_illustration.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _pageIndex = 0;

  static const int _pageCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.goNamed(AppRoutes.water);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _pageIndex = index),
              children: const [
                OnboardingPage(
                  illustration: SoundWaveCircle(),
                  kicker: 'MEET SONIC_LAB',
                  title: 'Clean Your Phone with Sound',
                  body:
                      'High-frequency tones physically eject water and dust from your speaker grills — no shaking required.',
                ),
                OnboardingPage(
                  illustration: PhoneScanIllustration(),
                  kicker: 'PHONE DETECTION',
                  title: 'Optimised for Your Device',
                  body:
                      'We automatically detect your phone model and calibrate the exact frequency range for your speaker hardware.',
                ),
                OnboardingPage(
                  illustration: VolumeTipIllustration(),
                  kicker: 'TURN VOLUME UP',
                  title: 'One Tip Before You Start',
                  body:
                      'Always set your volume to maximum and place your phone screen-down on a flat surface for best results.',
                ),
              ],
            ),
            if (_pageIndex < _pageCount - 1)
              Positioned(
                top: 8,
                right: AppConstants.horizontalPadding,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
            Positioned(
              left: AppConstants.horizontalPadding,
              right: AppConstants.horizontalPadding,
              bottom: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OnboardingDotIndicator(
                    currentIndex: _pageIndex,
                    length: _pageCount,
                  ),
                  const SizedBox(height: 24),
                  if (_pageIndex == _pageCount - 1)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _finish,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.water,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.pillRadius),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
