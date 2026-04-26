import 'package:flutter/services.dart';

abstract final class HapticHelper {
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }
}
