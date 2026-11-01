import 'package:dottoday/domain/calendar/calendar_series_settings.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/recurrence/series_change.dart';

/// The repeating calendar event an imported occurrence is an instance of
/// (docs/02 F5.7): its account and series key, and what was set for it so
/// far ([settings], null until the first edit with scope All).
final class ImportedSeries {
  const ImportedSeries({
    required this.accountId,
    required this.seriesKey,
    this.settings,
  });

  final String accountId;
  final String seriesKey;
  final CalendarSeries? settings;

  /// [settings], or a new row setting nothing yet.
  CalendarSeries settingsOr({
    required String userId,
    required String Function() newId,
    required DateTime now,
  }) =>
      settings ??
      CalendarSeries(
        id: newId(),
        userId: userId,
        accountId: accountId,
        seriesKey: seriesKey,
        createdAt: now,
        updatedAt: now,
      );
}

/// What one scope-All edit or delete of an imported series writes: its
/// settings row and the instances it changes, as one batch (one Undo).
typedef ImportedSeriesWrite = ({
  CalendarSeries settings,
  List<Occurrence> occurrences,
});

/// [change] to every instance of [series] from [fromUtc] on (the start of
/// today), and to the instances that arrive later through [series]'
/// settings. [instances] are the series' imported occurrences; done,
/// skipped and earlier ones stay as they were, [target] always changes.
/// Alerts and sound become each row's own: an import has no series row to
/// inherit from.
///
/// ```dart
/// editImportedSeries(series: s, instances: rows, target: o,
///     change: const SeriesChange(startMinute: 330), fromUtc: today, …);
/// ```
ImportedSeriesWrite editImportedSeries({
  required ImportedSeries series,
  required List<Occurrence> instances,
  required Occurrence target,
  required SeriesChange change,
  required DateTime fromUtc,
  required DateTime now,
  required String Function() newId,
}) {
  final settings = _withChange(
    series.settingsOr(userId: target.userId, newId: newId, now: now),
    change,
    target.tzId,
  ).copyWith(updatedAt: now);
  return (
    settings: settings,
    occurrences: [
      for (final o in _reached(instances, target, fromUtc))
        atSeriesTime(
          change.fields(o, own: true),
          settings,
        ).copyWith(updatedAt: now),
    ],
  );
}

/// Deletes [series] with scope All: no instance comes back on re-import,
/// and [target] plus every planned instance from [fromUtc] go to Trash.
ImportedSeriesWrite deleteImportedSeries({
  required ImportedSeries series,
  required List<Occurrence> instances,
  required Occurrence target,
  required DateTime fromUtc,
  required DateTime now,
  required String Function() newId,
}) => (
  settings: series
      .settingsOr(userId: target.userId, newId: newId, now: now)
      .copyWith(hidden: true, updatedAt: now),
  occurrences: [
    for (final o in _reached(instances, target, fromUtc))
      o.copyWith(deletedAt: now, updatedAt: now),
  ],
);

/// [target] and the live planned instances starting at or after [fromUtc].
Iterable<Occurrence> _reached(
  List<Occurrence> instances,
  Occurrence target,
  DateTime fromUtc,
) => [
  target,
  for (final o in instances)
    if (o.id != target.id &&
        o.deletedAt == null &&
        o.status == OccurrenceStatus.planned &&
        !(o.startUtc?.isBefore(fromUtc) ?? true))
      o,
];

CalendarSeries _withChange(CalendarSeries s, SeriesChange c, String tzId) =>
    s.copyWith(
      title: c.title ?? s.title,
      notes: switch (c.notes) {
        (:final to) => to,
        null => s.notes,
      },
      colorKey: c.colorKey ?? s.colorKey,
      iconKey: c.iconKey ?? s.iconKey,
      durationMin: c.durationMin ?? s.durationMin,
      pinned: c.pinned ?? s.pinned,
      energy: switch (c.energy) {
        (:final to) => to,
        null => s.energy,
      },
      startMinute: c.startMinute ?? s.startMinute,
      tzId: c.startMinute == null ? s.tzId : tzId,
      alerts: c.alerts ?? s.alerts,
      soundId: switch (c.soundId) {
        (:final to) => to,
        null => s.soundId,
      },
    );
