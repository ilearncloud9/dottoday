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
