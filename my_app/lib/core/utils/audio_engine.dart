import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

enum SweepType { linear, logarithmic, sawtooth, random }

abstract class AudioBackend {
  Future<void> playSine(
    double frequency, {
    required double amplitude,
    required int durationMs,
    required bool loop,
  });

  Future<void> playSweep(
    double startHz,
    double endHz,
    int durationMs, {
    required SweepType type,
    required double amplitude,
  });

  Future<void> playPulse(
    double frequency,
    int onMs,
    int offMs, {
    required int totalDurationMs,
    required double amplitude,
  });

  Future<void> stop();

  bool get isPlaying;
}

class AudioEngine {
  AudioEngine._({AudioBackend? backend})
      : _backend = backend ??
            CompositeAudioBackend(
              primary: NativeAudioBackend(),
              fallback: JustAudioToneBackend(),
            );

  factory AudioEngine.test({required AudioBackend backend}) {
    return AudioEngine._(backend: backend);
  }

  static final AudioEngine instance = AudioEngine._();

  final AudioBackend _backend;
  final StreamController<double> _frequencyController =
      StreamController<double>.broadcast();
  Timer? _frequencyTimer;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying || _backend.isPlaying;

  Stream<double> get currentFrequencyStream => _frequencyController.stream;

  Future<void> playSineWave(
    double frequency, {
    double amplitude = 1.0,
  }) async {
    await stop();
    _setPlaying(true);
    _emitFrequency(frequency);
    try {
      await _backend.playSine(
        frequency,
        amplitude: amplitude.clamp(0, 1),
        durationMs: 10000,
        loop: true,
      );
    } on Exception {
      _setPlaying(false);
      rethrow;
    }
  }

  Future<void> playSweep(
    double startHz,
    double endHz,
    int durationMs, {
    SweepType type = SweepType.linear,
    double amplitude = 0.85,
  }) async {
    await stop();
    _setPlaying(true);
    _startFrequencySweep(startHz, endHz, durationMs, type);
    try {
      await _backend.playSweep(
        startHz,
        endHz,
        durationMs,
        type: type,
        amplitude: amplitude.clamp(0, 1),
      );
      _scheduleStop(durationMs);
    } on Exception {
      _setPlaying(false);
      rethrow;
    }
  }

  Future<void> playPulse(
    double frequency,
    int onMs,
    int offMs, {
    int totalDurationMs = 30000,
    double amplitude = 1.0,
  }) async {
    await stop();
    _setPlaying(true);
    _emitFrequency(frequency);
    _frequencyTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _emitFrequency(frequency),
    );
    try {
      await _backend.playPulse(
        frequency,
        onMs,
        offMs,
        totalDurationMs: totalDurationMs,
        amplitude: amplitude.clamp(0, 1),
      );
      _scheduleStop(totalDurationMs);
    } on Exception {
      _setPlaying(false);
      rethrow;
    }
  }

  Future<void> stop() async {
    _frequencyTimer?.cancel();
    _frequencyTimer = null;
    _setPlaying(false);
    try {
      await _backend.stop();
    } on Exception {
      rethrow;
    }
  }

  void _setPlaying(bool value) {
    _isPlaying = value;
  }

  void _emitFrequency(double frequency) {
    if (!_frequencyController.isClosed) {
      _frequencyController.add(frequency);
    }
  }

  void _scheduleStop(int durationMs) {
    Timer(Duration(milliseconds: durationMs), () {
      _setPlaying(false);
      _frequencyTimer?.cancel();
      _frequencyTimer = null;
    });
  }

  void _startFrequencySweep(
    double startHz,
    double endHz,
    int durationMs,
    SweepType type,
  ) {
    final started = DateTime.now();
    final random = math.Random(37);
    _frequencyTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      final progress = (elapsed / durationMs).clamp(0.0, 1.0);
      final frequency = switch (type) {
        SweepType.linear => startHz + ((endHz - startHz) * progress),
        SweepType.logarithmic =>
          startHz * math.pow(endHz / startHz, progress).toDouble(),
        SweepType.sawtooth =>
          startHz + ((endHz - startHz) * ((progress * 4) % 1)),
        SweepType.random => startHz + ((endHz - startHz) * random.nextDouble()),
      };
      _emitFrequency(frequency);
      if (progress >= 1) {
        _frequencyTimer?.cancel();
      }
    });
  }
}

class CompositeAudioBackend implements AudioBackend {
  CompositeAudioBackend({
    required this.primary,
    required this.fallback,
  });

  final AudioBackend primary;
  final AudioBackend fallback;
  AudioBackend? _activeBackend;

  @override
  bool get isPlaying => _activeBackend?.isPlaying ?? false;

