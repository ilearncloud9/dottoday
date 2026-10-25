import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/calendar_moves.dart';
import 'package:dottoday/data/calendar/channel_device_calendar_gateway.dart';
import 'package:dottoday/data/calendar/cloud_calendar_providers.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/calendar/no_device_calendar_gateway.dart';
import 'package:dottoday/data/calendar/plugin_device_calendar_gateway.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/calendar/calendar_import.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/calendar_source_repository.dart';
import 'package:dottoday/domain/calendar/cloud_calendar.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'calendar_providers.g.dart';

/// The device calendars: `device_calendar` on iOS and Android (M7.1), the
/// EventKit channel on macOS (M7.1b); none on the web (M7.4).
@Riverpod(keepAlive: true)
DeviceCalendarGateway deviceCalendarGateway(Ref ref) {
  if (kIsWeb) return const NoDeviceCalendarGateway();
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.android => PluginDeviceCalendarGateway(
      ref.watch(appDatabaseProvider),
      ref.watch(loggerProvider),
      deviceZone: () => ref.read(currentDeviceZoneProvider.future),
    ),
    TargetPlatform.macOS => ChannelDeviceCalendarGateway(
      ref.watch(loggerProvider),
    ),
    _ => const NoDeviceCalendarGateway(),
  };
}

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

