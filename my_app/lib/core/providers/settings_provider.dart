import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/duration_constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences must be overridden before runApp.');
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});

class AppSettings {
  const AppSettings({
    required this.notificationsEnabled,
    required this.selectedDurationSeconds,
    required this.safeMode,
    required this.preferredTheme,
    required this.hasCompletedOnboarding,
    required this.hasSeenDeviceSheet,
  });

  factory AppSettings.fromPreferences(SharedPreferences prefs) {
    return AppSettings(
      notificationsEnabled:
          prefs.getBool(_SettingsKeys.notificationsEnabled) ?? true,
      selectedDurationSeconds:
          prefs.getInt(_SettingsKeys.selectedDurationSeconds) ??
              DurationConstants.cleaningDurationsSeconds[1],
      safeMode: prefs.getBool(_SettingsKeys.safeMode) ?? true,
      preferredTheme: prefs.getString(_SettingsKeys.preferredTheme) ?? 'dark',
      hasCompletedOnboarding:
          prefs.getBool(_SettingsKeys.hasCompletedOnboarding) ?? false,
      hasSeenDeviceSheet:
          prefs.getBool(_SettingsKeys.hasSeenDeviceSheet) ?? false,
    );
  }

  final bool notificationsEnabled;
  final int selectedDurationSeconds;
  final bool safeMode;
  final String preferredTheme;
  final bool hasCompletedOnboarding;
  final bool hasSeenDeviceSheet;

  Duration get selectedDuration => Duration(seconds: selectedDurationSeconds);

  AppSettings copyWith({
    bool? notificationsEnabled,
    int? selectedDurationSeconds,
    bool? safeMode,
    String? preferredTheme,
    bool? hasCompletedOnboarding,
    bool? hasSeenDeviceSheet,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedDurationSeconds:
          selectedDurationSeconds ?? this.selectedDurationSeconds,
      safeMode: safeMode ?? this.safeMode,
      preferredTheme: preferredTheme ?? this.preferredTheme,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasSeenDeviceSheet: hasSeenDeviceSheet ?? this.hasSeenDeviceSheet,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._prefs) : super(AppSettings.fromPreferences(_prefs));

  final SharedPreferences _prefs;

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _persistBool(_SettingsKeys.notificationsEnabled, value);
  }

  Future<void> setSelectedDuration(int seconds) async {
    state = state.copyWith(selectedDurationSeconds: seconds);
    await _persistInt(_SettingsKeys.selectedDurationSeconds, seconds);
  }

  Future<void> setSafeMode(bool value) async {
    state = state.copyWith(safeMode: value);
    await _persistBool(_SettingsKeys.safeMode, value);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    await _persistBool(_SettingsKeys.hasCompletedOnboarding, true);
  }

  Future<void> markDeviceSheetSeen() async {
    state = state.copyWith(hasSeenDeviceSheet: true);
    await _persistBool(_SettingsKeys.hasSeenDeviceSheet, true);
  }

  Future<void> _persistBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } on Exception {
      rethrow;
    }
  }

  Future<void> _persistInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } on Exception {
      rethrow;
    }
  }
}

abstract final class _SettingsKeys {
  static const String notificationsEnabled = 'notificationsEnabled';
  static const String selectedDurationSeconds = 'selectedDurationSeconds';
  static const String safeMode = 'safeMode';
  static const String preferredTheme = 'preferredTheme';
  static const String hasCompletedOnboarding = 'hasCompletedOnboarding';
  static const String hasSeenDeviceSheet = 'hasSeenDeviceSheet';
}
