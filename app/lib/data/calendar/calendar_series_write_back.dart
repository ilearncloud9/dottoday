import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/calendar/calendar_write_back.dart';
import 'package:dottoday/data/daos/calendar_links_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/data/repositories/drift_calendar_series_repository.dart';
import 'package:dottoday/domain/calendar/calendar_series_sender.dart';
import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/recurrence/series_change.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:timezone/timezone.dart' as tz;

const _codec = RowCodec();

/// Sends a scope-All edit or delete of a repeating calendar event to its
/// calendar, on the whole series (docs/02 F5.7), when Send changes back is
/// on for that calendar. Only the time of day, length and title go; notes,
/// steps and alerts never leave the device (docs/02 F5.3).
final class CalendarSeriesWriteBack implements CalendarSeriesSender {
  CalendarSeriesWriteBack({
    required AppDatabase db,
    required CalendarWriter? Function(CalendarProvider) writerFor,
    required WriteUseCase writes,
    required Clock clock,
    required Logger logger,
  }) : _links = CalendarLinksDao(db),
       _series = DriftCalendarSeriesRepository(db),
       _writes = writes,
       _writerFor = writerFor,
       _clock = clock,
       _logger = logger;

  final CalendarLinksDao _links;
  final DriftCalendarSeriesRepository _series;
  final WriteUseCase _writes;
  final CalendarWriter? Function(CalendarProvider) _writerFor;
  final Clock _clock;
  final Logger _logger;

  /// The question "Delete from the calendar too?" is only asked when true.
  @override
  Future<bool> sends(Occurrence target) async => (await _route(target)) != null;

  /// Sends [change] to the series [target] belongs to. On success the
  /// series' time, length and title are the calendar's again (no longer
  /// overrides here), and every instance's link records what the calendar
  /// now has, so nothing is also sent instance by instance.
  @override
  Future<SeriesSend> edit(Occurrence target, SeriesChange change) async {
    final route = await _route(target);
    if (route == null) return SeriesSend.stayed;
    final patch = _patch(route.link, target, change);
    if (patch == null) return SeriesSend.stayed;
    final outcome = await route.writer.writeSeries(route.at, patch);
    _logger.info('calendar.series_sent', fields: {'outcome': outcome.index});
    if (outcome != WriteBackOutcome.written) return _stayedOr(outcome);
    await _adopt(target.userId, route.link, route.series);
    return SeriesSend.sent;
  }

  @override
  Future<SeriesSend> delete(Occurrence target) async {
    final route = await _route(target);
    if (route == null) return SeriesSend.stayed;
    final outcome = await route.writer.deleteSeries(route.at);
    _logger.info('calendar.series_deleted', fields: {'outcome': outcome.index});
    return outcome == WriteBackOutcome.written ||
            outcome == WriteBackOutcome.gone
        ? SeriesSend.sent
        : _stayedOr(outcome);
  }

  static SeriesSend _stayedOr(WriteBackOutcome o) =>
      o == WriteBackOutcome.failed ? SeriesSend.failed : SeriesSend.stayed;

  /// The writer and address of [target]'s series, or null when its
  /// calendar doesn't take changes from here.
  Future<_Route?> _route(Occurrence target) async {
    final linkId = target.calendarLinkId;
    if (linkId == null) return null;
    final row = await _links
        .linkWithAccount(target.userId, linkId)
        .getSingleOrNull();
    if (row == null) return null;
    final (linkRow, account) = row;
    final link = CalendarLink.fromJson(_codec.decode(linkRow));
    final series = link.seriesKey;
    final provider = CalendarProvider.values
        .where((p) => p.wire == account.provider)
        .firstOrNull;
    final writer = provider == null ? null : _writerFor(provider);
    final sends =
        account.writeBack &&
        account.enabled &&
        writeBackProviders.contains(account.provider);
    if (series == null || writer == null || !sends) return null;
    return _Route(
      link: link,
      series: series,
      writer: writer,
      at: EventAddress(calendarId: link.externalCalendarId, eventId: series),
    );
  }

  /// The series patch for [change]: the time of day moves by the change
  /// against what the calendar last had for [target] (its fingerprint).
  static SeriesPatch? _patch(
    CalendarLink link,
    Occurrence target,
    SeriesChange change,
  ) {
    final base = ImportFingerprint.parse(link.etag);
    final start = target.startUtc;
    var shift = Duration.zero;
    if (change.startMinute != null && base != null && start != null) {
      final zone = tz.getLocation(target.tzId);
      int minuteOf(DateTime utc) {
        final w = utcToWallClock(zone, utc);
        return w.hour * 60 + w.minute;
      }

      final was = DateTime.fromMillisecondsSinceEpoch(
        base.startMs,
        isUtc: true,
      );
      shift = Duration(minutes: minuteOf(start) - minuteOf(was));
    }
    final patch = SeriesPatch(
      shift: shift,
      duration: change.durationMin == null
          ? null
          : Duration(minutes: change.durationMin!),
      title: change.title,
    );
    return patch.isEmpty ? null : patch;
  }

  /// After a series write: the calendar holds the time, length and title,
  /// so the settings stop overriding them, and each instance's link takes
  /// its occurrence's values as the calendar's (the next import agrees).
  Future<void> _adopt(String userId, CalendarLink link, String key) async {
    final now = _clock.nowUtc();
    final settings = await _series.findByKey(userId, link.accountId, key);
    if (settings != null) {
      // Not undoable: the calendar already has it.
      await _writes.apply(
        WriteBatch(
          userId: userId,
          calendarSeries: [
            settings.cleared().copyWith(
              notes: settings.notes,
              colorKey: settings.colorKey,
              iconKey: settings.iconKey,
              pinned: settings.pinned,
              travelBufferMin: settings.travelBufferMin,
              energy: settings.energy,
              alerts: settings.alerts,
              soundId: settings.soundId,
              subtaskTemplate: settings.subtaskTemplate,
              hidden: settings.hidden,
              updatedAt: now,
            ),
          ],
        ),
      );
    }
    final instances = await _series.instances(userId, link.accountId, key);
    for (final o in instances) {
      final row = o.calendarLinkId == null
          ? null
          : await _links
                .linkWithAccount(userId, o.calendarLinkId!)
                .getSingleOrNull();
      final start = o.startUtc;
      if (row == null || start == null || o.deletedAt != null) continue;
      final instance = CalendarLink.fromJson(_codec.decode(row.$1));
      final base = ImportFingerprint.parse(instance.etag);
      final adopted = ImportFingerprint(
        startMs: start.millisecondsSinceEpoch,
        durationMin: o.durationMin,
        title: textHash(o.title),
        notes: base?.notes ?? textHash(null),
      );
      await _links.upsertLink(
        _codec.encode<CalendarLinkRow>(
          instance
              .copyWith(etag: adopted.encode(), lastSyncedUtc: now)
              .toJson(),
        ),
      );
    }
  }
}

final class _Route {
  const _Route({
    required this.link,
    required this.series,
    required this.writer,
    required this.at,
  });

  final CalendarLink link;
  final String series;
  final CalendarWriter writer;
  final EventAddress at;
}
