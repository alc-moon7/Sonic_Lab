enum CleaningMode { water, dust, sonic }

enum SessionStatus { idle, playing, complete, error }

class SessionResult {
  const SessionResult({
    required this.mode,
    required this.frequencyLabel,
    required this.duration,
    required this.completedAt,
  });

  final CleaningMode mode;
  final String frequencyLabel;
  final Duration duration;
  final DateTime completedAt;
}

class SessionState {
  const SessionState({
    required this.status,
    required this.currentFrequency,
    required this.elapsed,
    required this.total,
    required this.mode,
    this.message,
  });

  factory SessionState.idle() => const SessionState(
        status: SessionStatus.idle,
        currentFrequency: 0,
        elapsed: Duration.zero,
        total: Duration.zero,
        mode: CleaningMode.water,
      );

  final SessionStatus status;
  final double currentFrequency;
  final Duration elapsed;
  final Duration total;
  final CleaningMode mode;
  final String? message;

  bool get isPlaying => status == SessionStatus.playing;

  double get progress {
    if (total.inMilliseconds == 0) {
      return 0;
    }
    return (elapsed.inMilliseconds / total.inMilliseconds).clamp(0, 1);
  }

  int get remainingSeconds {
    final remaining = total - elapsed;
    final seconds = (remaining.inMilliseconds / 1000).ceil();
    return seconds.clamp(0, total.inSeconds).toInt();
  }

  SessionState copyWith({
    SessionStatus? status,
    double? currentFrequency,
    Duration? elapsed,
    Duration? total,
    CleaningMode? mode,
    String? message,
  }) {
    return SessionState(
      status: status ?? this.status,
      currentFrequency: currentFrequency ?? this.currentFrequency,
      elapsed: elapsed ?? this.elapsed,
      total: total ?? this.total,
      mode: mode ?? this.mode,
      message: message ?? this.message,
    );
  }
}
