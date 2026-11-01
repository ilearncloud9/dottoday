part of 'calendar_import_plan.dart';

// How one calendar's items and stored links are matched (docs/09 M7.2,
// docs/02 F5.7), and what each match writes.

void _reconcile(
  _PlanBuilder out,
  ImportSource source,
  List<ImportedItem> items,
  List<LinkedOccurrence> links,
  tz.Location zone,
) {
  final byKey = {for (final l in links) l.link.externalEventId: l};
  final unmatched = <ImportedItem>[];
  for (final item in items) {
    final link = byKey.remove(item.key);
    link == null ? unmatched.add(item) : out.update(source, link, item);
  }
  // A series moved to another time (here with scope All, or in the
  // calendar) gives every instance a new key; each day keeps its own
  // occurrence, done or not, by series and date (docs/02 F5.7).
  final bySeriesDay = <String, LinkedOccurrence>{};
  for (final l in byKey.values) {
    final key = _seriesDay(l.link.seriesKey, l.link.externalEventId, zone);
    if (key != null) bySeriesDay[key] = l;
  }
  unmatched.removeWhere((item) {
    final key = _seriesDay(item.seriesKey, item.key, zone);
    final link = key == null ? null : bySeriesDay.remove(key);
    if (link == null) return false;
    byKey.remove(link.link.externalEventId);
    out.update(source, link, item);
    return true;
  });
  // Moved in the calendar: one item and one link left for the event.
  final leftByEvent = <String, List<LinkedOccurrence>>{};
  for (final l in byKey.values) {
    final event = parseImportKey(l.link.externalEventId)?.$1;
    if (event != null) (leftByEvent[event] ??= []).add(l);
  }
  final newByEvent = <String, List<ImportedItem>>{};
  for (final i in unmatched) {
    (newByEvent[i.eventId] ??= []).add(i);
  }
  for (final MapEntry(key: event, value: news) in newByEvent.entries) {
    final left = leftByEvent[event];
    if (news.length == 1 && left != null && left.length == 1) {
      out.update(source, left.single, news.single);
      byKey.remove(left.single.link.externalEventId);
    } else {
      for (final i in news) {
        out.add(source, i);
      }
    }
  }
  byKey.values.forEach(out.remove);
}

/// `<series key>/<local date>` of an instance whose link key is [key], or
/// null for a one-off event.
String? _seriesDay(String? seriesKey, String key, tz.Location zone) {
  final ms = parseImportKey(key)?.$2;
  if (seriesKey == null || ms == null) return null;
  final local = tz.TZDateTime.fromMillisecondsSinceEpoch(zone, ms);
  return '$seriesKey/${local.year}-${local.month}-${local.day}';
}

final class _PlanBuilder {
  _PlanBuilder({
    required this.userId,
    required this.tzId,
    required this.now,
    required this.newId,
    required this.held,
    required this.series,
  });

  final String userId;
  final String tzId;
  final DateTime now;
  final String Function() newId;
  final Set<String> held;
  final Map<String, CalendarSeries> series;
  final _links = <CalendarLink>[];
  final _occurrences = <Occurrence>[];
  final _subtasks = <Subtask>[];
  final _removeOccurrences = <String>{};
  final _removeLinks = <String>{};
  final _moved = <CalendarMove>[];

  CalendarSeries? _seriesOf(String accountId, String? seriesKey) =>
      seriesKey == null
      ? null
      : series[calendarSeriesLookup(accountId, seriesKey)];

  void add(ImportSource source, ImportedItem item) {
    final settings = _seriesOf(source.accountId, item.seriesKey);
    if (settings != null && settings.hidden) return;
    final link = CalendarLink(
      id: newId(),
      userId: userId,
      accountId: source.accountId,
      externalCalendarId: source.calendar.id,
      externalEventId: item.key,
      etag: ImportFingerprint.of(item).encode(),
      lastSyncedUtc: now,
      readOnly: source.calendar.readOnly || !item.writable,
      location: item.location,
      seriesKey: item.seriesKey,
    );
    _links.add(link);
    final o = Occurrence(
      id: newId(),
      userId: userId,
      title: item.title,
      notes: item.notes,
      colorKey: source.colorKey,
      startUtc: item.startUtc,
      tzId: tzId,
      durationMin: item.durationMin,
      source: OccurrenceSource.calendar,
      calendarLinkId: link.id,
      createdAt: now,
      updatedAt: now,
    );
    if (settings == null) {
      _occurrences.add(o);
      return;
    }
    _occurrences.add(withSeriesSettings(o, settings));
    _subtasks.addAll(seriesSubtasks(o, settings, now: now, newId: newId));
  }

