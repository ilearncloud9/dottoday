// The real EventKit bridge on a Mac (docs/09 M7.1b): the channel answers,
// and once access is allowed, calendars and a week of events read without
// error. Never asks: the OS prompt would wait for a person, so a Mac that
// hasn't been asked only checks the status call.
// Run: flutter test integration_test/mac_calendar_bridge_test.dart -d macos
//   --dart-define-from-file=.env
import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/calendar/channel_device_calendar_gateway.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the EventKit bridge answers on this Mac', (tester) async {
    final gateway = ChannelDeviceCalendarGateway(
      Logger(const DeveloperLogSink(), const SystemClock()),
    );
    // The raw call, so a missing bridge fails instead of reading as denied.
    final raw = await ChannelDeviceCalendarGateway.calendarChannel
        .invokeMethod<String>('status');
    expect(raw, isIn(['granted', 'denied', 'notAsked']));
    final state = await gateway.status();
    debugPrint('calendar permission: ${state.name}');
    if (state != PermissionState.granted) return;

    final calendars = await gateway.calendars();
    expect(calendars, isA<Ok<List<DeviceCalendar>, AppFailure>>());
    final list = (calendars as Ok<List<DeviceCalendar>, AppFailure>).value;
    debugPrint('calendars: ${list.length}');
    if (list.isEmpty) return;

    final now = DateTime.now().toUtc();
    final events = await gateway.events(
      list.first.id,
      now.subtract(const Duration(days: 3)),
      now.add(const Duration(days: 4)),
    );
    expect(events, isA<Ok<List<ExternalEvent>, AppFailure>>());
    final week = (events as Ok<List<ExternalEvent>, AppFailure>).value;
    debugPrint('events this week: ${week.length}');
  }, skip: kIsWeb || defaultTargetPlatform != TargetPlatform.macOS);
}
