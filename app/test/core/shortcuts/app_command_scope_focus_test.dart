import 'dart:ui';

import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The web follow-up to M12: a ⋯ menu that closes drops the browser's focus,
// the popover's field takes it back, and Flutter hands the view's focus to
// its first traversable node. That must not be the app-wide key catcher.
void main() {
  for (final (name, size) in [
    ('sheet (compact)', const Size(390, 844)),
    ('popover (expanded)', const Size(1280, 800)),
  ]) {
    testWidgets('$name field keeps focus when the view refocuses', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(_fieldHasFocus(tester), isTrue);

      _viewFocus(tester, ViewFocusState.unfocused);
      await tester.pump();
      _viewFocus(tester, ViewFocusState.focused);
      await tester.pumpAndSettle();

      expect(_fieldHasFocus(tester), isTrue);
    });
  }
}

Widget _app() => MaterialApp(
  theme: DotTheme.light(),
  builder: (context, child) =>
      AppCommandScope(handlers: const {}, child: child!),
  home: Scaffold(
    body: Builder(
      builder: (context) => TextButton(
        onPressed: () => showAppSheet<void>(
          context: context,
          builder: (_) => const TextField(autofocus: true),
        ),
        child: const Text('Open'),
      ),
    ),
  ),
);

bool _fieldHasFocus(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;

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
