import 'dart:async';
import 'dart:ui';

import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/today_harness.dart';

// CI a11y-web (popover_focus_check.mjs) once saw Add's field lose the
// browser's focus on a fresh profile, where Today shows the learning
// caption with its × (docs/13 §4.2). Replay the web's view unfocus /
// refocus over the real Today screen: the field must keep the focus.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Add keeps its field focused when the view refocuses', (
    tester,
  ) async {
    await pumpToday(tester);
    expect(find.byTooltip('Hide until tomorrow'), findsOneWidget);
    // As the shell's add button does.
    unawaited(showAddFlow(tester.element(find.byType(TodayScreen))));
    await tester.pumpAndSettle();
    expect(_fieldHasFocus(tester), isTrue);

    _viewFocus(tester, ViewFocusState.unfocused);
    await tester.pump();
    _viewFocus(tester, ViewFocusState.focused);
    await tester.pumpAndSettle();

    expect(_fieldHasFocus(tester), isTrue);
  });

  // The same check failed again (2026-10-29, 2026-10-31): after a reload
  // on a slow runner, Today drew under an already open Add sheet and its
  // key catcher's autofocus took the field's focus.
  testWidgets('Today drawn under an open Add leaves its field focused', (
    tester,
  ) async {
    final today = ValueNotifier(false);
    addTearDown(today.dispose);
    await pumpToday(
      tester,
      wrap: (screen) => ValueListenableBuilder(
        valueListenable: today,
        builder: (_, shown, _) => shown ? screen : const Placeholder(),
      ),
    );
    unawaited(showAddFlow(tester.element(find.byType(Placeholder))));
    await tester.pumpAndSettle();
    expect(_fieldHasFocus(tester), isTrue);

    today.value = true;
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(_fieldHasFocus(tester), isTrue);
  });

  // And again (2026-11-01): at 390 px the sheet's close button slides up
  // under the pointer that tapped Add. Its tooltip popped for a frame, and
  // that overlay re-parented the sheet's semantics, which on the web moved
  // the focused field's element and dropped its browser focus.
  testWidgets('Add sliding under a resting pointer shows no tooltip', (
    tester,
  ) async {
    await pumpToday(tester);
    unawaited(showAddFlow(tester.element(find.byType(TodayScreen))));
    final close = find.byTooltip('Close');
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    // Mid-slide: the close button is on screen, still on its way up.
    do {
      await tester.pump(const Duration(milliseconds: 16));
    } while (close.evaluate().isEmpty ||
        tester.getRect(close).bottom > screen.height);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    final rest = tester.getCenter(close);
    await mouse.addPointer(location: rest);

    var tooltip = false;
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      tooltip = tooltip || find.text('Close').evaluate().isNotEmpty;
    }

    expect(tester.getRect(close).contains(rest), isFalse);
    expect(tooltip, isFalse);
    expect(_fieldHasFocus(tester), isTrue);
  });
}

bool _fieldHasFocus(WidgetTester tester) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byType(AddTitleField),
        matching: find.byType(EditableText),
      ),
    )
    .focusNode
    .hasFocus;

void _viewFocus(WidgetTester tester, ViewFocusState state) =>
    tester.binding.handleViewFocusChanged(
      ViewFocusEvent(
        viewId: tester.view.viewId,
        state: state,
        direction: state == ViewFocusState.focused
            ? ViewFocusDirection.forward
            : ViewFocusDirection.undefined,
      ),
    );
