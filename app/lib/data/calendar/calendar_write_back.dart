import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/daos/calendar_links_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/writes/after_write_effects.dart';
import 'package:dottoday/data/writes/validate_batch.dart';
import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:dottoday/domain/calendar/write_back_merge.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';

const _codec = RowCodec();

/// Wire names of the providers write-back can reach today (device
/// calendars, M7.3; Google/Microsoft join in M7.4).
const writeBackProviders = {'apple_device', 'android_device'};

/// One imported item moved, resized or renamed here and not yet in its
/// calendar (docs/09 M7.3).
final class PendingWriteBack {
  const PendingWriteBack({
    required this.link,
    required this.occurrence,
    required this.provider,
    required this.base,
  });

  final CalendarLink link;
  final Occurrence occurrence;
  final CalendarProvider provider;

  /// What the calendar last had (`calendar_links.etag`).
  final ImportFingerprint base;

  /// Changes when either side does: an attempt that failed or clashed is
  /// not repeated on its own until then (no retry storm, R-08).
  String get signature => [
    link.etag,
    occurrence.startUtc?.millisecondsSinceEpoch,
    occurrence.durationMin,
    textHash(occurrence.title),
  ].join('|');
}

/// What one [CalendarWriteBack.push] left to the person, by link id.
final class WriteBackReport {
  const WriteBackReport({this.failed = const {}, this.clashes = const {}});

  /// Couldn't reach the calendar: the banner offers Retry.
  final Set<String> failed;

  /// Changed in the calendar too: Keep mine / Use calendar's.
  final Set<String> clashes;
}

enum _Done { written, failed, clash, skipped }

/// Sends moves, resizes and renames of imported events back to calendars
/// with write-back on (docs/02 F5, docs/09 M7.3, R-02): reads the event,
/// merges field by field with what changed there ([mergeWriteBack]),
/// writes only if it is still as read, then stores the new base. Nothing
/// here goes through the sync outbox: imports are device-only.
final class CalendarWriteBack {
  CalendarWriteBack({
    required AppDatabase db,
    required CalendarWriter? Function(CalendarProvider) writerFor,
    required AfterWriteEffects effects,
    required Clock clock,
    required Logger logger,
  }) : _db = db,
       _links = CalendarLinksDao(db),
       _occurrences = DriftOccurrenceRepository(db),
       _writerFor = writerFor,
       _effects = effects,
       _clock = clock,
       _logger = logger;

  final AppDatabase _db;
  final CalendarLinksDao _links;
  final DriftOccurrenceRepository _occurrences;
  final CalendarWriter? Function(CalendarProvider) _writerFor;
  final AfterWriteEffects _effects;
  final Clock _clock;
  final Logger _logger;

  /// [userId]'s items with something to send, now.
  Future<List<PendingWriteBack>> pending(String userId) async => _pendingOf(
    await _links.writeBackCandidates(userId, writeBackProviders).get(),
  );

  /// The same, re-read whenever an occurrence, link or calendar changes.
  Stream<List<PendingWriteBack>> watchPending(String userId) => _links
      .writeBackCandidates(userId, writeBackProviders)
      .watch()
      .map(_pendingOf);

  /// Sends [items] one by one; [prefer] settles clashes ("Keep mine",
  /// "Use calendar's"), else they are reported. [untitled] is the
  /// import's name for an event without a title.
  Future<WriteBackReport> push(
    List<PendingWriteBack> items, {
    required String untitled,
    WriteBackPrefer prefer = WriteBackPrefer.ask,
  }) async {
    final failed = <String>{};
    final clashes = <String>{};
    for (final item in items) {
      final done = await _pushOne(item, untitled, prefer);
      if (done == _Done.failed) failed.add(item.link.id);
      if (done == _Done.clash) clashes.add(item.link.id);
    }
    _logger.info(
      'calendar.write_back',
      fields: {
        'items': items.length,
        'failed': failed.length,
        'clashes': clashes.length,
      },
    );
    return WriteBackReport(failed: failed, clashes: clashes);
  }

  Future<_Done> _pushOne(
    PendingWriteBack item,
    String untitled,
    WriteBackPrefer prefer,
  ) async {
    final writer = _writerFor(item.provider);
    final eventId = parseImportKey(item.link.externalEventId)?.$1;
    if (writer == null || eventId == null) return _Done.skipped;
    final at = EventAddress(
      calendarId: item.link.externalCalendarId,
      eventId: eventId,
    );
    // Twice at most: once more when the event changed between the read
    // and the write.
    for (var attempt = 0; attempt < 2; attempt++) {
      final done = await _attempt(item, writer, at, untitled, prefer);
      if (done != null) return done;
    }
    return _Done.failed;
  }

