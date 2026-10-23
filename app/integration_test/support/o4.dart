import 'package:flutter_test/flutter_test.dart';

/// Leaves onboarding O4 the short way (docs/09 M6.5.9, M6.5.12). With
/// notifications already granted (the harness grants them on Android) O4
/// offers the test alarm and Continue; otherwise Allow / Not now. It first
/// draws the not-asked state and switches once the permission has loaded,
/// so decide only after the test-alarm card had time to appear. [before]
/// runs once it has settled (the sweep's screenshot).
Future<void> leaveRemindersStep(
  WidgetTester tester,
  Future<void> Function(String label) tap, {
  Future<void> Function()? before,
}) async {
  final end = DateTime.now().add(const Duration(seconds: 3));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(find.text('Send me a test alarm'))) break;
  }
  // The sweep's screenshot: of the settled step.
  await before?.call();
  await tap(
    tester.any(find.text('Send me a test alarm')) ? 'Continue' : 'Not now',
  );
}
