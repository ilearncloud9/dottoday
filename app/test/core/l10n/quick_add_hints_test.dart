import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

// The example inputs the UI shows (Inbox hint, Add's "type a time too")
// must work when typed in that language (R-06, docs/09 M8.3): a hint that
// the parser can't read teaches the wrong thing.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final language in QuickAddLanguage.values) {
    final l10n = lookupAppLocalizations(Locale(language.name));
    final ctx = QuickAddContext(
      nowUtc: DateTime.utc(2026, 10, 21, 10),
      tzId: 'Europe/Berlin',
      language: language,
    );

    test('${language.name}: hints parse to a time and a length', () {
      final quoted = RegExp('‘(.+)’').firstMatch(l10n.addTypeTimeHint);
      expect(quoted, isNotNull, reason: 'addTypeTimeHint quotes an example');
      for (final example in [l10n.inboxAddHint, quoted!.group(1)!]) {
        final draft = switch (const QuickAddParser().parse(example, ctx)) {
          Ok(:final value) => value,
          Err(:final failure) => fail(failure.code),
        };
        expect(draft.minuteOfDay, isNotNull, reason: example);
        expect(draft.durationMin, isNotNull, reason: example);
        expect(draft.title, isNotEmpty, reason: example);
      }
    });
  }
}
