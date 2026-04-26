import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_lab/core/utils/audio_engine.dart';
import 'package:sonic_lab/core/utils/device_detector.dart';

void main() {
  test('Samsung lookup uses water frequency override', () {
    final profile = DeviceDetector.profileForBrandModel(
      'Samsung',
      'Galaxy S24 Ultra',
    );

    expect(profile.brand, 'Samsung');
    expect(profile.waterFrequency, 200);
    expect(profile.dustSweepType, SweepType.sawtooth);
  });

  test('iPhone lookup maps machine identifier to optimized profile', () {
    final profile = DeviceDetector.profileForIosMachine('iPhone17,1');

    expect(profile.brand, 'Apple');
    expect(profile.model, 'iPhone 16 Pro');
    expect(profile.waterFrequency, 165);
    expect(profile.dustSweepStart, 9000);
  });

  test('Unknown device falls back to generic profile', () {
    final profile = DeviceDetector.profileForBrandModel('Unknown', 'Prototype');

    expect(profile.brand, 'Generic');
    expect(profile.waterFrequency, 165);
  });
}
