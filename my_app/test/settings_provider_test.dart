import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonic_lab/core/providers/settings_provider.dart';

void main() {
  test('SettingsNotifier loads defaults and persists changes', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final notifier = SettingsNotifier(prefs);

    expect(notifier.state.notificationsEnabled, isTrue);
    expect(notifier.state.selectedDurationSeconds, 30);

    await notifier.setNotificationsEnabled(false);
    await notifier.setSelectedDuration(60);
    await notifier.completeOnboarding();

    expect(notifier.state.notificationsEnabled, isFalse);
    expect(notifier.state.selectedDurationSeconds, 60);
    expect(notifier.state.hasCompletedOnboarding, isTrue);
    expect(prefs.getBool('notificationsEnabled'), isFalse);
    expect(prefs.getInt('selectedDurationSeconds'), 60);
  });
}
