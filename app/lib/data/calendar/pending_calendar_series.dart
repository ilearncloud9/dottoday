/// Calendar-series settings in D1's export and back (CR-160 Stage A):
/// read for the file by provider ids, restored from it as pending
/// templates under the importing account, and attached to a calendar here
/// only when its ids provably name the same calendar and series
/// (`attachPendingCalendarSeries`). Never by title or likeness.
library;

import 'dart:math';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:drift/drift.dart';

/// `local_meta` key of this install's device tag: device-wide, not an
/// owner's (no `:<owner>` suffix), so it outlives an account's removal.
const calendarDeviceTagKey = 'calendar_device_tag';

const pendingCalendarSeriesCodec = RowCodec(
  jsonColumns: {'alerts', 'subtask_template'},
);

/// This install's device tag, created on first use: 16 random hex digits
/// that say which install a device calendar's template came from (a
/// device calendar's ids are only this install's). Not tied to a person.
Future<String> calendarDeviceTag(AppDatabase db, {Random? random}) async {
  final held = await readCalendarDeviceTag(db);
  if (held != null) return held;
  final r = random ?? Random.secure();
  final tag = [
    for (var i = 0; i < 8; i++)
      r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
  await db
      .into(db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(key: calendarDeviceTagKey, value: tag),
      );
  return tag;
}

/// The device tag if this install has one (null before the first D1
/// export): attaching never creates it.
Future<String?> readCalendarDeviceTag(
  AppDatabase db,
) async => (await (db.select(
  db.localMeta,
)..where((m) => m.key.equals(calendarDeviceTagKey))).getSingleOrNull())?.value;

/// Every calendar-series template of [owner], for D1's file: each
/// `calendar_series` row with its calendar's provider ids (a device
/// calendar's with this install's tag), then every pending one. Run it
/// inside the export's transaction.
Future<List<CalendarSeriesTemplate>> readCalendarSeriesTemplates(
  AppDatabase db,
  String owner,
) async {
  final series = db.calendarSeriesTable;
  final accounts = db.calendarAccounts;
  final rows =
      await (db.select(series).join([
              innerJoin(accounts, accounts.id.equalsExp(series.accountId)),
            ])
            ..where(series.userId.equals(owner))
            ..orderBy([OrderingTerm(expression: series.id)]))
          .get();
  String? tag;
  final attached = <CalendarSeriesTemplate>[];
  for (final row in rows) {
    final account = row.readTable(accounts);
    final provider = CalendarProvider.values.singleWhere(
      (p) => p.wire == account.provider,
    );
    final t = CalendarSeriesTemplate(
      provider: provider,
      // Always set by the importer (the calendar's id); never null here.
      externalCalendarId: account.externalAccountId ?? '',
      settings: calendarSeriesFromRow(row.readTable(series)),
    );
    attached.add(
      t.isDevice
          ? CalendarSeriesTemplate(
              provider: provider,
              externalCalendarId: t.externalCalendarId,
              deviceTag: tag ??= await calendarDeviceTag(db),
              settings: t.settings,
            )
          : t,
    );
  }
  return [...attached, ...await pendingCalendarSeries(db, owner)];
}

/// [owner]'s pending templates, by id.
Future<List<CalendarSeriesTemplate>> pendingCalendarSeries(
  AppDatabase db,
  String owner,
) async {
  final rows =
      await (db.select(db.pendingCalendarSeriesTable)
            ..where((p) => p.userId.equals(owner))
            ..orderBy([(p) => OrderingTerm(expression: p.id)]))
          .get();
  return [for (final r in rows) pendingTemplateFromRow(r)];
}

CalendarSeriesTemplate pendingTemplateFromRow(PendingCalendarSeriesRow row) =>
    CalendarSeriesTemplate.fromJson(pendingCalendarSeriesCodec.decode(row));

/// Keeps a file's [templates] as pending under [owner], the account that
/// imported it (CR-160 Stage A): re-owned, with new local ids (a file's
/// ids are never trusted as keys), replacing a pending template for the
/// same calendar and series. Attaches nothing. Refused, writing nothing,
/// unless [owner] is the shown account and not being deleted; counts as
/// a save for D1's review (write revision).
Future<Result<void, AppFailure>> stashCalendarSeriesTemplates(
  AppDatabase db,
  String owner,
  List<CalendarSeriesTemplate> templates,
  IdGenerator ids,
) async {
  if (templates.isEmpty) return const Ok(null);
  try {
    final kept = await db.transaction(() async {
      await checkNotSealed(db, owner);
      if (await activeOwnerId(db) != owner) return false;
      for (final t in templates) {
        await _stashOne(db, t.reownedTo(owner), ids.newId());
      }
      await bumpWriteRevision(db, owner);
      return true;
    });
    return kept ? const Ok(null) : const Err(StorageFailure());
  } on OwnerSealedException {
    return const Err(StorageFailure());
  }
}

Future<void> _stashOne(
  AppDatabase db,
  CalendarSeriesTemplate t,
  String id,
) async {
  await db.customStatement(
    'DELETE FROM pending_calendar_series WHERE user_id = ? AND provider = ? '
    'AND external_calendar_id = ? AND series_key = ?',
    [t.userId, t.provider.wire, t.externalCalendarId, t.seriesKey],
  );
  final json = t.copyWith(settings: t.settings.copyWith(id: id)).toJson();
  await db
      .into(db.pendingCalendarSeriesTable)
      .insert(
        pendingCalendarSeriesCodec.encode<PendingCalendarSeriesRow>(json),
      );
}
