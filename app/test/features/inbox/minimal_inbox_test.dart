import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/inbox/widgets/completed_group.dart';
import 'package:dottoday/features/inbox/widgets/drop_today_panel.dart';
import 'package:dottoday/features/inbox/widgets/inbox_filters.dart';
import 'package:dottoday/features/inbox/widgets/swipe_hint.dart';
import 'package:dottoday/features/inbox/widgets/wide_inbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/inbox_harness.dart';

// docs/14 §3 `inboxExtras` (Hidden in minimal): the Inbox shows the list,
// the next free slot, swipe and each row's Place only, at every width
// (ED-333); full keeps the filters with Sort, the swipe hint, Completed,
// Auto-plan the week and, expanded, the wide Inbox with Drop onto today
// (E-R2-13).

const _widths = {
  'compact': Size(390, 1400),
  'medium': Size(700, 1400),
  'expanded': Size(1280, 1400),
};

Settings _settings(UiLayout layout) =>
    Settings(uiLayout: layout, use24h: false);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final MapEntry(key: name, value: size) in _widths.entries) {
    testWidgets('minimal, $name: next free slot and Place only', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpInbox(
        tester,
        size: size,
        settings: _settings(UiLayout.minimal),
      );
      expect(find.byType(WideInbox), findsNothing);
      expect(find.byType(DropTodayPanel), findsNothing);
      expect(find.text('Drop onto today'), findsNothing);
      expect(find.textContaining('Auto-plan the week'), findsNothing);
      expect(find.byType(InboxFilters), findsNothing);
      expect(find.text('Sort: added'), findsNothing);
      expect(find.byType(InboxSwipeHint), findsNothing);
      expect(find.byType(CompletedGroup), findsNothing);
      expect(find.text('Go for a run'), findsOneWidget);
      expect(
        find.text('Next free slot today: 11:15 AM – 11:30 AM · fits Call Mum'),
        findsOneWidget,
      );
      // Every open row has its own Place.
      expect(find.widgetWithText(FilledButton, 'Place'), findsNWidgets(5));
      handle.dispose();
    });

    testWidgets('full, $name: the extras stay', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpInbox(tester, size: size, settings: _settings(UiLayout.full));
      final wide = name == 'expanded';
      expect(find.byType(WideInbox), wide ? findsOneWidget : findsNothing);
      expect(
        find.text('Drop onto today'),
        wide ? findsOneWidget : findsNothing,
      );
      expect(find.textContaining('Auto-plan the week'), findsOneWidget);
      expect(find.byType(InboxFilters), findsOneWidget);
      expect(find.text('Sort: added'), findsOneWidget);
      expect(find.byType(CompletedGroup), findsOneWidget);
      // The wide rows don't swipe, so only the narrow list has the hint.
      expect(find.byType(InboxSwipeHint), wide ? findsNothing : findsOneWidget);
      handle.dispose();
    });
  }
}
