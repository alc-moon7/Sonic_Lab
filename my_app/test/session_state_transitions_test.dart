import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_lab/core/providers/audio_session_provider.dart';
import 'package:sonic_lab/core/utils/audio_engine.dart';
import 'package:sonic_lab/core/utils/device_detector.dart';
import 'package:sonic_lab/core/utils/volume_channel.dart';
import 'package:sonic_lab/models/session_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('audioSessionProvider transitions from playing to complete', () async {
    final container = ProviderContainer(
      overrides: [
        audioEngineProvider.overrideWithValue(
          AudioEngine.test(backend: FakeAudioBackend()),
        ),
        volumeChannelProvider.overrideWithValue(FakeVolumeChannel()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(audioSessionProvider.notifier).startWaterSession(
          DeviceDetector.defaultProfile,
          const Duration(milliseconds: 350),
        );

    expect(
      container.read(audioSessionProvider).valueOrNull?.status,
      SessionStatus.playing,
    );

    await Future<void>.delayed(const Duration(milliseconds: 650));

    final state = container.read(audioSessionProvider).valueOrNull;
    expect(state?.status, SessionStatus.complete);
    expect(state?.mode, CleaningMode.water);
  });

  test('audioSessionProvider stops an active session on request', () async {
    final backend = FakeAudioBackend();
    final container = ProviderContainer(
      overrides: [
        audioEngineProvider.overrideWithValue(
          AudioEngine.test(backend: backend),
        ),
        volumeChannelProvider.overrideWithValue(FakeVolumeChannel()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(audioSessionProvider.notifier).startWaterSession(
          DeviceDetector.defaultProfile,
          const Duration(seconds: 30),
        );

    expect(
      container.read(audioSessionProvider).valueOrNull?.status,
      SessionStatus.playing,
    );
    expect(backend.playing, isTrue);

    await container.read(audioSessionProvider.notifier).stopSession();

    final state = container.read(audioSessionProvider).valueOrNull;
    expect(state?.status, SessionStatus.idle);
    expect(backend.playing, isFalse);
  });
}

class FakeVolumeChannel extends VolumeChannel {
  @override
  Future<bool> setMaxVolume() async => true;

  @override
  Future<double?> getVolume() async => 1;
}

class FakeAudioBackend implements AudioBackend {
  bool playing = false;

  @override
  bool get isPlaying => playing;

  @override
  Future<void> playPulse(
    double frequency,
    int onMs,
    int offMs, {
    required int totalDurationMs,
    required double amplitude,
  }) async {
    playing = true;
  }

  @override
  Future<void> playSine(
    double frequency, {
    required double amplitude,
    required int durationMs,
    required bool loop,
  }) async {
    playing = true;
  }

  @override
  Future<void> playSweep(
    double startHz,
    double endHz,
    int durationMs, {
    required SweepType type,
    required double amplitude,
  }) async {
    playing = true;
  }

  @override
  Future<void> stop() async {
    playing = false;
  }
}