/// Device-calendar events → occurrences (docs/09 M7.2).
@Riverpod(keepAlive: true)
CalendarImport calendarImporter(Ref ref) => CalendarImporter(
  db: ref.watch(appDatabaseProvider),
  gateway: ref.watch(deviceCalendarGatewayProvider),
  sources: ref.watch(calendarSourceRepositoryProvider),
  effects: ref.watch(afterWriteEffectsProvider),
  clock: ref.watch(clockProvider),
  ids: const UuidV7Generator(),
  logger: ref.watch(loggerProvider),
  heldLinks: (userId) async => {
    for (final p in await ref.read(calendarWriteBackProvider).pending(userId))
      p.link.id,
  },
  onMoved: (moved) => ref.read(calendarMovesProvider.notifier).add(moved),
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
  // Every watch before the first await: the permission is re-read on each
  // resume, and a watch after the gap would hit a disposed ref (found on
  // the Android emulator at M7.7).
  final gateway = ref.watch(deviceCalendarGatewayProvider);
  final permission = await ref.watch(calendarPermissionStateProvider.future);
  if (permission != PermissionState.granted) return const [];
  final result = await gateway.calendars();
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

/// Each device calendar with its switch and inherited colour.
@riverpod
Stream<List<CalendarChoice>> calendarChoiceList(Ref ref) async* {
  // Every watch before the first await (see [deviceCalendars]).
  final calendarsFuture = ref.watch(deviceCalendarsProvider.future);
  final profileFuture = ref.watch(currentProfileProvider.future)..ignore();
  final sources = ref.watch(calendarSourceRepositoryProvider);
  final calendars = await calendarsFuture;
  if (calendars.isEmpty) {
    yield const [];
    return;
  }
  final profile = await profileFuture;
  yield* sources
      .watchDevice(profile.id)
      .map((rows) => calendarChoices(calendars, rows, calendarPalette));
}

/// The task colours as ARGB, for [inheritColorKey].
final calendarPalette = {
  for (final c in TaskColor.values) c.key: c.color.toARGB32(),
};

/// What Settings and onboarding do with device calendars.
@Riverpod(keepAlive: true)
CalendarActions calendarActions(Ref ref) => CalendarActions(ref);

/// Asking for the permission and switching calendars (docs/02 F5).
final class CalendarActions {
  CalendarActions(this._ref);

  final Ref _ref;

  /// Shows the OS prompt (the "Connect a calendar" button and O4 row) and
  /// returns the answer; the page and the list follow, and once allowed
  /// the events come in.
  Future<PermissionState> connect() async {
    try {
      final answer = await _ref.read(deviceCalendarGatewayProvider).request();
      if (answer == PermissionState.granted) {
        _ref.invalidate(calendarPermissionStateProvider);
        // In the background: the prompt's answer shows at once.
        unawaited(importEvents());
      }
      return answer;
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
      final profile = await _profile();
      await _ref
          .read(calendarSourceRepositoryProvider)
          .setEnabled(profile.id, calendar, enabled: on);
      unawaited(importEvents());
      return const Ok(null);
    } on Exception catch (e, s) {
      _ref
          .read(loggerProvider)
          .warn('calendar.switch_failed', error: e, stackTrace: s);
      return const Err(StorageFailure());
    }
  }

  /// Turns write-back for [calendar] on or off (M7.3). Turning it on
  /// sends the moves, resizes and renames already made here too.
  Future<Result<void, AppFailure>> setWriteBack(
    DeviceCalendar calendar, {
    required bool on,
  }) async {
    try {
      final profile = await _profile();
      await _ref
          .read(calendarSourceRepositoryProvider)
          .setWriteBack(profile.id, calendar, writeBack: on);
      return const Ok(null);
    } on Exception catch (e, s) {
      _ref
          .read(loggerProvider)
          .warn('calendar.write_back_switch_failed', error: e, stackTrace: s);
      return const Err(StorageFailure());
    }
  }

  /// Brings the switched-on calendars' events in now (start, resume, a
  /// switch, connecting): this device's, then the connected Google and
  /// Microsoft accounts' (M7.4). Failures are logged; the next run repairs
  /// them.
  Future<void> importEvents() async {
    final device = _ref.read(deviceCalendarGatewayProvider).available;
    final cloud = _ref.read(cloudCalendarsProvider).available;
    if (!device && !cloud) return;
    final logger = _ref.read(loggerProvider);
    try {
      // Edits on their way to a calendar go first, so the import reads
      // the calendars with them in.
      final writeBack = _ref.read(writeBackControllerProvider.notifier)
        ..start();
      await writeBack.flush();
    } on Object catch (e, s) {
      logger.warn('calendar.write_back_flush_failed', error: e, stackTrace: s);
    }
    if (device) {
      await _importFrom(
        _ref.read(calendarImporterProvider),
        calendarChoiceListProvider.future,
      );
    }
    if (cloud && await _cloudReadable()) {
      await _importFrom(
        _ref.read(cloudCalendarImporterProvider),
        cloudCalendarChoiceListProvider.future,
      );
    }
  }

  /// Whether every connected account can be read now. One that can't
  /// (revoked, provider down) holds the whole cloud import, since its
  /// calendars would otherwise look removed (R-08).
  Future<bool> _cloudReadable() async {
    if (await _ref.read(cloudCalendarsProvider).status() !=
        PermissionState.granted) {
      return false;
    }
    final accounts = _ref.listen(cloudAccountsProvider.future, (_, _) {});
    try {
      final list = await accounts.read();
      final ok = list.every((a) => a.status == CloudAccountStatus.ok);
      if (!ok) _ref.read(loggerProvider).warn('calendar.cloud_import_held');
      return ok;
    } on Object catch (e, s) {
      _ref
          .read(loggerProvider)
          .warn('calendar.cloud_import_skipped', error: e, stackTrace: s);
      return false;
    } finally {
      accounts.close();
    }
  }

  Future<void> _importFrom(
    CalendarImport importer,
    ProviderListenable<Future<List<CalendarChoice>>> choicesOf,
  ) async {
    final logger = _ref.read(loggerProvider);
    final choices = _ref.listen(choicesOf, (_, _) {});
    try {
      final profile = await _profile();
      final list = await choices.read();
      final zone = await _ref.read(currentDeviceZoneProvider.future);
      final result = await importer.run(
        userId: profile.id,
        choices: list,
        location: tz.getLocation(zone),
        untitled: lookupAppLocalizations(
          Locale(profile.locale),
        ).calendarEventUntitled,
      );
      if (result case Err(:final failure)) {
        logger.warn('calendar.import_refused', error: failure);
      }
    } on Object catch (e, s) {
      // A calendar that can't be listed, or an unknown zone: nothing was
      // written; the next start or resume tries again.
      logger.warn('calendar.import_skipped', error: e, stackTrace: s);
    } finally {
      choices.close();
    }
  }

  /// The stored row, not the profile stream (see `readProfile`): sign-in
  /// re-keys it.
  Future<Profile> _profile() async =>
      await _ref.read(settingsRepositoryProvider).findLocalProfile() ??
      await _ref.read<Future<Profile>>(localProfileProvider.future);
}
