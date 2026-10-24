import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:timezone/timezone.dart' as tz;

/// The longest `calendar_links.external_event_id` (docs/05, the table's
/// CHECK). An event id that can't fit with its `@<millis>` suffix is
/// skipped rather than cut, since a cut id could collide (06 §7).
const maxExternalEventIdLength = 512;

/// The longest `calendar_links.external_calendar_id` (docs/05).
const maxExternalCalendarIdLength = 256;

/// The longest suffix [ImportedItem.key] adds: `@` and a 13-digit epoch.
const _keySuffix = 15;

/// Control characters a calendar may carry; tabs and newlines stay in
/// notes, nothing stays in a title (06 §7 "calendar events").
final _titleControl = RegExp(r'[\u0000-\u001F\u007F]');
final _notesControl = RegExp(r'[\u0000-\u0008\u000B-\u001F\u007F]');

/// One timeline item an [ExternalEvent] becomes (docs/09 M7.2): a timed
/// event is one item; an all-day event is one item per day it covers.
final class ImportedItem {
  const ImportedItem({
    required this.eventId,
    required this.keyMs,
    required this.title,
    required this.notes,
    required this.startUtc,
    required this.durationMin,
    this.writable = true,
  });

  /// The provider's event id. EventKit gives every instance of a repeating
  /// event the same one, so it alone is not unique.
  final String eventId;

  /// Which instance: the start instant of a timed event, the UTC midnight
  /// of the day for an all-day one (the same in every zone).
  final int keyMs;
  final String title;
  final String? notes;
  final DateTime startUtc;
  final int durationMin;

  /// Whether a change made here can go back to the event (M7.3): only a
  /// timed, non-repeating one. An all-day item is one day of an event
  /// that may span several; a repeating instance shares its series' id.
  final bool writable;

  /// `calendar_links.external_event_id`: `<eventId>@<keyMs>`.
  String get key => importKey(eventId, keyMs);
}

/// `<eventId>@<keyMs>`, the link key of one instance.
String importKey(String eventId, int keyMs) => '$eventId@$keyMs';

/// The event id and instance millis of a link key, or null when [key] is
/// not one [importKey] made.
(String, int)? parseImportKey(String key) {
  final at = key.lastIndexOf('@');
  if (at <= 0) return null;
  final ms = int.tryParse(key.substring(at + 1));
  return ms == null ? null : (key.substring(0, at), ms);
}

/// The items [event] makes, in [location] (the device zone), validated
/// for storage (06 §7): the title cleaned and clipped to 200 (empty →
/// [untitled]), the description plus the event link as notes clipped to
/// 10 000, the length kept to 5–1440 min. Empty when the event id is too
/// long to store.
///
/// ```dart
/// importedItems(standup, berlin, untitled: 'Busy');
/// // [ImportedItem(key: 'E1@1792573200000', durationMin: 15, …)]
/// ```
List<ImportedItem> importedItems(
  ExternalEvent event,
  tz.Location location, {
  required String untitled,
}) {
  if (event.id.isEmpty ||
      event.id.length > maxExternalEventIdLength - _keySuffix) {
    return const [];
  }
  final title = importedTitle(event.title, untitled);
  final notes = importedNotes(event.description, event.url);
  if (event.allDay) {
    return [
      for (final date in allDayDates(event))
        ImportedItem(
          eventId: event.id,
          keyMs: date.millisecondsSinceEpoch,
          title: title,
          notes: notes,
          startUtc: allDayStartUtc(date, location),
          durationMin: maxDurationMin,
          writable: false,
        ),
    ];
  }
  return [
    ImportedItem(
      eventId: event.id,
      keyMs: event.startUtc.millisecondsSinceEpoch,
      title: title,
      notes: notes,
      startUtc: event.startUtc,
      durationMin: importedDurationMin(event.startUtc, event.endUtc),
      writable: !event.repeating,
    ),
  ];
}

/// How long a timed event's block is: longer than a day shows its first
/// 24 h; a zero-length reminder gets the shortest block.
int importedDurationMin(DateTime startUtc, DateTime endUtc) =>
    endUtc.difference(startUtc).inMinutes.clamp(minDurationMin, maxDurationMin);

/// [raw] as a block title: control characters out, clipped to 200, empty
/// → [untitled] (06 §7).
String importedTitle(String raw, String untitled) {
  final clean = raw.replaceAll(_titleControl, ' ').trim();
  if (clean.isEmpty) return untitled;
  return clean.length <= maxTitleLength
      ? clean
      : clean.substring(0, maxTitleLength).trimRight();
}

/// What an event brings as notes: its description, then its link when the
/// description doesn't already hold it (R-02 "links tappable"). Null when
/// there is neither.
String? importedNotes(String? description, Uri? url) {
  final text = (description ?? '').replaceAll(_notesControl, '').trim();
  final link = url?.toString();
  final parts = [
    if (text.isNotEmpty) text,
    if (link != null && !text.contains(link)) link,
  ];
  if (parts.isEmpty) return null;
  final notes = parts.join('\n\n');
  return notes.length <= maxNotesLength
      ? notes
      : notes.substring(0, maxNotesLength);
}

/// What an item looked like when it was last imported, kept in
/// `calendar_links.etag` (device calendars have no etag): its start and
/// length, and short hashes of its title and notes. A re-import changes
/// only what changed in the calendar since, so a local move, rename or
/// note survives until the calendar changes that same thing.
final class ImportFingerprint {
  const ImportFingerprint({
    required this.startMs,
    required this.durationMin,
    required this.title,
    required this.notes,
  });

  factory ImportFingerprint.of(ImportedItem item) => ImportFingerprint(
    startMs: item.startUtc.millisecondsSinceEpoch,
    durationMin: item.durationMin,
    title: textHash(item.title),
    notes: textHash(item.notes),
  );

  /// Null for anything [encode] didn't write.
  static ImportFingerprint? parse(String? etag) {
    final parts = etag?.split(';');
    if (parts == null || parts.length != 5 || parts[0] != _version) {
      return null;
    }
    final start = int.tryParse(parts[1]);
    final duration = int.tryParse(parts[2]);
    if (start == null || duration == null) return null;
    return ImportFingerprint(
      startMs: start,
      durationMin: duration,
      title: parts[3],
      notes: parts[4],
    );
  }

  static const _version = 'v1';

  final int startMs;
  final int durationMin;
  final String title;
  final String notes;

  String encode() => '$_version;$startMs;$durationMin;$title;$notes';
}

/// A 12-hex-digit hash of [text] (null and empty alike): enough to tell
/// a change, never the text itself.
String textHash(String? text) =>
    sha256.convert(utf8.encode(text ?? '')).toString().substring(0, 12);
