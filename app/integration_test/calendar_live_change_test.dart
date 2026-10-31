// No polling (docs/04 §4 "Triggers", owner 2026-10-31), on a device with
// calendar access granted by tool/device_tests.sh: while the app stays in
// the foreground, with no resume, an event added, moved and deleted in the
// device calendar reaches Today through the OS's own change notification
// (`dottoday/system_events` → `calendar`), within the 2 s settle plus one
// import. Each step's delay is printed.
import 'package:dottoday/data/system/system_events.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';

/// The 2 s settle, one import, and a slow device's margin.
const _inTime = Duration(seconds: 10);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('calendar changes arrive without a resume', (tester) async {
    final container = await startApp(tester);
    final qa = CalendarQa(container);
    await qa.setUp();
    final heard = <SystemEvent>[];
    final sub = container.read(systemEventsProvider).events.listen(heard.add);
    addTearDown(sub.cancel);
    await goToday(tester, container);
    // The first import (start) has run before anything is added.
    await resume(tester);
    await settle(tester);
    final now = DateTime.now();
    final title = 'QA live ${now.hour}${now.minute.toString().padLeft(2, '0')}';

    Future<List<Occurrence>> timed(
      String step,
      bool Function(List<Occurrence>) check,
    ) async {
      final clock = Stopwatch()..start();
      final items = await qa.until(
        tester,
        () => qa.items(title),
        check,
        timeout: _inTime,
        what: step,
      );
      debugPrint('LIVE_CHECK $step in ${clock.elapsedMilliseconds} ms: PASS');
      return items;
    }

    final id = await qa.add(title, qa.at(0, 15), const Duration(minutes: 30));
    final added = (await timed('added', (l) => l.length == 1)).single;
    expect(heard, contains(SystemEvent.calendar));

    await qa.moveInCalendar(id, const Duration(minutes: 30));
    final moved = (await timed(
      'moved',
      (l) =>
          l.length == 1 &&
          l.single.startUtc == added.startUtc!.add(const Duration(minutes: 30)),
    )).single;
    expect(moved.id, added.id);

    await qa.deleteInCalendar(id);
    await timed('deleted', (l) => l.isEmpty);
  });
}
