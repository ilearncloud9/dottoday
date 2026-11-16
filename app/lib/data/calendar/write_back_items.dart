import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:dottoday/domain/calendar/write_back_merge.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

const _codec = RowCodec();

/// One imported item moved, resized or renamed here and not yet in its
/// calendar (docs/09 M7.3).
final class PendingWriteBack {
  const PendingWriteBack({
    required this.link,
    required this.occurrence,
    required this.provider,
    required this.base,
    this.ownerGeneration,
  });

  final CalendarLink link;
  final Occurrence occurrence;
  final CalendarProvider provider;

  /// What the calendar last had (`calendar_links.etag`).
  final ImportFingerprint base;

  /// The owner session it was read in (CR-160 I1): nothing is sent or
  /// stored for it once that session has ended. Null: never sent.
  final int? ownerGeneration;

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

/// Write-back candidate [rows] with a local change, as items read in owner
/// session [generation] (CR-160 I1).
List<PendingWriteBack> pendingWriteBacksOf(
  List<(CalendarLinkRow, OccurrenceRow, CalendarAccountRow)> rows,
  int generation,
) => [
  for (final (linkRow, occurrenceRow, accountRow) in rows)
    ?_pendingFrom(linkRow, occurrenceRow, accountRow, generation),
];

PendingWriteBack? _pendingFrom(
  CalendarLinkRow linkRow,
  OccurrenceRow occurrenceRow,
  CalendarAccountRow accountRow,
  int generation,
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
    ownerGeneration: generation,
  );
}
