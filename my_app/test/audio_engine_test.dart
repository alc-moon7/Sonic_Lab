import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_lab/core/utils/audio_engine.dart';

void main() {
  test('AudioEngine plays sine wave and stops through backend', () async {
    final backend = FakeAudioBackend();
    final engine = AudioEngine.test(backend: backend);
    final frequencies = <double>[];
    final subscription = engine.currentFrequencyStream.listen(frequencies.add);

    await engine.playSineWave(440, amplitude: 0.7);
    expect(engine.isPlaying, isTrue);
    expect(backend.lastSineFrequency, 440);
    expect(backend.lastAmplitude, 0.7);
    expect(frequencies, contains(440));

    await engine.stop();
    expect(engine.isPlaying, isFalse);
    expect(backend.stopped, isTrue);
    await subscription.cancel();
  });

  test('ToneWaveFactory creates valid wav header', () {
    final bytes = ToneWaveFactory.sine(
      165,
      durationMs: 100,
      amplitude: 1,
    );

    expect(String.fromCharCodes(bytes.take(4)), 'RIFF');
    expect(String.fromCharCodes(bytes.skip(8).take(4)), 'WAVE');
    expect(bytes.length, greaterThan(ToneWaveFactory.headerBytes));
  });
}

class FakeAudioBackend implements AudioBackend {
  double? lastSineFrequency;
  double? lastAmplitude;
  bool stopped = false;
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
    lastSineFrequency = frequency;
    lastAmplitude = amplitude;
  }

  @override
  Future<void> playSine(
    double frequency, {
    required double amplitude,
    required int durationMs,
    required bool loop,
  }) async {
    playing = true;
    lastSineFrequency = frequency;
    lastAmplitude = amplitude;
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
    lastSineFrequency = startHz;
    lastAmplitude = amplitude;
  }

  @override
  Future<void> stop() async {
    stopped = true;
    playing = false;
  }
}
