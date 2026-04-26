import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/frequency_constants.dart';
import '../../core/providers/sonic_lab_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_top_bar.dart';
import '../water/widgets/science_info_sheet.dart';
import 'widgets/sonic_dial_card.dart';
import 'widgets/sonic_preset_card.dart';

class SonicLabScreen extends ConsumerWidget {
  const SonicLabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sonicLabProvider);
    final notifier = ref.read(sonicLabProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppConstants.navHeight + 34),
          child: Column(
            children: [
              AppTopBar(
                actions: [
                  TopIconButton(
                    icon: Icons.info,
                    tooltip: 'Sonic Lab Info',
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: AppColors.surface,
                      builder: (context) => const ScienceInfoSheet(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  56,
                  AppConstants.horizontalPadding,
                  0,
                ),
                child: Column(
                  children: [
                    Text(
                      'CURRENT FREQUENCY',
                      style: AppTextStyles.eyebrow.copyWith(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: state.frequency.round().toString(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 72,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(
                            text: ' Hz',
                            style: TextStyle(
                              color: AppColors.water,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    SonicDialCard(
                      progress: state.sliderProgress,
                      sliderValue: state.sliderProgress,
                      isManual: state.sweepMode == SonicSweepMode.manual,
                      onToggleSweep: notifier.toggleSweepMode,
                      onSliderChanged: notifier.setFrequencyFromProgress,
                    ),
                    const SizedBox(height: 38),
                    _PlayButton(
                      isPlaying: state.isPlaying,
                      onTap: () async => notifier.togglePlayback(),
                    ),
                    const SizedBox(height: 44),
                    Row(
                      children: [
                        SonicPresetCard(
                          icon: Icons.water_drop,
                          iconColor: AppColors.lime,
                          title: 'Eject Water',
                          subtitle: '165HZ PULSE',
                          onTap: () {
                            notifier.setFrequency(
                                FrequencyConstants.waterGeneralHz);
                            context.goNamed(AppRoutes.water);
                          },
                        ),
                        const SizedBox(width: 16),
                        SonicPresetCard(
                          icon: Icons.air,
                          iconColor: AppColors.warning,
                          title: 'Clear Dust',
                          subtitle: 'VARIED SWEEP',
                          onTap: () => context.goNamed(AppRoutes.dust),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isPlaying, required this.onTap});

  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppConstants.playButtonSize,
        height: AppConstants.playButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.water,
          boxShadow: [
            BoxShadow(
              color: AppColors.water.withOpacity(0.42),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
          color: AppColors.background,
          size: 34,
        ),
      ),
    );
  }
}
