import 'dart:convert';

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';

/// iCalendar (RFC 5545) export of the timeline (docs/05 "Export format",
/// R-11).
///
/// One-off scheduled blocks become VEVENTs in UTC. Each live series becomes
/// one VEVENT with `DTSTART;TZID=` + `RRULE`, so calendars expand it with
/// DST intact; its skipped/deleted instances become `EXDATE`, and instances
/// the user moved or renamed become `RECURRENCE-ID` overrides. Inbox items
/// have no time and are left out. TZID is the IANA name without a
/// VTIMEZONE block, which Apple, Google and Outlook resolve.
String toIcs({
  required DateTime stampUtc,
  required Iterable<Series> series,
  required Iterable<Occurrence> occurrences,
}) {
  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Dottoday//Dottoday//EN',
    'CALSCALE:GREGORIAN',
  ];
  final stamp = _utc(stampUtc);
  final bySeries = <String, List<Occurrence>>{};
  for (final o in occurrences) {
    if (o.startUtc == null) continue;
    final seriesId = o.seriesId;
    if (seriesId == null) {
      if (o.deletedAt == null) lines.addAll(_event(o, stamp));
    } else {
      bySeries.putIfAbsent(seriesId, () => []).add(o);
    }
  }
  for (final s in series.where((s) => s.deletedAt == null)) {
    lines.addAll(_seriesEvents(s, bySeries[s.id] ?? const [], stamp));
  }
  lines.add('END:VCALENDAR');
  return '${lines.map(_fold).join('\r\n')}\r\n';
}

List<String> _event(
  Occurrence o,
  String stamp, {
  String? uid,
  String? recurrenceId,
}) => [
  'BEGIN:VEVENT',
  'UID:${uid ?? o.id}@dottoday',
  'DTSTAMP:$stamp',
  if (recurrenceId != null) 'RECURRENCE-ID:$recurrenceId',
  'DTSTART:${_utc(o.startUtc!)}',
  'DURATION:PT${o.durationMin}M',
  'SUMMARY:${_text(o.title)}',
  if (o.notes case final notes?) 'DESCRIPTION:${_text(notes)}',
  'END:VEVENT',
];

List<String> _seriesEvents(Series s, List<Occurrence> instances, String stamp) {
  final removed = [
    for (final o in instances)
      if (o.deletedAt != null || o.status == OccurrenceStatus.skipped)
        _utc(o.originalStartUtc ?? o.startUtc!),
  ];
  final overrides = [
    for (final o in instances)
      if (o.deletedAt == null &&
          o.status != OccurrenceStatus.skipped &&
          o.originalStartUtc != null &&
          (o.startUtc != o.originalStartUtc ||
              o.title != s.title ||
              o.durationMin != s.durationMin))
        o,
  ];
  return [
    'BEGIN:VEVENT',
    'UID:${s.id}@dottoday',
    'DTSTAMP:$stamp',
    'DTSTART;TZID=${s.tzId}:${_local(s.dtstartLocal)}',
    'DURATION:PT${s.durationMin}M',
    'RRULE:${_rrule(s)}',
    if (removed.isNotEmpty) 'EXDATE:${removed.join(',')}',
    'SUMMARY:${_text(s.title)}',
    if (s.notes case final notes?) 'DESCRIPTION:${_text(notes)}',
    'END:VEVENT',
    for (final o in overrides)
      ..._event(o, stamp, uid: s.id, recurrenceId: _utc(o.originalStartUtc!)),
  ];
}

/// The stored rule plus the series' own COUNT/UNTIL columns.
String _rrule(Series s) {
  final parts = [s.rrule];
  final until = s.untilUtc;
  if (s.count != null && !s.rrule.contains('COUNT=')) {
    parts.add('COUNT=${s.count}');
  }
  if (until != null && !s.rrule.contains('UNTIL=')) {
    parts.add('UNTIL=${_utc(until)}');
  }
  return parts.join(';');
}

String _two(int n) => n.toString().padLeft(2, '0');

String _utc(DateTime t) {
  final u = t.toUtc();
  return '${u.year.toString().padLeft(4, '0')}${_two(u.month)}${_two(u.day)}'
      'T${_two(u.hour)}${_two(u.minute)}${_two(u.second)}Z';
}

/// `2026-10-21T07:00[:00]` → `20261021T070000` (floating local time).
String _local(String iso) {
  final d = DateTime.parse(iso);
  return '${d.year.toString().padLeft(4, '0')}${_two(d.month)}${_two(d.day)}'
      'T${_two(d.hour)}${_two(d.minute)}${_two(d.second)}';
}

/// RFC 5545 §3.3.11 TEXT escaping.
String _text(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll(';', r'\;')
    .replaceAll(',', r'\,')
    .replaceAll(RegExp(r'\r\n|\r|\n'), r'\n');

/// RFC 5545 §3.1: lines longer than 75 octets continue on the next line
/// after CRLF + space, never splitting a UTF-8 character.
String _fold(String line) {
  if (utf8.encode(line).length <= 75) return line;
  final out = StringBuffer();
  var octets = 0;
  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final size = utf8.encode(char).length;
    // First line holds 75 octets; continuation lines 74 after the space.
    if (octets + size > 75) {
      out.write('\r\n ');
      octets = 1;
    }
    out.write(char);
    octets += size;
  }
  return out.toString();
}
