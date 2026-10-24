// M7.3's failure path on a device (docs/08 §6.2, M7.7). Runs after
// calendar_write_back_test with calendar access revoked (revoking ends a
// running app on both OSes, so tool/device_tests.sh revokes before the
// launch): an edit of a written-back event shows "1 change hasn't reached
// your calendar yet"; the script grants access again on DEVICE_GRANT, and
// Try again sends it.
import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('access revoked: the banner, then Try again', (tester) async {
    final container = await startApp(tester);
    final gateway = container.read(deviceCalendarGatewayProvider);
    expect(await gateway.status(), isNot(PermissionState.granted));
    final profile = await container.read(localProfileProvider.future);
    // The event calendar_write_back_test sent: a writable link on a
    // calendar with Send changes back on.
    final row = await sentEvent(container);
    final repo = container.read(occurrenceRepositoryProvider);
    final item = (await repo.findById(profile.id, row.read<String>('id')))!;
    final moved = item.startUtc!.add(const Duration(minutes: 15));
    await container
        .read(undoServiceProvider)
        .applyUndoable(
          WriteBatch(
            userId: profile.id,
            occurrences: [
              item.copyWith(startUtc: moved, updatedAt: DateTime.now().toUtc()),
            ],
          ),
        );
    await waitFor(
      tester,
      find.textContaining("hasn't reached your calendar yet"),
    );
    await deviceShot('calendar_write_failed');
    debugPrint('CAL_CHECK M7.3 revoked: failure banner: PASS');

    // iOS ends an app whose privacy access changes, so there the access
    // comes back with the next launch: calendar_regranted_test checks the
    // edit goes out then, by itself (as after a person allows it in
    // Settings). Android keeps running: Try again.
    if (defaultTargetPlatform == TargetPlatform.iOS) return;
    // Access back (the script grants it), then Try again.
    debugPrint('DEVICE_GRANT calendar');
    final end = DateTime.now().add(const Duration(seconds: 60));
    while (await gateway.status() != PermissionState.granted) {
      if (DateTime.now().isAfter(end)) fail('access never came back');
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tapOn(tester, find.text('Try again'));
    final plugin = dc.DeviceCalendarPlugin(shouldInitTimezone: false);
    final calendarId = row.read<String>('cal');
    // The link keeps `<event id>@<instance ms>` (docs/09 M7.2).
    final eventId = row.read<String>('ev').split('@').first;
    final qa = CalendarQa(container);
    await qa.until(
      tester,
      () async {
        final r = await plugin.retrieveEvents(
          calendarId,
          dc.RetrieveEventsParams(eventIds: [eventId]),
        );
        final start = r.data?.firstOrNull?.start;
        return start == null ? null : utc(start);
      },
      (s) => s == moved,
      what: 'sent after Try again',
    );
    await qa.until(
      tester,
      () async => tester.any(find.textContaining("hasn't reached")),
      (up) => !up,
      what: 'banner gone',
    );
    debugPrint('CAL_CHECK M7.3 Try again sends once access is back: PASS');
  });
}
