import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/widgets/night_rows.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Day shape's Wind Down row (docs/15 W4): the set time, or "22:45 · from
// tomorrow's 06:30" when a sleep target pulls it earlier.

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  String at(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:'
      '${(m % 60).toString().padLeft(2, '0')}';
  String value(Settings s, {int wake = 6 * 60 + 30, int windDown = 23 * 60}) =>
      windDownValue(
        l10n,
        s,
        wakeMinute: wake,
        windDownMinute: windDown,
        at: at,
      );

  test('no target: the set time', () {
    expect(value(const Settings()), '23:00');
  });

  test('a target that pulls it earlier: the derived time and why', () {
    expect(
      value(const Settings(sleepTargetMin: 7 * 60 + 45)),
      "22:45 · from tomorrow's 06:30",
    );
  });

  test('a target that would make it later: the set time', () {
    expect(value(const Settings(sleepTargetMin: 6 * 60)), '23:00');
  });
}