  @override
  Future<void> playSine(
    double frequency, {
    required double amplitude,
    required int durationMs,
    required bool loop,
  }) async {
    await _tryPrimary(
      () => primary.playSine(
        frequency,
        amplitude: amplitude,
        durationMs: durationMs,
        loop: loop,
      ),
      () => fallback.playSine(
        frequency,
        amplitude: amplitude,
        durationMs: durationMs,
        loop: loop,
      ),
    );
  }

  @override
  Future<void> playSweep(
    double startHz,
    double endHz,
    int durationMs, {
    required SweepType type,
    required double amplitude,
  }) async {
    await _tryPrimary(
      () => primary.playSweep(
        startHz,
        endHz,
        durationMs,
        type: type,
        amplitude: amplitude,
      ),
      () => fallback.playSweep(
        startHz,
        endHz,
        durationMs,
        type: type,
        amplitude: amplitude,
      ),
    );
  }

  @override
  Future<void> playPulse(
    double frequency,
    int onMs,
    int offMs, {
    required int totalDurationMs,
    required double amplitude,
  }) async {
    await _tryPrimary(
      () => primary.playPulse(
        frequency,
        onMs,
        offMs,
        totalDurationMs: totalDurationMs,
        amplitude: amplitude,
      ),
      () => fallback.playPulse(
        frequency,
        onMs,
        offMs,
        totalDurationMs: totalDurationMs,
        amplitude: amplitude,
      ),
    );
  }

  @override
  Future<void> stop() async {
    final active = _activeBackend;
    _activeBackend = null;
    if (active != null) {
      await active.stop();
      return;
    }
    try {
      await primary.stop();
    } on Exception {
      // The native channel may not exist on desktop/web test hosts.
    }
    await fallback.stop();
  }

  Future<void> _tryPrimary(
    Future<void> Function() primaryCall,
    Future<void> Function() fallbackCall,
  ) async {
    try {
      await fallback.stop();
      await primaryCall();
      _activeBackend = primary;
    } on Exception {
      try {
        await primary.stop();
      } on Exception {
        // Fall through to the Dart audio fallback.
      }
      await fallbackCall();
      _activeBackend = fallback;
    }
  }
}

class NativeAudioBackend implements AudioBackend {
  static const MethodChannel _channel = MethodChannel('com.soniclab/audio');

  bool _isPlaying = false;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> playSine(
    double frequency, {
    required double amplitude,
    required int durationMs,
    required bool loop,
  }) async {
    await _invoke('playSine', {
      'frequency': frequency,
      'amplitude': amplitude,
      'durationMs': durationMs,
      'loop': loop,
    });
  }

  @override
  Future<void> playSweep(
    double startHz,
    double endHz,
    int durationMs, {
    required SweepType type,
    required double amplitude,
  }) async {
    await _invoke('playSweep', {
      'startHz': startHz,
      'endHz': endHz,
      'durationMs': durationMs,
      'type': type.name,
      'amplitude': amplitude,
    });
  }

  @override
  Future<void> playPulse(
    double frequency,
    int onMs,
    int offMs, {
    required int totalDurationMs,
    required double amplitude,
  }) async {
    await _invoke('playPulse', {
      'frequency': frequency,
      'onMs': onMs,
      'offMs': offMs,
      'totalDurationMs': totalDurationMs,
      'amplitude': amplitude,
    });
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    await _channel.invokeMethod<void>('stop');
  }

  Future<void> _invoke(String method, Map<String, Object> arguments) async {
    _isPlaying = false;
    await _channel.invokeMethod<void>(method, arguments);
    _isPlaying = true;
  }
}

class JustAudioToneBackend implements AudioBackend {
  AudioPlayer? _player;
  bool _isPlaying = false;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> playSine(
    double frequency, {
    required double amplitude,
    required int durationMs,
    required bool loop,
  }) async {
    final bytes = ToneWaveFactory.sine(
      frequency,
      durationMs: durationMs,
      amplitude: amplitude,
    );
    await _playBytes(bytes, loop: loop);
  }

  @override
  Future<void> playSweep(
    double startHz,
    double endHz,
    int durationMs, {
    required SweepType type,
    required double amplitude,
  }) async {
    final bytes = ToneWaveFactory.sweep(
      startHz,
      endHz,
      durationMs: durationMs,
      type: type,
      amplitude: amplitude,
    );
    await _playBytes(bytes, loop: false);
  }

  @override
  Future<void> playPulse(
    double frequency,
    int onMs,
    int offMs, {
    required int totalDurationMs,
    required double amplitude,
  }) async {
    final bytes = ToneWaveFactory.pulse(
      frequency,
      onMs,
      offMs,
      totalDurationMs: totalDurationMs,
      amplitude: amplitude,
    );
    await _playBytes(bytes, loop: false);
  }

