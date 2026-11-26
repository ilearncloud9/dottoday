import 'package:flutter_test/flutter_test.dart';

/// Leaves the nudge (M20.11 part 4, ED-489) the short way: once the ask
/// has risen, Not now, which goes to Today with the Wake Up alarm and the
/// Wind Down reminder off. [before] runs once it has settled (the sweep's
/// screenshot).
Future<void> leaveNudgeStep(
  WidgetTester tester,
  Future<void> Function(String label) tap, {
  Future<void> Function()? before,
}) async {
  // The ask rises at 800 ms over 500 ms.
  await tester.pump(const Duration(milliseconds: 1400));
  await before?.call();
  await tap('Not now');
}
