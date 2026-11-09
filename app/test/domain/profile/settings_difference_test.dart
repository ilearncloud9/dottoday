import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/profile/settings_difference.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// CR-160 B1 shows only the settings that differ, in this order.
void main() {
  final base = profileFixture();

  test('the same shown settings: nothing to ask', () {
    final other = base.copyWith(settings: const Settings(snapMinutes: 15));
    expect(settingsDifferences(base, other), isEmpty);
  });

  test('every shown setting, in display order', () {
    final device = base.copyWith(
      tzId: 'Asia/Tokyo',
      locale: 'de',
      settings: withCommonWindow(
        const Settings(uiLayout: UiLayout.minimal, theme: ThemePreference.dark),
        const TimeWindow(start: '06:30', end: '22:30'),
      ),
    );
    expect(settingsDifferences(base, device), SettingsField.values);
  });
}
