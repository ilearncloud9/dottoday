import 'package:dottoday/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'features/settings/settings_harness.dart';
import 'support/inbox_harness.dart';
import 'support/today_harness.dart';

// docs/07 Web "responsive 360 px" (docs/09 M5.7): the main screens at the
// narrowest supported width lay out without overflow. Goldens cover 390,
// 700 and 1280; this holds the 360 floor (small Android phones, a narrow
// browser).
const _narrow = Size(360, 740);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Today', (tester) async {
    await pumpToday(tester, size: _narrow);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inbox', (tester) async {
    await pumpInbox(tester, size: _narrow);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search', (tester) async {
    await pumpInbox(tester, size: _narrow, home: const SearchScreen());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings', (tester) async {
    await pumpSettings(tester, size: const Size(360, 2600));
    expect(tester.takeException(), isNull);
  });
}
