import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gets past onboarding on a device that hasn't finished it (docs/09 M4):
/// Get started, The full planner at step 0 (the device suites check the
/// full layout; docs/14), then Skip (or the last step's button) until
/// Today shows.
/// A device that finished it goes straight on. [timeout] covers a first
/// database open waiting on the Mac's Keychain prompt.
Future<void> passOnboarding(
  WidgetTester tester, {
  Duration timeout = const Duration(minutes: 3),
}) async {
  final end = DateTime.now().add(timeout);
  var full = false;
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (tester.any(find.byType(TodayScreen))) return;
    final planner = find.text('The full planner');
    if (!full && tester.any(planner)) {
      await tester.tap(planner.first, warnIfMissed: false);
      full = true;
      continue;
    }
    for (final label in ['Get started', 'Skip', 'Open today', 'Continue']) {
      final button = find.text(label);
      if (tester.any(button)) {
        // A small screen puts O6's button below the card: scroll to it.
        await tester.ensureVisible(button.first);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(button.first, warnIfMissed: false);
        break;
      }
    }
  }
  fail('onboarding did not lead to Today');
}
