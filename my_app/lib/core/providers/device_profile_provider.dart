import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/phone_profile.dart';
import '../utils/device_detector.dart';

final deviceDetectorProvider = Provider<DeviceDetector>((ref) {
  return DeviceDetector();
});

final deviceProfileProvider = FutureProvider<PhoneProfile>((ref) async {
  try {
    return await ref.watch(deviceDetectorProvider).detect();
  } on Exception {
    return DeviceDetector.defaultProfile;
  }
});
