import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';

/// The settings B1 ("Which settings should Dottoday use?", CR-160
/// criterion 7) compares, in the order it lists them. Each is one the
/// person sees and recognises at once; the rest of `Settings` follows
/// whichever side is chosen.
enum SettingsField { timeZone, language, yourDay, layout, theme }

/// The [SettingsField]s where [account] and [device] differ, in display
/// order; empty when B1 has nothing to ask (it is then never shown).
///
/// ```dart
/// settingsDifferences(berlin, tokyo); // [timeZone, ...]
/// ```
List<SettingsField> settingsDifferences(Profile account, Profile device) {
  final a = account.settings;
  final d = device.settings;
  return [
    if (account.tzId != device.tzId) SettingsField.timeZone,
    if (account.locale != device.locale) SettingsField.language,
    if (commonWindow(a) != commonWindow(d)) SettingsField.yourDay,
    if (LayoutPolicy.forSettings(a).isMinimal !=
        LayoutPolicy.forSettings(d).isMinimal)
      SettingsField.layout,
    if (a.theme != d.theme) SettingsField.theme,
  ];
}
