import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/entities/utc_millis_converter.dart';

/// Everything a user owns, as exported and imported (docs/05 "Export
/// format", R-11): `{version, exportedAt, profile, series, occurrences,
/// subtasks, routines}`, values in the same canonical form as storage (snake_case,
/// UTC epoch ms).
final class ExportBundle {
  const ExportBundle({
    required this.exportedAt,
    required this.profile,
    this.series = const [],
    this.occurrences = const [],
    this.subtasks = const [],
    this.routines = const [],
  });

  /// Decodes a v1 bundle. Throws on any shape mismatch; use
  /// `decodeExportJson` for validated, user-facing import.
  factory ExportBundle.fromJson(Map<String, Object?> json) {
    List<T> list<T>(String key, T Function(Map<String, Object?>) read) => [
      for (final item in json[key]! as List<Object?>)
        read(item! as Map<String, Object?>),
    ];
    return ExportBundle(
      exportedAt: const UtcMillisConverter().fromJson(
        json['exportedAt']! as int,
      ),
      profile: Profile.fromJson(json['profile']! as Map<String, Object?>),
      series: list('series', Series.fromJson),
      occurrences: list('occurrences', Occurrence.fromJson),
      subtasks: list('subtasks', Subtask.fromJson),
      // Added in M11.4: a file from before routines has none.
      routines: json.containsKey('routines')
          ? list('routines', Routine.fromJson)
          : const [],
    );
  }

  /// The only format version this app reads and writes.
  static const version = 1;

  final DateTime exportedAt;
  final Profile profile;
  final List<Series> series;
  final List<Occurrence> occurrences;
  final List<Subtask> subtasks;
  final List<Routine> routines;

  Map<String, Object?> toJson() => {
    'version': version,
    'exportedAt': const UtcMillisConverter().toJson(exportedAt),
    'profile': profile.toJson(),
    'series': [for (final s in series) s.toJson()],
    'occurrences': [for (final o in occurrences) o.toJson()],
    'subtasks': [for (final s in subtasks) s.toJson()],
    'routines': [for (final r in routines) r.toJson()],
  };

  /// The bundle without imported calendar events and their subtasks
  /// (docs/05 "Export format", M8.1). Imports are device-only and keyed to
  /// this device's calendars (`calendar_links`, never exported), so a copy
  /// in a file could only come back unlinked beside the importer's fresh
  /// one. The calendar stays their source: each device re-imports them.
  ExportBundle withoutImported() {
    bool imported(Occurrence o) => o.source == OccurrenceSource.calendar;
    final droppedIds = {
      for (final o in occurrences)
        if (imported(o)) o.id,
    };
    // Only their subtasks go: one pointing nowhere stays, so an import
    // still refuses a broken file.
    return ExportBundle(
      exportedAt: exportedAt,
      profile: profile,
      series: series,
      occurrences: [
        for (final o in occurrences)
          if (!imported(o)) o,
      ],
      subtasks: [
        for (final s in subtasks)
          if (!droppedIds.contains(s.occurrenceId)) s,
      ],
      routines: routines,
    );
  }

  /// The same data owned by [userId], so an import can never write rows for
  /// another account (06 §9, RLS would reject them anyway).
  ExportBundle reownedTo(String userId) => ExportBundle(
    exportedAt: exportedAt,
    profile: profile.copyWith(id: userId),
    series: [for (final s in series) s.copyWith(userId: userId)],
    occurrences: [for (final o in occurrences) o.copyWith(userId: userId)],
    subtasks: [for (final s in subtasks) s.copyWith(userId: userId)],
    routines: [for (final r in routines) r.copyWith(userId: userId)],
  );
}
