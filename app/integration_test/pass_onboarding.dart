import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gets past onboarding on a device that hasn't finished it (docs/09 M4):
/// Get started, then Skip (or the last step's button) until Today shows.
/// A device that finished it goes straight on. [timeout] covers a first
/// database open waiting on the Mac's Keychain prompt.
Future<void> passOnboarding(
  WidgetTester tester, {
  Duration timeout = const Duration(minutes: 3),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (tester.any(find.byType(TodayScreen))) return;
    for (final label in ['Get started', 'Skip', 'Open today', 'Continue']) {
      final button = find.text(label);
      if (tester.any(button)) {
        await tester.tap(button.first);
        break;
      }
    }
  }
  fail('onboarding did not lead to Today');
}
