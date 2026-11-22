import 'dart:async';

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_picker.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// Pick today's one thing as E-R2-34 draws it (ED-339): a sheet led by the
// question on phones, a dialog with its own title and Close from medium
// width, the pick marked selected, the empty case, and "· Your one thing"
// joined to the live row's time line.

Future<void> _open(WidgetTester tester) async {
  unawaited(showOneThingSheet(tester.element(find.byType(Scaffold).first)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('phones: the question leads, no Close', (tester) async {
    await pumpToday(tester, size: const Size(390, 1400));
    await _open(tester);
    expect(find.text('What matters most today?'), findsOneWidget);
    expect(find.text("Pick today's one thing"), findsNothing);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byTooltip('Close'),
      ),
      findsNothing,
    );
  });

  testWidgets('wide: a titled dialog that Close shuts', (tester) async {
    await pumpToday(tester, size: const Size(1280, 900));
    await _open(tester);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Pick today's one thing"), findsOneWidget);
    expect(find.text('What matters most today?'), findsOneWidget);
    expect(
      tester.getSize(find.byType(OneThingPicker)).width,
      lessThanOrEqualTo(460),
    );
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(OneThingPicker), findsNothing);
  });

  testWidgets('the pick reads as selected', (tester) async {
    final handle = tester.ensureSemantics();
    final pick = demoDayRows(
      todayTestDate,
    ).firstWhere((o) => o.startUtc != null && o.endUtc!.isAfter(todayTestNow));
    await pumpToday(
      tester,
      size: const Size(390, 1400),
      settings: Settings(
        oneThing: OneThing(date: '2026-10-21', occurrenceId: pick.id),
      ),
    );
    await _open(tester);
    expect(
      find.descendant(
        of: find.byType(OneThingPicker),
        matching: find.bySemanticsLabel(RegExp('your one thing')),
      ),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(
        find
            .descendant(
              of: find.byType(OneThingPicker),
              matching: find.bySemanticsLabel(RegExp('your one thing')),
            )
            .first,
      ),
      isSemantics(isSelected: true, isButton: true),
    );
    handle.dispose();
  });

  testWidgets('nothing to pick from', (tester) async {
    await pumpToday(tester, rows: const [], size: const Size(390, 900));
    await _open(tester);
    expect(
      find.text('Nothing to pick from yet. Plan a dot or two first.'),
      findsOneWidget,
    );
    expect(find.byType(OneThingPicker), findsNothing);
  });

  testWidgets('the live row joins "· Your one thing" to its time', (
    tester,
  ) async {
    final live = demoDayRows(todayTestDate).firstWhere(
      (o) =>
          o.startUtc != null &&
          !o.startUtc!.isAfter(todayTestNow) &&
          o.endUtc!.isAfter(todayTestNow),
    );
    await pumpToday(
      tester,
      size: const Size(390, 1400),
      settings: Settings(
        oneThing: OneThing(date: '2026-10-21', occurrenceId: live.id),
      ),
    );
    expect(find.textContaining('min left · Your one thing'), findsOneWidget);
  });
}
