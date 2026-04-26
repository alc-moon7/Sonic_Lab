import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/phone_profile.dart';
import '../../models/session_result.dart';
import '../constants/frequency_constants.dart';
import '../utils/audio_engine.dart';
import '../utils/haptic_helper.dart';
import '../utils/volume_channel.dart';

final audioEngineProvider =
    Provider<AudioEngine>((ref) => AudioEngine.instance);

final volumeChannelProvider = Provider<VolumeChannel>((ref) => VolumeChannel());

final audioSessionProvider =
    AsyncNotifierProvider<AudioSessionNotifier, SessionState>(
  AudioSessionNotifier.new,
);

class AudioSessionNotifier extends AsyncNotifier<SessionState> {
  Timer? _timer;

  @override
  FutureOr<SessionState> build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return SessionState.idle();
  }

  Future<void> startWaterSession(
    PhoneProfile profile,
    Duration duration,
  ) async {
    await _startSession(
      mode: CleaningMode.water,
      duration: duration,
      initialFrequency: profile.waterFrequency,
      playback: () async {
        await ref.read(volumeChannelProvider).setMaxVolume();
        await ref.read(audioEngineProvider).playSineWave(
              profile.waterFrequency,
              amplitude: _waterAmplitude(profile),
            );
      },
      frequencyAtProgress: (_) => profile.waterFrequency,
    );
  }

  Future<void> startDustSession(
    PhoneProfile profile,
    Duration duration, {
    required bool safeMode,
  }) async {
    await _startSession(
      mode: CleaningMode.dust,
      duration: duration,
      initialFrequency: profile.dustSweepStart,
      playback: () async {
        await ref.read(volumeChannelProvider).setMaxVolume();
        await ref.read(audioEngineProvider).playSweep(
              profile.dustSweepStart,
              profile.dustSweepEnd,
              duration.inMilliseconds,
              type: profile.dustSweepType,
              amplitude: safeMode
                  ? profile.maxSafeAmplitude
                  : FrequencyConstants.fullAmplitude,
            );
      },
      frequencyAtProgress: (progress) {
        return switch (profile.dustSweepType) {
          SweepType.linear => profile.dustSweepStart +
              ((profile.dustSweepEnd - profile.dustSweepStart) * progress),
          SweepType.logarithmic => profile.dustSweepStart,
          SweepType.sawtooth => profile.dustSweepStart +
              ((profile.dustSweepEnd - profile.dustSweepStart) *
                  ((progress * 6) % 1)),
          SweepType.random => profile.dustSweepStart,
        };
      },
    );
  }

  Future<void> stopSession() async {
    _timer?.cancel();
    _timer = null;
    try {
      await ref.read(audioEngineProvider).stop();
      state = AsyncData(SessionState.idle());
    } on Exception catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> terminateSession() async {
    await stopSession();
  }

  Future<void> _startSession({
    required CleaningMode mode,
    required Duration duration,
    required double initialFrequency,
    required Future<void> Function() playback,
    required double Function(double progress) frequencyAtProgress,
  }) async {
    _timer?.cancel();
    state = AsyncData(
      SessionState(
        status: SessionStatus.playing,
        currentFrequency: initialFrequency,
        elapsed: Duration.zero,
        total: duration,
        mode: mode,
      ),
    );
    try {
      await HapticHelper.selectionClick();
      await playback();
      _runCountdown(
        mode: mode,
        duration: duration,
        frequencyAtProgress: frequencyAtProgress,
      );
    } on Exception catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void _runCountdown({
    required CleaningMode mode,
    required Duration duration,
    required double Function(double progress) frequencyAtProgress,
  }) {
    final startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) async {
      final elapsed = DateTime.now().difference(startedAt);
      final progress =
          (elapsed.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
      if (progress >= 1) {
        timer.cancel();
        _timer = null;
        try {
          await ref.read(audioEngineProvider).stop();
          await HapticHelper.heavyImpact();
          state = AsyncData(
            SessionState(
              status: SessionStatus.complete,
              currentFrequency: frequencyAtProgress(1),
              elapsed: duration,
              total: duration,
              mode: mode,
              message: 'Session Complete',
            ),
          );
        } on Exception catch (error, stackTrace) {
          state = AsyncError(error, stackTrace);
        }
        return;
      }
      state = AsyncData(
        SessionState(
          status: SessionStatus.playing,
          currentFrequency: frequencyAtProgress(progress),
          elapsed: elapsed,
          total: duration,
          mode: mode,
        ),
      );
    });
  }

  double _waterAmplitude(PhoneProfile profile) {
    return profile.brand == 'Samsung'
        ? FrequencyConstants.samsungWaterAmplitude
        : FrequencyConstants.fullAmplitude;
  }
}
