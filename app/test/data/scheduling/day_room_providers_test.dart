import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';

// M3d.3: a weekday's own Wake Up / Bedtime bound the room Add and the
// Inbox fit into; other days keep the everyday window. Berlin, UTC+2.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  test("the room follows that weekday's window", () async {
    const friday = TimeWindow(start: '09:00', end: '23:30');
    final container = ProviderContainer(
      overrides: timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 8),
        profile: testProfile(
          settings: const Settings(dayBoundaries: {Weekday.fri: friday}),
        ),
      ),
    );
    addTearDown(container.dispose);
    Future<(DateTime, DateTime)> window(DateTime d) async {
      final sub = container.listen(dayRoomProvider(d), (_, _) {});
      addTearDown(sub.close);
      final room = await container.read(dayRoomProvider(d).future);
      return (room.startUtc, room.endUtc);
    }

    expect(await window(DateTime(2026, 10, 23)), (
      DateTime.utc(2026, 10, 23, 7),
      DateTime.utc(2026, 10, 23, 21, 30),
    ));
    expect(await window(DateTime(2026, 10, 22)), (
      DateTime.utc(2026, 10, 22, 5),
      DateTime.utc(2026, 10, 22, 20),
    ));
  });
}