  /// One read–merge–write; null when the event changed in between.
  Future<_Done?> _attempt(
    PendingWriteBack item,
    CalendarWriter writer,
    EventAddress at,
    String untitled,
    WriteBackPrefer prefer,
  ) async {
    final RemoteEvent? remote;
    switch (await writer.read(at)) {
      case Err(:final failure):
        _logger.warn('calendar.write_back_read_failed', error: failure);
        return _Done.failed;
      case Ok(:final value):
        remote = value;
    }
    if (remote == null || !remote.writable) return _keepLocal(item);
    final merge = mergeWriteBack(
      base: item.base,
      local: item.occurrence,
      remote: remote,
      untitled: untitled,
      prefer: prefer,
    );
    if (merge is! WriteBackMerged) return _Done.clash;
    final patch = merge.patch;
    final outcome = patch == null
        ? WriteBackOutcome.written
        : await writer.write(at, patch, expectedVersion: remote.version);
    return switch (outcome) {
      WriteBackOutcome.written => await _commit(item, at.eventId, merge),
      WriteBackOutcome.changed => null,
      WriteBackOutcome.gone ||
      WriteBackOutcome.notWritable => await _keepLocal(item),
      WriteBackOutcome.failed => _Done.failed,
    };
  }

  /// The calendar has [merge] now: store it as the new base (and the
  /// link key of the moved instance), and take what came from there. An
  /// item edited again meanwhile is left for the next run to merge.
  Future<_Done> _commit(
    PendingWriteBack item,
    String eventId,
    WriteBackMerged merge,
  ) async {
    final now = _clock.nowUtc();
    final adopted = merge.adopted?.copyWith(updatedAt: now);
    final valid = adopted == null
        ? const <Occurrence>[]
        : switch (validateBatch(
            WriteBatch(userId: item.link.userId, occurrences: [adopted]),
          )) {
            Ok(:final value) => value.occurrences,
            Err() => null,
          };
    if (valid == null) return _Done.failed;
    final link = item.link.copyWith(
      etag: merge.fingerprint.encode(),
      externalEventId: importKey(eventId, merge.fingerprint.startMs),
      lastSyncedUtc: now,
    );
    final committed = await _db.transaction(() async {
      final current = await _occurrences.findById(
        item.link.userId,
        item.occurrence.id,
      );
      if (current != item.occurrence) return false;
      await _links.upsertLink(_codec.encode<CalendarLinkRow>(link.toJson()));
      await _occurrences.upsertAll(valid);
      return true;
    });
    if (valid.isNotEmpty && committed) _effects.schedule(item.link.userId);
    return committed ? _Done.written : _Done.skipped;
  }

  /// Gone from the calendar, or it can't take changes (became repeating,
  /// all-day, read-only): the edit stays here, and the link is marked so
  /// it isn't tried again; the next import removes a gone event.
  Future<_Done> _keepLocal(PendingWriteBack item) async {
    final link = item.link.copyWith(readOnly: true);
    await _links.upsertLink(_codec.encode<CalendarLinkRow>(link.toJson()));
    return _Done.skipped;
  }

  static List<PendingWriteBack> _pendingOf(
    List<(CalendarLinkRow, OccurrenceRow, CalendarAccountRow)> rows,
  ) => [
    for (final (linkRow, occurrenceRow, accountRow) in rows)
      ?_pendingFrom(linkRow, occurrenceRow, accountRow),
  ];

  static PendingWriteBack? _pendingFrom(
    CalendarLinkRow linkRow,
    OccurrenceRow occurrenceRow,
    CalendarAccountRow accountRow,
  ) {
    final link = CalendarLink.fromJson(_codec.decode(linkRow));
    final base = ImportFingerprint.parse(link.etag);
    final o = occurrenceFromRow(occurrenceRow);
    if (base == null || o.startUtc == null || !hasLocalChange(o, base)) {
      return null;
    }
    return PendingWriteBack(
      link: link,
      occurrence: o,
      provider: CalendarAccount.fromJson(_codec.decode(accountRow)).provider,
      base: base,
    );
  }
}
