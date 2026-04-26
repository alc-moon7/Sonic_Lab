import 'package:flutter/services.dart';

abstract final class HapticHelper {
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } on Exception {
      // Haptics are feedback only; cleaning sessions must never fail on this.
    }
  }

  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } on Exception {
      // Some platforms do not expose haptic feedback.
    }
  }
}