  /// Applies what changed in the calendar since the last import.
  void update(
    ImportSource source,
    LinkedOccurrence existing,
    ImportedItem item,
  ) {
    final link = existing.link;
    if (held.contains(link.id)) return;
    final etag = ImportFingerprint.of(item).encode();
    final readOnly = source.calendar.readOnly || !item.writable;
    if (link.etag == etag &&
        link.externalEventId == item.key &&
        link.readOnly == readOnly &&
        link.location == item.location &&
        link.seriesKey == item.seriesKey) {
      return;
    }
    _links.add(
      link.copyWith(
        externalEventId: item.key,
        etag: etag,
        lastSyncedUtc: now,
        readOnly: readOnly,
        location: item.location,
        seriesKey: item.seriesKey,
      ),
    );
    final o = existing.occurrence;
    if (existing._hidden || o == null) return;
    final changed = _changed(o, ImportFingerprint.parse(link.etag), item);
    if (changed == o) return;
    _occurrences.add(changed.copyWith(updatedAt: now));
    final from = o.startUtc;
    final to = changed.startUtc;
    if (from != null &&
        to != null &&
        from != to &&
        o.status == OccurrenceStatus.planned) {
      _moved.add(
        CalendarMove(
          occurrenceId: o.id,
          title: changed.title,
          fromUtc: from,
          toUtc: to,
          durationMin: o.durationMin,
        ),
      );
    }
  }

  void remove(LinkedOccurrence existing) {
    if (held.contains(existing.link.id)) return;
    _removeLinks.add(existing.link.id);
    final o = existing.occurrence;
    if (existing._hidden || o == null) return;
    final before = ImportFingerprint.parse(existing.link.etag);
    // A series instance's steps and notes came from the series (F5.7):
    // only doing it counts, or a series ended in the calendar would
    // fill Trash with one copy of its list per day.
    final fromSeries =
        _seriesOf(existing.link.accountId, existing.link.seriesKey) != null;
    final localWork =
        o.status != OccurrenceStatus.planned ||
        o.actualStartUtc != null ||
        (!fromSeries &&
            (existing.hasSubtasks || textHash(o.notes) != before?.notes));
    if (!localWork) {
      _removeOccurrences.add(o.id);
      return;
    }
    _occurrences.add(
      o.copyWith(calendarLinkId: null, deletedAt: now, updatedAt: now),
    );
  }

  CalendarImportPlan build() => CalendarImportPlan(
    links: _links,
    occurrences: _occurrences,
    subtasks: _subtasks,
    removeOccurrenceIds: _removeOccurrences,
    removeLinkIds: _removeLinks,
    moved: _moved,
  );
}

/// [o] with each field the calendar changed since [before] taken from
/// [item]. Without a fingerprint everything but notes is taken.
Occurrence _changed(
  Occurrence o,
  ImportFingerprint? before,
  ImportedItem item,
) {
  final now = ImportFingerprint.of(item);
  var out = o;
  if (before?.startMs != now.startMs) {
    out = out.copyWith(startUtc: item.startUtc);
  }
  if (before?.durationMin != now.durationMin) {
    out = out.copyWith(durationMin: item.durationMin);
  }
  if (before?.title != now.title) out = out.copyWith(title: item.title);
  // Notes are the person's once edited here: only untouched ones follow.
  final untouched = before != null && textHash(o.notes) == before.notes;
  if (before?.notes != now.notes && untouched) {
    out = out.copyWith(notes: item.notes);
  }
  return out;
}
