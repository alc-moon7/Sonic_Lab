import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/frequency_constants.dart';
import '../utils/audio_engine.dart';
import 'audio_session_provider.dart';

enum SonicSweepMode { manual, auto }

final sonicLabProvider =
    StateNotifierProvider<SonicLabNotifier, SonicLabState>((ref) {
  return SonicLabNotifier(ref.watch(audioEngineProvider));
});

class SonicLabState {
  const SonicLabState({
    required this.frequency,
    required this.isPlaying,
    required this.sweepMode,
  });

  final double frequency;
  final bool isPlaying;
  final SonicSweepMode sweepMode;

  double get sliderProgress {
    const min = FrequencyConstants.minManualHz;
    const max = FrequencyConstants.maxManualHz;
    return (math.log(frequency / min) / math.log(max / min)).clamp(0, 1);
  }

  SonicLabState copyWith({
    double? frequency,
    bool? isPlaying,
    SonicSweepMode? sweepMode,
  }) {
    return SonicLabState(
      frequency: frequency ?? this.frequency,
      isPlaying: isPlaying ?? this.isPlaying,
      sweepMode: sweepMode ?? this.sweepMode,
    );
  }
}

class SonicLabNotifier extends StateNotifier<SonicLabState> {
  SonicLabNotifier(this._engine)
      : super(
          const SonicLabState(
            frequency: 440,
            isPlaying: false,
            sweepMode: SonicSweepMode.manual,
          ),
        );

  final AudioEngine _engine;

  void setFrequencyFromProgress(double progress) {
    const min = FrequencyConstants.minManualHz;
    const max = FrequencyConstants.maxManualHz;
    final frequency = min * math.pow(max / min, progress).toDouble();
    state = state.copyWith(frequency: frequency);
    if (state.isPlaying) {
      unawaited(_engine.playSineWave(frequency));
    }
  }

  void setFrequency(double frequency) {
    state = state.copyWith(
      frequency: frequency.clamp(
        FrequencyConstants.minManualHz,
        FrequencyConstants.maxManualHz,
      ),
    );
  }

  void toggleSweepMode() {
    state = state.copyWith(
      sweepMode: state.sweepMode == SonicSweepMode.manual
          ? SonicSweepMode.auto
          : SonicSweepMode.manual,
    );
  }

  Future<void> togglePlayback() async {
    try {
      if (state.isPlaying) {
        await _engine.stop();
        state = state.copyWith(isPlaying: false);
        return;
      }
      await _engine.playSineWave(state.frequency);
      state = state.copyWith(isPlaying: true);
    } on Exception {
      state = state.copyWith(isPlaying: false);
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _engine.stop();
      state = state.copyWith(isPlaying: false);
    } on Exception {
      rethrow;
    }
  }
}
