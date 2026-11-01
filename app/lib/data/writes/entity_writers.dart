import 'package:dottoday/data/repositories/drift_calendar_series_repository.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_reveal_hint_repository.dart';
import 'package:dottoday/data/repositories/drift_routine_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/writes/row_writer.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';

// Table names are the `sync_push` entities (supabase/migrations/0002).

EntityWriter<Profile> profileWriter(DriftSettingsRepository repo) =>
    EntityWriter(
      table: 'profiles',
      toJson: (p) => p.toJson(),
      idOf: (p) => p.id,
      stamp: (p, now) => p.copyWith(updatedAt: now),
      find: (id) => repo.watchProfile(id).first,
      upsertAll: (rows) async {
        for (final p in rows) {
          await repo.upsert(p);
        }
      },
    );

EntityWriter<Series> seriesWriter(String userId, DriftSeriesRepository repo) =>
    EntityWriter(
      table: 'series',
      toJson: (s) => s.toJson(),
      idOf: (s) => s.id,
      stamp: (s, now) => s.copyWith(updatedAt: now),
      find: (id) => repo.findById(userId, id),
      upsertAll: repo.upsertAll,
    );

EntityWriter<Routine> routineWriter(
  String userId,
  DriftRoutineRepository repo,
) => EntityWriter(
  table: 'routines',
  toJson: (r) => r.toJson(),
  idOf: (r) => r.id,
  stamp: (r, now) => r.copyWith(updatedAt: now),
  find: (id) => repo.findById(userId, id),
  upsertAll: repo.upsertAll,
);

EntityWriter<RevealHint> revealHintWriter(
  String userId,
  DriftRevealHintRepository repo,
) => EntityWriter(
  table: 'reveal_hints',
  toJson: (h) => h.toJson(),
  idOf: (h) => h.id,
  stamp: (h, now) => h.copyWith(updatedAt: now),
  find: (id) => repo.findById(userId, id),
  upsertAll: repo.upsertAll,
);

/// Repeating calendar events' settings (docs/02 F5.7): device-only like
/// the imports they shape, so `table` is never logged to the outbox.
EntityWriter<CalendarSeries> calendarSeriesWriter(
  String userId,
  DriftCalendarSeriesRepository repo,
) => EntityWriter(
  table: 'calendar_series',
  toJson: (s) => s.toJson(),
  idOf: (s) => s.id,
  stamp: (s, now) => s.copyWith(updatedAt: now),
  find: (id) => repo.findById(userId, id),
  upsertAll: repo.upsertAll,
  deviceOnly: (_) async => true,
);

EntityWriter<Occurrence> occurrenceWriter(
  String userId,
  DriftOccurrenceRepository repo,
) => EntityWriter(
  table: 'occurrences',
  toJson: (o) => o.toJson(),
  idOf: (o) => o.id,
  stamp: (o, now) => o.copyWith(updatedAt: now),
  find: (id) => repo.findById(userId, id),
  upsertAll: repo.upsertAll,
  deviceOnly: (o) async => isDeviceOnly(o),
);

/// Subtasks follow their occurrence: those on a device-calendar import
/// stay on the device too. Written after occurrences, so a new parent in
/// the same batch is already there.
EntityWriter<Subtask> subtaskWriter(
  String userId,
  DriftSubtaskRepository repo,
  DriftOccurrenceRepository occurrences,
) => EntityWriter(
  table: 'subtasks',
  toJson: (s) => s.toJson(),
  idOf: (s) => s.id,
  stamp: (s, now) => s.copyWith(updatedAt: now),
  find: (id) => repo.findById(userId, id),
  upsertAll: repo.upsertAll,
  deviceOnly: (s) async {
    final parent = await occurrences.findById(userId, s.occurrenceId);
    return parent != null && isDeviceOnly(parent);
  },
);
