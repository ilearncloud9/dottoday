import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scrolls the day's vertical list until [text] is built and on screen:
/// phones' rows grow with their task (ED-419), so a later task may not be
/// built when the day opens.
Future<void> revealRow(WidgetTester tester, String text) async {
  final vertical = find.byWidgetPredicate(
    (w) =>
        w is Scrollable &&
        axisDirectionToAxis(w.axisDirection) == Axis.vertical,
  );
  await tester.scrollUntilVisible(
    find.text(text),
    120,
    scrollable: vertical.first,
  );
  await tester.pumpAndSettle();
}
