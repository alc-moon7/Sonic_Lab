import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../../models/phone_profile.dart';
import '../constants/frequency_constants.dart';
import 'audio_engine.dart';

class DeviceDetector {
  DeviceDetector({DeviceInfoPlugin? plugin})
      : _plugin = plugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;

  Future<PhoneProfile> detect() async {
    try {
      if (kIsWeb) {
        return defaultProfile;
      }
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await _plugin.androidInfo;
          return profileForBrandModel(info.manufacturer, info.model);
        case TargetPlatform.iOS:
          final info = await _plugin.iosInfo;
          return profileForIosMachine(info.utsname.machine);
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
          return defaultProfile;
      }
    } on Exception {
      return defaultProfile;
    }
  }

  static PhoneProfile profileForBrandModel(String brand, String model) {
    final normalized = '$brand $model'.toLowerCase();
    for (final rule in _androidRules) {
      if (rule.matches(normalized)) {
        return rule.profile;
      }
    }
    if (normalized.contains('samsung')) {
      return _samsungGeneric(model);
    }
    if (normalized.contains('google') || normalized.contains('pixel')) {
      return _pixelGeneric(model);
    }
    if (normalized.contains('oneplus')) {
      return _onePlusGeneric(model);
    }
    if (normalized.contains('xiaomi') || normalized.contains('redmi')) {
      return _xiaomiGeneric(model);
    }
    return defaultProfile;
  }

  static PhoneProfile profileForIosMachine(String machine) {
    final model = _iosMachineMap[machine] ?? _iosFallbackName(machine);
    if (model.startsWith('iPad')) {
      return PhoneProfile(
        brand: 'Apple',
        model: model,
        waterFrequency: FrequencyConstants.waterIphoneHz,
        dustSweepStart: FrequencyConstants.dustIphoneStartHz,
        dustSweepEnd: FrequencyConstants.dustIphoneEndHz,
        dustSweepType: FrequencyConstants.iphoneDustSweepType,
        maxSafeAmplitude: FrequencyConstants.dustSafeAmplitude,
        speakerInfo:
            'Speaker size: tablet stereo array | Recommended frequency: 165 Hz',
      );
    }
    return PhoneProfile(
      brand: 'Apple',
      model: model,
      waterFrequency: FrequencyConstants.waterIphoneHz,
      dustSweepStart: FrequencyConstants.dustIphoneStartHz,
      dustSweepEnd: FrequencyConstants.dustIphoneEndHz,
      dustSweepType: FrequencyConstants.iphoneDustSweepType,
      maxSafeAmplitude: FrequencyConstants.dustSafeAmplitude,
      speakerInfo:
          'Speaker size: compact stereo port | Recommended frequency: 165 Hz',
    );
  }

  static const PhoneProfile defaultProfile = PhoneProfile(
    brand: 'Generic',
    model: 'Mobile Device',
    waterFrequency: FrequencyConstants.waterGeneralHz,
    dustSweepStart: FrequencyConstants.dustGeneralStartHz,
    dustSweepEnd: FrequencyConstants.dustGeneralEndHz,
    dustSweepType: FrequencyConstants.defaultDustSweepType,
    maxSafeAmplitude: FrequencyConstants.dustSafeAmplitude,
    speakerInfo:
        'Speaker size: standard phone driver | Recommended frequency: 165 Hz',
  );

  static PhoneProfile _samsungGeneric(String model) {
    return PhoneProfile(
      brand: 'Samsung',
      model: model,
      waterFrequency: FrequencyConstants.waterSamsungHz,
      dustSweepStart: FrequencyConstants.dustSamsungStartHz,
      dustSweepEnd: FrequencyConstants.dustSamsungEndHz,
      dustSweepType: SweepType.sawtooth,
      maxSafeAmplitude: FrequencyConstants.dustSafeAmplitude,
      speakerInfo:
          'Speaker size: sealed stereo module | Recommended frequency: 200 Hz',
    );
  }

  static PhoneProfile _pixelGeneric(String model) {
    return PhoneProfile(
      brand: 'Google',
      model: model,
      waterFrequency: FrequencyConstants.waterPixelHz,
      dustSweepStart: FrequencyConstants.dustPixelStartHz,
      dustSweepEnd: FrequencyConstants.dustPixelEndHz,
      dustSweepType: SweepType.linear,
      maxSafeAmplitude: FrequencyConstants.dustSafeAmplitude,
      speakerInfo:
          'Speaker size: balanced stereo port | Recommended frequency: 180 Hz',
    );
  }

  static PhoneProfile _onePlusGeneric(String model) {
    return PhoneProfile(
      brand: 'OnePlus',
      model: model,
      waterFrequency: 175,
      dustSweepStart: FrequencyConstants.dustGeneralStartHz,
      dustSweepEnd: FrequencyConstants.dustGeneralEndHz,
      dustSweepType: SweepType.sawtooth,
      maxSafeAmplitude: FrequencyConstants.dustSafeAmplitude,
      speakerInfo:
          'Speaker size: wide stereo chamber | Recommended frequency: 175 Hz',
    );
  }

  static PhoneProfile _xiaomiGeneric(String model) {
    return PhoneProfile(
      brand: 'Xiaomi',
      model: model,
      waterFrequency: 170,
      dustSweepStart: 7800,
      dustSweepEnd: 12200,
      dustSweepType: SweepType.sawtooth,
      maxSafeAmplitude: FrequencyConstants.dustSafeAmplitude,
      speakerInfo:
          'Speaker size: dual outlet grille | Recommended frequency: 170 Hz',
    );
  }

  static String _iosFallbackName(String machine) {
    if (machine.toLowerCase().contains('ipad')) {
      return 'iPad';
    }
    return machine.toLowerCase().contains('iphone') ? 'iPhone' : 'iOS Device';
  }

  static final List<_ProfileRule> _androidRules = <_ProfileRule>[
    _ProfileRule(
      const <String>['galaxy s21', 'sm-g991', 'sm-g996', 'sm-g998'],
      _samsungGeneric('Galaxy S21 Series'),
    ),
    _ProfileRule(
      const <String>['galaxy s22', 'sm-s901', 'sm-s906', 'sm-s908'],
      _samsungGeneric('Galaxy S22 Series'),
    ),
    _ProfileRule(
      const <String>['galaxy s23', 'sm-s911', 'sm-s916', 'sm-s918'],
      _samsungGeneric('Galaxy S23 Series'),
    ),
    _ProfileRule(
      const <String>['galaxy s24', 'sm-s921', 'sm-s926', 'sm-s928'],
      _samsungGeneric('Galaxy S24 Series'),
    ),
    _ProfileRule(
      const <String>['galaxy a', 'sm-a1', 'sm-a2', 'sm-a3', 'sm-a5', 'sm-a7'],
      _samsungGeneric('Galaxy A Series'),
    ),
    _ProfileRule(
      const <String>['galaxy z fold', 'sm-f9', 'galaxy z flip', 'sm-f7'],
      _samsungGeneric('Galaxy Z Fold/Flip'),
    ),
    _ProfileRule(
      const <String>['pixel 5', 'pixel 6', 'pixel 7', 'pixel 8'],
      _pixelGeneric('Pixel 5-8 Series'),
    ),
    _ProfileRule(
      const <String>['oneplus 10', 'oneplus 11', 'oneplus 12'],
      _onePlusGeneric('OnePlus 10-12'),
    ),
    _ProfileRule(
      const <String>['xiaomi 12', 'xiaomi 13', 'xiaomi 14', 'redmi note'],
      _xiaomiGeneric('Xiaomi 12-14 / Redmi Note'),
    ),
  ];

  static const Map<String, String> _iosMachineMap = <String, String>{
    'iPhone8,4': 'iPhone SE (1st gen)',
    'iPhone12,8': 'iPhone SE (2nd gen)',
    'iPhone14,6': 'iPhone SE (3rd gen)',
    'iPhone13,1': 'iPhone 12 mini',
    'iPhone13,2': 'iPhone 12',
    'iPhone13,3': 'iPhone 12 Pro',
    'iPhone13,4': 'iPhone 12 Pro Max',
    'iPhone14,4': 'iPhone 13 mini',
    'iPhone14,5': 'iPhone 13',
    'iPhone14,2': 'iPhone 13 Pro',
    'iPhone14,3': 'iPhone 13 Pro Max',
    'iPhone14,7': 'iPhone 14',
    'iPhone14,8': 'iPhone 14 Plus',
    'iPhone15,2': 'iPhone 14 Pro',
    'iPhone15,3': 'iPhone 14 Pro Max',
    'iPhone15,4': 'iPhone 15',
    'iPhone15,5': 'iPhone 15 Plus',
    'iPhone16,1': 'iPhone 15 Pro',
    'iPhone16,2': 'iPhone 15 Pro Max',
    'iPhone17,3': 'iPhone 16',
    'iPhone17,4': 'iPhone 16 Plus',
    'iPhone17,1': 'iPhone 16 Pro',
    'iPhone17,2': 'iPhone 16 Pro Max',
    'iPad11,6': 'iPad (8th gen)',
    'iPad12,1': 'iPad (9th gen)',
    'iPad13,18': 'iPad (10th gen)',
    'iPad13,1': 'iPad Air (4th gen)',
    'iPad13,16': 'iPad Air (5th gen)',
    'iPad8,1': 'iPad Pro 11-inch',
    'iPad13,4': 'iPad Pro 11-inch M1',
    'iPad14,3': 'iPad Pro 11-inch M2',
    'iPad8,5': 'iPad Pro 12.9-inch',
    'iPad13,8': 'iPad Pro 12.9-inch M1',
    'iPad14,5': 'iPad Pro 12.9-inch M2',
    'iPad14,1': 'iPad mini (6th gen)',
  };
}

class _ProfileRule {
  _ProfileRule(this.patterns, this.profile);

  final List<String> patterns;
  final PhoneProfile profile;

  bool matches(String value) {
    return patterns.any(value.contains);
  }
}
