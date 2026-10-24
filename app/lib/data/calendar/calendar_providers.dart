import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/calendar/no_device_calendar_gateway.dart';
import 'package:dottoday/data/calendar/plugin_device_calendar_gateway.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/calendar_source_repository.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_providers.g.dart';

bool get _hasPluginCalendars =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// The device calendars on iOS and Android (M7.1); none on the web and,
/// until M7.1b, macOS.
@Riverpod(keepAlive: true)
DeviceCalendarGateway deviceCalendarGateway(Ref ref) => _hasPluginCalendars
    ? PluginDeviceCalendarGateway(
        ref.watch(appDatabaseProvider),
        ref.watch(loggerProvider),
        deviceZone: () => ref.read(currentDeviceZoneProvider.future),
      )
    : const NoDeviceCalendarGateway();

@Riverpod(keepAlive: true)
CalendarSourceRepository calendarSourceRepository(Ref ref) =>
    DriftCalendarSourceRepository(
      ref.watch(appDatabaseProvider),
      provider: defaultTargetPlatform == TargetPlatform.android
          ? CalendarProvider.androidDevice
          : CalendarProvider.appleDevice,
      clock: ref.watch(clockProvider),
      ids: const UuidV7Generator(),
    );

/// The calendar permission now; re-read with `ref.invalidate` (on resume,
/// after asking).
@riverpod
Future<PermissionState> calendarPermissionState(Ref ref) =>
    ref.watch(deviceCalendarGatewayProvider).status();

/// The device's calendars once allowed, else none. Throws the failure
/// when they can't be read (shown by the page's error state).
@riverpod
Future<List<DeviceCalendar>> deviceCalendars(Ref ref) async {
  final permission = await ref.watch(calendarPermissionStateProvider.future);
  if (permission != PermissionState.granted) return const [];
  final result = await ref.watch(deviceCalendarGatewayProvider).calendars();
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

/// Each device calendar with its switch and inherited colour.
@riverpod
Stream<List<CalendarChoice>> calendarChoiceList(Ref ref) async* {
  final calendars = await ref.watch(deviceCalendarsProvider.future);
  if (calendars.isEmpty) {
    yield const [];
    return;
  }
  final profile = await ref.watch(currentProfileProvider.future);
  yield* ref
      .watch(calendarSourceRepositoryProvider)
      .watchDevice(profile.id)
      .map((rows) => calendarChoices(calendars, rows, _palette));
}

/// The task colours as ARGB, for [inheritColorKey].
final _palette = {for (final c in TaskColor.values) c.key: c.color.toARGB32()};

/// What Settings and onboarding do with device calendars.
@Riverpod(keepAlive: true)
CalendarActions calendarActions(Ref ref) => CalendarActions(ref);

/// Asking for the permission and switching calendars (docs/02 F5).
final class CalendarActions {
  CalendarActions(this._ref);

  final Ref _ref;

  /// Shows the OS prompt (the "Connect a calendar" button and O4 row) and
  /// returns the answer; the page and the list follow.
  Future<PermissionState> connect() async {
    try {
      return await _ref.read(deviceCalendarGatewayProvider).request();
    } on Exception catch (e, s) {
      // Nothing was granted; the page re-reads the state below.
      _ref
          .read(loggerProvider)
          .warn('calendar.connect_failed', error: e, stackTrace: s);
      return PermissionState.notAsked;
    } finally {
      _ref.invalidate(calendarPermissionStateProvider);
    }
  }

  /// Switches [calendar]'s events on or off; a failed write is a
  /// [StorageFailure] for the page to show (never swallowed).
  Future<Result<void, AppFailure>> setEnabled(
    DeviceCalendar calendar, {
    required bool on,
  }) async {
    try {
      // The stored row, not the profile stream (see `readProfile`).
      final profile =
          await _ref.read(settingsRepositoryProvider).findLocalProfile() ??
          await _ref.read<Future<Profile>>(localProfileProvider.future);
      await _ref
          .read(calendarSourceRepositoryProvider)
          .setEnabled(profile.id, calendar, enabled: on);
      return const Ok(null);
    } on Exception catch (e, s) {
      _ref
          .read(loggerProvider)
          .warn('calendar.switch_failed', error: e, stackTrace: s);
      return const Err(StorageFailure());
    }
  }
}
