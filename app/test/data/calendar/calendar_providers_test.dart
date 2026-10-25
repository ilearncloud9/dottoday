import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/calendar/calendar_source_repository.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../domain/fixtures.dart';

class _Gateway extends Mock implements DeviceCalendarGateway {}

class _Sources extends Mock implements CalendarSourceRepository {}

// Found on the Android emulator at M7.7: a resume re-reads the calendar
// permission while the calendar list is still waiting for the previous
// answer; the stale build then watched another provider through its
// disposed ref and threw UnmountedRefException as an uncaught error.
void main() {
  test('a permission re-read mid-build throws nothing', () async {
    final gateway = _Gateway();
    final answers = [
      Completer<PermissionState>(),
      Completer<PermissionState>(),
    ];
    var asked = 0;
    when(gateway.status).thenAnswer((_) => answers[asked++].future);
    when(gateway.calendars).thenAnswer(
      (_) async => const Ok<List<DeviceCalendar>, AppFailure>([
        DeviceCalendar(id: 'work', name: 'Work'),
      ]),
    );
    final sources = _Sources();
    when(() => sources.watchDevice(any())).thenAnswer((_) => Stream.value([]));
    final container = ProviderContainer(
      overrides: [
        deviceCalendarGatewayProvider.overrideWithValue(gateway),
        calendarSourceRepositoryProvider.overrideWithValue(sources),
        currentProfileProvider.overrideWith(
          (ref) => Stream.value(profileFixture()),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(calendarChoiceListProvider, (_, _) {});
    addTearDown(sub.close);

    await Future<void>.delayed(Duration.zero);
    // Rebuilt while the first build still waits for the calendars.
    container
      ..invalidate(calendarPermissionStateProvider)
      ..invalidate(calendarChoiceListProvider);
    await Future<void>.delayed(Duration.zero);
    answers[0].complete(PermissionState.granted);
    answers[1].complete(PermissionState.granted);
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    final list = await container.read(calendarChoiceListProvider.future);
    expect(list.single.calendar.id, 'work');
  });
}
