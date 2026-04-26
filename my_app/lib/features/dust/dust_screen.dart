import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/audio_session_provider.dart';
import '../../core/providers/device_profile_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/device_detector.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/duration_selector_panel.dart';
import '../../core/widgets/glow_circle_button.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/session_status_card.dart';
import '../../models/phone_profile.dart';
import '../../models/session_result.dart';
import '../water/widgets/science_info_sheet.dart';
import 'widgets/dust_badge.dart';
import 'widgets/high_frequency_shield_card.dart';

class DustScreen extends ConsumerStatefulWidget {
  const DustScreen({super.key});

  @override
  ConsumerState<DustScreen> createState() => _DustScreenState();
}

class _DustScreenState extends ConsumerState<DustScreen> {
  ProviderSubscription<AsyncValue<SessionState>>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _sessionSubscription = ref.listenManual(audioSessionProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Audio failed to start. Turn volume up and try again.'),
          ),
        );
      }
      final session = next.valueOrNull;
      if (session?.status == SessionStatus.complete &&
          session?.mode == CleaningMode.dust &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(session?.message ?? 'Session Complete')),
        );
      }
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(deviceProfileProvider).valueOrNull ??
        DeviceDetector.defaultProfile;
    final session =
        ref.watch(audioSessionProvider).valueOrNull ?? SessionState.idle();
    final isDustPlaying =
        session.isPlaying && session.mode == CleaningMode.dust;

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
                    icon: Icons.history,
                    tooltip: 'History',
                    onPressed: () {},
                  ),
                  TopIconButton(
                    icon: Icons.help,
                    tooltip: 'Help',
                    onPressed: _showHelpSheet,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  46,
                  AppConstants.horizontalPadding,
                  0,
                ),
                child: Column(
                  children: [
                    const DustBadge(),
                    const SizedBox(height: 18),
                    const Text(
                      'Precision Airflow',
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Utilizing localized ultrasonic vibrations to dislodge micro-particles from internal mesh.',
                      style: AppTextStyles.subtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26),
                    GlowCircleButton(
                      variant: GlowCircleVariant.dust,
                      icon: Icons.vibration,
                      label: 'Clean Dust',
                      isPlaying: isDustPlaying,
                      progress: session.progress,
                      countdownText:
                          isDustPlaying ? '${session.remainingSeconds}s' : null,
                      onPressed: () =>
                          _startDust(profile, settings.selectedDuration),
                    ),
                    SessionStatusCard(
                      session:
                          isDustPlaying || session.mode == CleaningMode.dust
                              ? session
                              : SessionState.idle(),
                      activeColor: AppColors.lime,
                    ),
                    const SizedBox(height: 30),
                    DurationSelectorPanel(
                      selectedSeconds: settings.selectedDurationSeconds,
                      activeColor: AppColors.lime,
                      showAutomaticPill: false,
                      onChanged: (seconds) => ref
                          .read(settingsProvider.notifier)
                          .setSelectedDuration(seconds),
                    ),
                    const SizedBox(height: 26),
                    const HighFrequencyShieldCard(),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            label: 'INTENSITY',
                            value: '9.8 kHz',
                            accent: AppColors.lime,
                            icon: Icons.bolt,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: MetricCard(
                            label: 'SAFE MODE',
                            value: 'Enabled',
                            accent: AppColors.lime,
                            icon: Icons.warning_amber,
                          ),
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

  Future<void> _startDust(PhoneProfile profile, Duration duration) async {
    try {
      await ref.read(audioSessionProvider.notifier).startDustSession(
            profile,
            duration,
            safeMode: ref.read(settingsProvider).safeMode,
          );
    } on Exception {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start dust session')),
      );
    }
  }

  void _showHelpSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => const ScienceInfoSheet(),
    );
  }
}
