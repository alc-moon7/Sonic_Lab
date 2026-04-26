import '../core/utils/audio_engine.dart';

class PhoneProfile {
  const PhoneProfile({
    required this.brand,
    required this.model,
    required this.waterFrequency,
    required this.dustSweepStart,
    required this.dustSweepEnd,
    required this.dustSweepType,
    required this.maxSafeAmplitude,
    required this.speakerInfo,
  });

  final String brand;
  final String model;
  final double waterFrequency;
  final double dustSweepStart;
  final double dustSweepEnd;
  final SweepType dustSweepType;
  final double maxSafeAmplitude;
  final String speakerInfo;

  String get displayName => '$brand $model'.trim();
}
