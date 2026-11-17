import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/calendar/pending_calendar_series.dart';
import 'package:dottoday/data/calendar/pending_series_attach.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/entities/enums.dart';

import 'deletion_world.dart';
import 'fake_clock.dart';
import 'fake_ids.dart';
import 'owner_app.dart';

// CR-160 Stage A: calendars switched on, series set, files imported and
// templates attached in a [DeletionWorld].

const workCalendar = DeviceCalendar(id: 'work', name: 'Work');

/// Android's CalendarContract ids: SQLite row ids.
const androidCalendar = DeviceCalendar(id: '3', name: 'Work');

/// A Google calendar as the app sees it: `<server connection id>/<id>`.
DeviceCalendar googleCalendar(String connection) => DeviceCalendar(
  id: '$connection/primary',
  name: 'Work',
  provider: CalendarProvider.google,
);

extension CalendarTemplateWorld on DeletionWorld {
  /// [owner] switches [calendar] on: its `calendar_accounts` row id.
  Future<String> connect(
    String owner,
    DeviceCalendar calendar, {
    CalendarProvider device = CalendarProvider.appleDevice,
  }) async => (await DriftCalendarSourceRepository(
    db,
    provider: device,
    clock: FakeClock(ownerAppNow),
    ids: FakeIds('acc-$owner-${calendar.id}-${device.name}'),
  ).ensure(owner, calendar)).id;

  /// [series] set on [accountId]'s calendar, as an edit with scope All.
  Future<void> setSeries(CalendarSeries series) => db
      .into(db.calendarSeriesTable)
      .insert(calendarSeriesCodec.encode<CalendarSeriesRow>(series.toJson()));

  Future<List<CalendarSeries>> attached(String owner) async => [
    for (final r in await (db.select(
      db.calendarSeriesTable,
    )..where((s) => s.userId.equals(owner))).get())
      calendarSeriesFromRow(r),
  ];

  Future<List<CalendarSeriesTemplate>> pending(String owner) =>
      pendingCalendarSeries(db, owner);

  /// One attach for [owner] in the owner session shown now.
  Future<int> attach(String owner) async => attachPendingCalendarSeries(
    db,
    await beginPull(db, owner),
    FakeIds('attached'),
  );

  /// Settings › Import of [file] by [owner].
  Future<Result<void, AppFailure>> importFile(String owner, String file) =>
      app.container.read(backupServiceProvider).importJson(owner, file);

  Future<String> deviceTag() => calendarDeviceTag(db);
}

/// [t]'s settings without what a restore re-keys (id, owner, account).
Map<String, Object?> contents(CalendarSeries s) => s.toJson()
  ..remove('id')
  ..remove('user_id')
  ..remove('account_id');
