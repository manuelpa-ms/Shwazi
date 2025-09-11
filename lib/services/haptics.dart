import 'package:flutter/services.dart';

// Lightweight cross-platform haptics helper.
// Uses Flutter's built-in HapticFeedback APIs (iOS & Android support).
class Haptics {
  static bool enabled = true; // Can be toggled later via settings.

  static DateTime? _lastLightImpact;
  static const Duration _minGap = Duration(milliseconds: 40); // Throttle rapid touches.

  static bool _tooSoon() {
    final now = DateTime.now();
    if (_lastLightImpact == null || now.difference(_lastLightImpact!) > _minGap) {
      _lastLightImpact = now;
      return false;
    }
    return true;
  }

  static void fingerDown() {
    if (!enabled) return;
    if (_tooSoon()) return;
    HapticFeedback.lightImpact();
  }

  static void fingerUp() {
    if (!enabled) return;
    if (_tooSoon()) return;
    HapticFeedback.selectionClick();
  }

  static Future<void> winnerChosen() async {
    if (!enabled) return;
    // Simple escalating pattern.
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    HapticFeedback.heavyImpact();
  }
}
