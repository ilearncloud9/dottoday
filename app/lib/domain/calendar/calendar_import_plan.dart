import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// One switched-on device calendar and the events read from it.
final class ImportSource {
  const ImportSource({
    required this.accountId,
    required this.calendar,
    required this.colorKey,
    required this.items,
  });

  /// Its `calendar_accounts` row (`calendar_links.account_id`).
  final String accountId;
  final DeviceCalendar calendar;

  /// The inherited task colour new items take.
  final String colorKey;
  final List<ImportedItem> items;
}

/// A stored link and its occurrence. [occurrence] is null once the row
/// was purged from Trash; a deleted or purged one means "I removed this
/// event here", so it is never brought back.
final class LinkedOccurrence {
  const LinkedOccurrence({
    required this.link,
    required this.occurrence,
    this.hasSubtasks = false,
  });

  final CalendarLink link;
  final Occurrence? occurrence;

  /// Whether it has live subtasks (local work, docs/02 F5).
  final bool hasSubtasks;

  bool get _hidden => occurrence == null || occurrence!.deletedAt != null;
}

/// An imported event whose start the calendar changed (docs/09 M11.1b):
/// Today offers Rebalance for it. Only planned, visible occurrences.
final class CalendarMove {
  const CalendarMove({
    required this.occurrenceId,
    required this.title,
    required this.fromUtc,
    required this.toUtc,
    required this.durationMin,
  });

  final String occurrenceId;
  final String title;

  /// Its start here before the import, and the calendar's new start.
  final DateTime fromUtc;
  final DateTime toUtc;
  final int durationMin;

  /// How far it moved: positive when later.
  int get deltaMin => toUtc.difference(fromUtc).inMinutes;

  /// Its end before the move: what followed it starts from here.
  DateTime get oldEndUtc => fromUtc.add(Duration(minutes: durationMin));
}

/// What one import writes (docs/09 M7.2). Applied in one transaction:
/// [links] first (occurrences reference them), then [occurrences] through
/// the write path, then the deletes.
final class CalendarImportPlan {
  const CalendarImportPlan({
    this.links = const [],
    this.occurrences = const [],
    this.removeOccurrenceIds = const {},
    this.removeLinkIds = const {},
    this.moved = const [],
  });

  /// New and changed links.
  final List<CalendarLink> links;

  /// New and changed occurrences, and gone ones that carry local work,
  /// soft-deleted and detached so Trash keeps them.
  final List<Occurrence> occurrences;

  /// Gone events' occurrences with nothing of the person's on them: a
  /// copy of the calendar, removed outright (never synced, docs/05).
  final Set<String> removeOccurrenceIds;
  final Set<String> removeLinkIds;

  /// Events the calendar moved (M11.1b); not written, reported.
  final List<CalendarMove> moved;

  bool get isEmpty =>
      links.isEmpty &&
      occurrences.isEmpty &&
      removeOccurrenceIds.isEmpty &&
      removeLinkIds.isEmpty;
}

/// The occurrences the [sources] should have in `[fromUtc, toUtc)`, given
/// what is [existing] (all device-calendar links of the user).
///
/// - An item and a link match on event id + instance, else on event id
///   alone when exactly one of each is left (an event moved in the
///   calendar keeps its subtasks and notes, R-09).
/// - A match changes only what changed in the calendar since the last
///   import ([ImportFingerprint]); notes edited here are never replaced.
/// - A link with no item, in the window of a switched-on calendar or
///   anywhere for a calendar now off or gone, is removed — except links
///   of [untouchedAccountIds] (calendars that couldn't be read: an error
///   never deletes anything, R-08).
/// - [heldLinkIds] (edits here still on their way to the calendar,
///   M7.3) still match their items, so nothing is duplicated, but are
///   neither changed nor removed: write-back merges them.
CalendarImportPlan planCalendarImport({
  required String userId,
  required List<ImportSource> sources,
  required List<LinkedOccurrence> existing,
  required DateTime fromUtc,
  required DateTime toUtc,
  required String tzId,
  required DateTime now,
  required String Function() newId,
  Set<String> untouchedAccountIds = const {},
  Set<String> heldLinkIds = const {},
}) {
  final out = _PlanBuilder(
    userId: userId,
    tzId: tzId,
    now: now,
    newId: newId,
    held: heldLinkIds,
  );
  final bySource = {for (final s in sources) s.accountId: s};
  final inWindow = <String, List<LinkedOccurrence>>{};
  bool within(int ms) =>
      ms >= fromUtc.millisecondsSinceEpoch && ms < toUtc.millisecondsSinceEpoch;
  for (final e in existing) {
    final account = e.link.accountId;
    if (untouchedAccountIds.contains(account)) continue;
    final ms = parseImportKey(e.link.externalEventId)?.$2;
    if (!bySource.containsKey(account)) {
      out.remove(e);
    } else if (ms != null && within(ms)) {
      (inWindow[account] ??= []).add(e);
    }
  }
  for (final source in sources) {
    // One item per key: a provider listing an instance twice must not
    // break the link's unique key.
    final seen = <String>{};
    final items = [
      for (final i in source.items)
        if (within(i.keyMs) && seen.add(i.key)) i,
    ];
    _reconcile(out, source, items, inWindow[source.accountId] ?? const []);
  }
  return out.build();
}

void _reconcile(
  _PlanBuilder out,
  ImportSource source,
  List<ImportedItem> items,
  List<LinkedOccurrence> links,
) {
  final byKey = {for (final l in links) l.link.externalEventId: l};
  final unmatched = <ImportedItem>[];
  for (final item in items) {
    final link = byKey.remove(item.key);
    link == null ? unmatched.add(item) : out.update(source, link, item);
  }
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

final class _PlanBuilder {
  _PlanBuilder({
    required this.userId,
    required this.tzId,
    required this.now,
    required this.newId,
    required this.held,
  });

  final String userId;
  final String tzId;
  final DateTime now;
  final String Function() newId;
  final Set<String> held;
  final _links = <CalendarLink>[];
  final _occurrences = <Occurrence>[];
  final _removeOccurrences = <String>{};
  final _removeLinks = <String>{};
  final _moved = <CalendarMove>[];

  void add(ImportSource source, ImportedItem item) {
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
    _occurrences.add(
      Occurrence(
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
      ),
    );
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
    final localWork =
        existing.hasSubtasks ||
        o.status != OccurrenceStatus.planned ||
        o.actualStartUtc != null ||
        textHash(o.notes) != before?.notes;
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
