import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/audio_session_provider.dart';
import '../../core/providers/device_profile_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/device_detected_sheet.dart';
import '../../core/widgets/duration_selector_panel.dart';
import '../../core/widgets/glow_circle_button.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/session_status_card.dart';
import '../../core/widgets/tip_card.dart';
import '../../core/utils/device_detector.dart';
import '../../models/phone_profile.dart';
import '../../models/session_result.dart';
import 'widgets/ios_volume_banner.dart';
import 'widgets/science_info_sheet.dart';

class WaterScreen extends ConsumerStatefulWidget {
  const WaterScreen({super.key});

  @override
  ConsumerState<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends ConsumerState<WaterScreen> {
  ProviderSubscription<AsyncValue<SessionState>>? _sessionSubscription;
  bool _deviceSheetQueued = false;

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
          session?.mode == CleaningMode.water &&
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
    final profileAsync = ref.watch(deviceProfileProvider);
    final profile = profileAsync.valueOrNull;
    final session =
        ref.watch(audioSessionProvider).valueOrNull ?? SessionState.idle();
    final isWaterPlaying =
        session.isPlaying && session.mode == CleaningMode.water;
    if (profile != null) {
      _queueDeviceSheet(profile, settings);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  AppTopBar(
                    actions: [
                      TopIconButton(
                        icon: Icons.info,
                        tooltip: 'Science',
                        onPressed: _showScienceSheet,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.horizontalPadding,
                      54,
                      AppConstants.horizontalPadding,
                      0,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Eject Water',
                          style: AppTextStyles.title,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'High-frequency sound waves create vibrations that physically push liquid out of your device\'s speaker grills.',
                          style: AppTextStyles.subtitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        const IosVolumeBanner(),
                        if (defaultTargetPlatform == TargetPlatform.iOS)
                          const SizedBox(height: 10),
                        GlowCircleButton(
                          variant: GlowCircleVariant.water,
                          icon: isWaterPlaying
                              ? Icons.stop_rounded
                              : Icons.water_drop,
                          label: 'Clean Water',
                          isPlaying: isWaterPlaying,
                          progress: session.progress,
                          countdownText: isWaterPlaying
                              ? '${session.remainingSeconds}s'
                              : null,
                          onPressed: () => isWaterPlaying
                              ? _stopActiveSession('Water session stopped')
                              : _startWater(
                                  profile ?? DeviceDetector.defaultProfile,
                                  settings.selectedDuration,
                                ),
                        ),
                        SessionStatusCard(
                          session: isWaterPlaying ||
                                  session.mode == CleaningMode.water
                              ? session
                              : SessionState.idle(),
                          activeColor: AppColors.water,
                        ),
                        const SizedBox(height: 30),
                        DurationSelectorPanel(
                          selectedSeconds: settings.selectedDurationSeconds,
                          onChanged: (seconds) => ref
                              .read(settingsProvider.notifier)
                              .setSelectedDuration(seconds),
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Expanded(
                              child: MetricCard(
                                label: 'FREQUENCY',
                                value:
                                    '${(profile?.waterFrequency ?? 165).round()}Hz',
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: MetricCard(
                                label: 'INTENSITY',
                                value: 'MAX',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        const TipCard(
                          text:
                              'Turn your volume to maximum and place the phone screen-down for optimal results.',
                        ),
                        const SizedBox(height: AppConstants.navHeight + 34),
                      ],
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

  Future<void> _startWater(PhoneProfile profile, Duration duration) async {
    try {
      await ref
          .read(audioSessionProvider.notifier)
          .startWaterSession(profile, duration);
    } on Exception {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start water session')),
      );
    }
  }

  Future<void> _stopActiveSession(String message) async {
    try {
      await ref.read(audioSessionProvider.notifier).stopSession();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on Exception {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to stop session')),
      );
    }
  }

  void _showScienceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => const ScienceInfoSheet(),
    );
  }

  void _queueDeviceSheet(PhoneProfile profile, AppSettings settings) {
    if (_deviceSheetQueued || settings.hasSeenDeviceSheet) {
      return;
    }
    _deviceSheetQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        builder: (context) => DeviceDetectedSheet(
          profile: profile,
          onApply: () =>
              ref.read(settingsProvider.notifier).markDeviceSheetSeen(),
          onUseDefaults: () =>
              ref.read(settingsProvider.notifier).markDeviceSheetSeen(),
        ),
      );
    });
  }
}
