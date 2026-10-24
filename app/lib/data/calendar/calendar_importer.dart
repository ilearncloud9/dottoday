import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/daos/calendar_links_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/writes/after_write_effects.dart';
import 'package:dottoday/data/writes/validate_batch.dart';
import 'package:dottoday/domain/calendar/calendar_import.dart';
import 'package:dottoday/domain/calendar/calendar_import_plan.dart';
import 'package:dottoday/domain/calendar/calendar_source_repository.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:timezone/timezone.dart' as tz;

const _codec = RowCodec();

/// Wire names of the device providers (docs/05 `calendar_accounts`).
const _deviceProviders = {'apple_device', 'android_device'};

/// Brings the switched-on device calendars' events onto the timeline as
/// occurrences (`source = calendar`, one `calendar_links` row each;
/// docs/02 F5, docs/09 M7.2, R-02). Runs on start, resume and after a
/// calendar is switched; each run is idempotent and runs one at a time.
final class CalendarImporter implements CalendarImport {
  CalendarImporter({
    required AppDatabase db,
    required DeviceCalendarGateway gateway,
    required CalendarSourceRepository sources,
    required AfterWriteEffects effects,
    required Clock clock,
    required IdGenerator ids,
    required Logger logger,
    Future<Set<String>> Function(String userId)? heldLinks,
  }) : _db = db,
       _heldLinks = heldLinks,
       _links = CalendarLinksDao(db),
       _gateway = gateway,
       _sources = sources,
       _occurrences = DriftOccurrenceRepository(db),
       _effects = effects,
       _clock = clock,
       _ids = ids,
       _logger = logger;

  /// How far ahead events come in: as far as repeats are materialised
  /// (docs/05 "Rules"), so the timeline reads the same offline.
  static const horizonDays = 90;

  final AppDatabase _db;
  final CalendarLinksDao _links;
  final DeviceCalendarGateway _gateway;
  final CalendarSourceRepository _sources;
  final DriftOccurrenceRepository _occurrences;
  final AfterWriteEffects _effects;
  final Clock _clock;
  final IdGenerator _ids;
  final Logger _logger;

  /// Links with an edit still on its way to the calendar (write-back,
  /// M7.3): the import leaves them to write-back's merge.
  final Future<Set<String>> Function(String userId)? _heldLinks;
  Future<void> _queue = Future.value();

  /// From yesterday to [horizonDays] ahead, in the device zone. Nothing
  /// happens without the calendar permission: a revoked permission never
  /// deletes what was imported (R-08).
  @override
  Future<Result<void, AppFailure>> run({
    required String userId,
    required List<CalendarChoice> choices,
    required tz.Location location,
    required String untitled,
  }) {
    final done = _queue.then((_) => _run(userId, choices, location, untitled));
    _queue = done.then((_) {}, onError: (_) {});
    return done;
  }

  Future<Result<void, AppFailure>> _run(
    String userId,
    List<CalendarChoice> choices,
    tz.Location location,
    String untitled,
  ) async {
    if (!_gateway.available ||
        await _gateway.status() != PermissionState.granted) {
      return const Ok(null);
    }
    try {
      final now = _clock.nowUtc();
      final from = _startOfYesterday(now, location);
      final to = from.add(const Duration(days: horizonDays + 1));
      final untouched = <String>{};
      final sources = <ImportSource>[];
      for (final c in choices.where((c) => c.enabled)) {
        final source = await _read(userId, c, from, to, location, untitled);
        source.$1 == null ? untouched.add(source.$2) : sources.add(source.$1!);
      }
      final plan = planCalendarImport(
        userId: userId,
        sources: sources,
        existing: await _existing(userId),
        fromUtc: from,
        toUtc: to,
        tzId: location.name,
        now: now,
        newId: _ids.newId,
        untouchedAccountIds: untouched,
        heldLinkIds: await _heldLinks?.call(userId) ?? const {},
      );
      return await _apply(userId, plan);
    } on Exception catch (e, st) {
      _logger.error('calendar.import_failed', error: e, stackTrace: st);
      return const Err(StorageFailure());
    }
  }

  /// One calendar's source, or null with its account id when its events
  /// couldn't be read (its imports are then left as they are).
  Future<(ImportSource?, String)> _read(
    String userId,
    CalendarChoice choice,
    DateTime from,
    DateTime to,
    tz.Location location,
    String untitled,
  ) async {
    final calendar = choice.calendar;
    final account = await _sources.ensure(userId, calendar);
    if (calendar.id.length > maxExternalCalendarIdLength) {
      _logger.warn('calendar.id_too_long');
      return (null, account.id);
    }
    final events = await _gateway.events(calendar.id, from, to);
    switch (events) {
      case Err(:final failure):
        _logger.warn('calendar.events_failed', error: failure);
        return (null, account.id);
      case Ok(:final value):
        return (
          ImportSource(
            accountId: account.id,
            calendar: calendar,
            colorKey: choice.colorKey,
            items: [
              for (final e in value)
                ...importedItems(e, location, untitled: untitled),
            ],
          ),
          account.id,
        );
    }
  }

  Future<List<LinkedOccurrence>> _existing(String userId) async {
    final withSubtasks = await _links.withSubtasks(userId);
    return [
      for (final (link, row) in await _links.linked(userId, _deviceProviders))
        LinkedOccurrence(
          link: CalendarLink.fromJson(_codec.decode(link)),
          occurrence: row == null ? null : occurrenceFromRow(row),
          hasSubtasks: row != null && withSubtasks.contains(row.id),
        ),
    ];
  }

  /// Writes [plan] in one transaction: links (occurrences reference
  /// them), the occurrences, then the removals. Not through the sync
  /// write path: every row here is device-only (`isDeviceOnly`), as
  /// `calendar_accounts` rows are, so there is no outbox to fill; rows
  /// are validated the same way (06 §7) and the same after-write effects
  /// (reminders, widgets) follow the commit.
  Future<Result<void, AppFailure>> _apply(
    String userId,
    CalendarImportPlan plan,
  ) async {
    if (plan.isEmpty) return const Ok(null);
    final valid = validateBatch(
      WriteBatch(userId: userId, occurrences: plan.occurrences),
    );
    final WriteBatch batch;
    switch (valid) {
      case Ok(:final value):
        batch = value;
      case Err(:final failure):
        return Err(failure);
    }
    await _db.transaction(() async {
      await _links.upsertAll([
        for (final l in plan.links) _codec.encode<CalendarLinkRow>(l.toJson()),
      ]);
      await _occurrences.upsertAll(batch.occurrences);
      await _links.deleteImported(userId, plan.removeOccurrenceIds);
      await _links.deleteLinks(userId, plan.removeLinkIds);
    });
    _effects.schedule(userId);
    _logger.info(
      'calendar.imported',
      fields: {
        'written': plan.occurrences.length,
        'removed': plan.removeOccurrenceIds.length,
      },
    );
    return const Ok(null);
  }

  static DateTime _startOfYesterday(DateTime now, tz.Location location) {
    final local = tz.TZDateTime.from(now, location);
    final yesterday = DateTime.utc(local.year, local.month, local.day - 1);
    return const ClockTime(0, 0).onDate(location, yesterday);
  }
}