  @override
  Future<void> stop() async {
    final player = _player;
    _isPlaying = false;
    if (player == null) {
      return;
    }
    await player.stop();
  }

  Future<void> _playBytes(Uint8List bytes, {required bool loop}) async {
    final player = _player ??= AudioPlayer();
    await player.stop();
    await player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
    await player.setAudioSource(_MemoryAudioSource(bytes));
    _isPlaying = true;
    unawaited(player.play().whenComplete(() {
      if (!loop) {
        _isPlaying = false;
      }
    }));
  }
}

abstract final class ToneWaveFactory {
  static const int sampleRate = 44100;
  static const int channels = 1;
  static const int bitsPerSample = 16;
  static const int headerBytes = 44;

  static Uint8List sine(
    double frequency, {
    required int durationMs,
    required double amplitude,
  }) {
    return _render(durationMs, (sampleIndex, phase) {
      return _SampleFrame(
        frequency: frequency,
        amplitude: amplitude,
      );
    });
  }

  static Uint8List sweep(
    double startHz,
    double endHz, {
    required int durationMs,
    required SweepType type,
    required double amplitude,
  }) {
    final random = math.Random(11);
    return _render(durationMs, (sampleIndex, phase) {
      final progress = sampleIndex / _sampleCount(durationMs);
      final frequency = switch (type) {
        SweepType.linear => startHz + ((endHz - startHz) * progress),
        SweepType.logarithmic =>
          startHz * math.pow(endHz / startHz, progress).toDouble(),
        SweepType.sawtooth =>
          startHz + ((endHz - startHz) * ((progress * 6) % 1)),
        SweepType.random => startHz + ((endHz - startHz) * random.nextDouble()),
      };
      final envelope = type == SweepType.sawtooth
          ? 0.35 + (0.65 * ((progress * 12) % 1))
          : 1.0;
      return _SampleFrame(
        frequency: frequency,
        amplitude: amplitude * envelope,
      );
    });
  }

  static Uint8List pulse(
    double frequency,
    int onMs,
    int offMs, {
    required int totalDurationMs,
    required double amplitude,
  }) {
    final cycleMs = math.max(1, onMs + offMs);
    return _render(totalDurationMs, (sampleIndex, phase) {
      final elapsedMs = (sampleIndex / sampleRate) * 1000;
      final active = elapsedMs % cycleMs < onMs;
      return _SampleFrame(
        frequency: frequency,
        amplitude: active ? amplitude : 0,
      );
    });
  }

  static Uint8List _render(
    int durationMs,
    _SampleFrame Function(int sampleIndex, double phase) frameForSample,
  ) {
    final sampleCount = _sampleCount(durationMs);
    final dataBytes = sampleCount * channels * (bitsPerSample ~/ 8);
    final bytes = Uint8List(headerBytes + dataBytes);
    final data = ByteData.sublistView(bytes);
    _writeHeader(data, dataBytes);

    var phase = 0.0;
    var offset = headerBytes;
    for (var i = 0; i < sampleCount; i += 1) {
      final frame = frameForSample(i, phase);
      final sample = (math.sin(phase) * frame.amplitude * 32767)
          .round()
          .clamp(-32768, 32767);
      data.setInt16(offset, sample, Endian.little);
      offset += 2;
      phase += (2 * math.pi * frame.frequency) / sampleRate;
      if (phase > 2 * math.pi) {
        phase -= 2 * math.pi;
      }
    }
    return bytes;
  }

  static int _sampleCount(int durationMs) {
    return (sampleRate * durationMs / 1000).round();
  }

  static void _writeHeader(ByteData data, int dataBytes) {
    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i += 1) {
        data.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    data.setUint32(4, 36 + dataBytes, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, channels, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(
        28, sampleRate * channels * bitsPerSample ~/ 8, Endian.little);
    data.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
    data.setUint16(34, bitsPerSample, Endian.little);
    writeString(36, 'data');
    data.setUint32(40, dataBytes, Endian.little);
  }
}

class _SampleFrame {
  const _SampleFrame({
    required this.frequency,
    required this.amplitude,
  });

  final double frequency;
  final double amplitude;
}

class _MemoryAudioSource extends StreamAudioSource {
  _MemoryAudioSource(this.bytes);

  final Uint8List bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final resolvedStart = start ?? 0;
    final resolvedEnd = end ?? bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: resolvedEnd - resolvedStart,
      offset: resolvedStart,
      stream:
          Stream<List<int>>.value(bytes.sublist(resolvedStart, resolvedEnd)),
      contentType: 'audio/wav',
    );
  }
}
