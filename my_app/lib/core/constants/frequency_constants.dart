import '../utils/audio_engine.dart';

abstract final class FrequencyConstants {
  static const double minManualHz = 20;
  static const double midManualHz = 10000;
  static const double maxManualHz = 20000;
  static const double waterGeneralHz = 165;
  static const double waterSamsungHz = 200;
  static const double waterIphoneHz = 165;
  static const double waterPixelHz = 180;
  static const double dustGeneralStartHz = 8000;
  static const double dustGeneralEndHz = 12000;
  static const double dustIphoneStartHz = 9000;
  static const double dustIphoneEndHz = 11000;
  static const double dustSamsungStartHz = 7000;
  static const double dustSamsungEndHz = 13000;
  static const double dustPixelStartHz = 8500;
  static const double dustPixelEndHz = 11500;
  static const double fullAmplitude = 1;
  static const double samsungWaterAmplitude = 0.9;
  static const double dustSafeAmplitude = 0.85;
  static const SweepType defaultDustSweepType = SweepType.sawtooth;
  static const SweepType iphoneDustSweepType = SweepType.linear;
  static const SweepType speakerTestSweepType = SweepType.logarithmic;
}
