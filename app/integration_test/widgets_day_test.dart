// A day for looking at the Home Screen and Lock Screen widgets on a device
// (docs/09 M20.9 part 3; E-R2-17, ED-309): a task under way, the rest of
// the day ahead, one done early, your one thing and three in the Inbox,
// all relative to now, through the real write path, so the app writes the
// widgets' snapshot. The widgets are then added on the device by hand.
//   tool/device_tests.sh ios [device] widgets_day
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/timezone.dart' as tz;

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a day for the widgets', (tester) async {
    final c = await startApp(tester);
    final profile = await c.read(localProfileProvider.future);
    final now = DateTime.now().toUtc();
    const ids = UuidV7Generator();
    Occurrence task(
      String title,
      int fromMin,
      int min,
      String color, {
      bool done = false,
      bool inbox = false,
    }) => Occurrence(
      id: ids.newId(),
      userId: profile.id,
      title: title,
      tzId: profile.tzId,
      startUtc: inbox ? null : now.add(Duration(minutes: fromMin)),
      durationMin: min,
      colorKey: color,
      status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
      createdAt: now,
      updatedAt: now,
    );
    final lunch = task('Lunch', 40, 45, 'rose');
    await c
        .read(writeUseCaseProvider)
        .apply(
          WriteBatch(
            userId: profile.id,
            occurrences: [
              task('Morning run', -400, 45, 'coral', done: true),
              task('Coffee and plan the day', -330, 15, 'amber', done: true),
              task('Deep work: roadmap', -102, 120, 'indigo'),
              lunch,
              task('Dentist', 100, 30, 'slate', done: true),
              task('Pick up parcel', 160, 20, 'mint'),
              task('Gym', 240, 60, 'violet'),
              task('Read', 330, 30, 'amber'),
              task('Book the car service', 0, 30, 'sky', inbox: true),
              task('Call the bank', 0, 15, 'slate', inbox: true),
              task('Plan the weekend', 0, 30, 'mint', inbox: true),
            ],
          ),
        );
    final today = tz.TZDateTime.now(tz.getLocation(profile.tzId));
    await updateSettings(
      c,
      (s) => s.copyWith(
        oneThing: OneThing(
          date: formatRouteDate(today),
          occurrenceId: lunch.id,
        ),
      ),
    );
    await settle(tester);
    await tester.pump(const Duration(seconds: 3));
    await deviceShot('widgets_day');
  });
}
