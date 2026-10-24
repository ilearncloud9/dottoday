// M7.3's failure path, part two, on iOS (docs/08 §6.2, M7.7): iOS ends an
// app whose calendar access changes, so after calendar_revoked_test left
// an edit that couldn't be sent, tool/device_tests.sh grants access and
// this next launch must send it by itself, as after a person allows
// access in Settings and comes back.
import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('access back: the waiting edit goes out', (tester) async {
    final container = await startApp(tester);
    final profile = await container.read(localProfileProvider.future);
    final row = await sentEvent(container);
    final item = (await container
        .read(occurrenceRepositoryProvider)
        .findById(profile.id, row.read<String>('id')))!;
    final plugin = dc.DeviceCalendarPlugin(shouldInitTimezone: false);
    final eventId = row.read<String>('ev').split('@').first;
    await CalendarQa(container).until(
      tester,
      () async {
        final r = await plugin.retrieveEvents(
          row.read<String>('cal'),
          dc.RetrieveEventsParams(eventIds: [eventId]),
        );
        final start = r.data?.firstOrNull?.start;
        return start == null ? null : utc(start);
      },
      (s) => s == item.startUtc,
      what: 'sent on the next launch',
    );
    debugPrint('CAL_CHECK M7.3 access back: the edit is sent: PASS');
  });
}
