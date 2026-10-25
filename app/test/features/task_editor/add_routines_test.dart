import 'package:dottoday/core/editing/pending_routine_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/routine_samples.dart';
import 'add_harness.dart';

// Add › Suggestions › Routines (docs/09 M11.4, 11 C2): every routine
// before typing, the matching ones after; a tap hands the routine and
// the draft's day to the shell's host (which proposes it) and closes Add.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('routines show, filter, and drop on the draft day', (
    tester,
  ) async {
    await pumpAddHost(
      tester,
      routines: sampleRoutines(),
      size: const Size(390, 1400),
    );
    expect(find.text('ROUTINES'), findsOneWidget);
    expect(find.bySemanticsLabel('Drop routine Morning'), findsOneWidget);
    await tester.enterText(addTitle, 'gym');
    await tester.pump();
    expect(find.bySemanticsLabel('Drop routine Morning'), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.text('open')),
    );
    await tester.tap(find.text('Gym day'));
    await tester.pumpAndSettle();
    final asked = container.read(pendingRoutineDropProvider);
    expect(asked?.routine.title, 'Gym day');
    expect(asked?.date, DateTime(2026, 10, 21));
    expect(find.byType(TextField), findsNothing, reason: 'Add closed');
  });

  testWidgets('no routines: no section', (tester) async {
    await pumpAddHost(tester, size: const Size(390, 1400));
    expect(find.text('ROUTINES'), findsNothing);
  });
}
