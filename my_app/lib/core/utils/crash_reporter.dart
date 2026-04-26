import 'package:flutter/foundation.dart';

abstract final class CrashReporter {
  static Future<void> configure() async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('CrashReporter captured: $error');
      return false;
    };
  }
}
