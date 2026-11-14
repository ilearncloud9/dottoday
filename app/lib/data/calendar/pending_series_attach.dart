import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/calendar/pending_calendar_series.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:drift/drift.dart';

/// Providers whose templates may attach (CR-160 Stage A, docs/05
/// `calendarSeries`): only Apple's device store (EventKit on iOS and
/// macOS), whose calendar and event identifiers are opaque unique strings,
/// so on the install that exported them they name exactly the calendar
/// and series they did, or nothing.
///
/// Not Android: CalendarContract's calendar and event ids are per-device
/// integer row ids ("3", "57"), the same numbers on every phone and not
/// documented as stable across an account re-add or re-sync, so an equal
/// id doesn't prove the same calendar. Not Google or Microsoft:
/// the app sees `<server connection id>/<calendar id>`, and the connection
/// id is a new one after the account is deleted and the calendar connected
/// again; the provider's stable account id never reaches the app (see
/// docs/05). Those templates stay pending, whole, until a verified id
/// exists.
const attachableProviders = {CalendarProvider.appleDevice};

/// Attaches [owner]'s pending templates whose calendar this install
/// provably has (CR-160 Stage A): same provider ([attachableProviders]),
/// exported on this install (device tag), exactly one of the owner's own
/// `calendar_accounts` rows with that provider calendar id, and no
/// `calendar_series` row for that calendar and series yet (the one here
/// wins and the template stays pending: nothing is overwritten or
/// guessed). Each attached template becomes a `calendar_series` row with
/// a new id and leaves pending, in one transaction.
///
/// Throws [PullRefusedException], attaching nothing, unless [owner] is
/// still the shown account in the same owner session, not sealed for
/// deletion and not being removed. Returns how many attached; any counts
/// as a save for D1's review (write revision).
Future<int> attachPendingCalendarSeries(
  AppDatabase db,
  PullOwner owner,
  IdGenerator ids,
) => db.transaction(() async {
  await checkPull(db, owner);
  final tag = await readCalendarDeviceTag(db);
  if (tag == null) return 0;
  final pending =
      await (db.select(db.pendingCalendarSeriesTable)..where(
            (p) =>
                p.userId.equals(owner.userId) &
                p.provider.isIn([for (final p in attachableProviders) p.wire]) &
                p.deviceTag.equals(tag),
          ))
          .get();
  var attached = 0;
  for (final row in pending) {
    if (await _attach(db, pendingTemplateFromRow(row), ids)) attached++;
  }
  if (attached > 0) await bumpWriteRevision(db, owner.userId);
  return attached;
});

Future<bool> _attach(
  AppDatabase db,
  CalendarSeriesTemplate t,
  IdGenerator ids,
) async {
  final accounts =
      await (db.select(db.calendarAccounts)..where(
            (a) =>
                a.userId.equals(t.userId) &
                a.provider.equals(t.provider.wire) &
                a.externalAccountId.equals(t.externalCalendarId),
          ))
          .get();
  if (accounts.length != 1) return false; // none, or ambiguous
  final account = accounts.single;
  final existing =
      await (db.select(db.calendarSeriesTable)..where(
            (s) =>
                s.userId.equals(t.userId) &
                s.accountId.equals(account.id) &
                s.seriesKey.equals(t.seriesKey),
          ))
          .getSingleOrNull();
  if (existing != null) return false;
  final series = t.settings.copyWith(id: ids.newId(), accountId: account.id);
  await db
      .into(db.calendarSeriesTable)
      .insert(calendarSeriesCodec.encode<CalendarSeriesRow>(series.toJson()));
  await (db.delete(
    db.pendingCalendarSeriesTable,
  )..where((p) => p.id.equals(t.id))).go();
  return true;
}

/// The calendar import's attach step: never stops the import; a refusal
/// (the owner changed) or a failure leaves templates pending for the next
/// run.
Future<void> attachPendingForImport(
  AppDatabase db,
  PullOwner owner,
  IdGenerator ids,
  Logger logger,
) async {
  try {
    final n = await attachPendingCalendarSeries(db, owner, ids);
    if (n > 0) logger.info('calendar.series_attached', fields: {'n': n});
  } on PullRefusedException catch (e) {
    logger.info('calendar.series_attach_refused', fields: {'why': e.reason});
  } on Exception catch (e, st) {
    logger.error('calendar.series_attach_failed', error: e, stackTrace: st);
  }
}
