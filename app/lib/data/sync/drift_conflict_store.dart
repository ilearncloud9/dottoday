import 'dart:convert';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/engine_sync_service.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/data/sync/synced_rows.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Open conflicts in the local `conflicts` table (docs/05, docs/04 §4),
/// shown as cards in the Sync sheet (M3f.8). "Keep mine" goes through the
/// write path, so the value gets a new clock and wins on the next push.
final class DriftConflictStore implements ConflictStore {
  DriftConflictStore({
    required AppDatabase db,
    required WriteUseCase writes,
    required Clock clock,
  }) : _db = db,
       _writes = writes,
       _clock = clock,
       _rows = SyncedRows(db);

  final AppDatabase _db;
  final WriteUseCase _writes;
  final Clock _clock;
  final SyncedRows _rows;

  @override
  Stream<List<SyncConflict>> watch(String userId) =>
      (_db.select(_db.conflicts)
            ..where((c) => c.userId.equals(userId) & c.resolvedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .watch()
          .asyncMap((rows) async {
            final zone = await _zone(userId);
            return [for (final r in rows) await _card(userId, r, zone)];
          });

  @override
  Future<Result<void, AppFailure>> keepMine(String userId, String id) async {
    final c = await (_db.select(
      _db.conflicts,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (c == null) return const Err(NotFoundFailure(EntityKind.occurrence));
    final row = await _rows.find(c.entity, userId, c.entityId);
    if (row == null) return const Err(NotFoundFailure(EntityKind.occurrence));
    row[c.field] = c.mine == null ? null : jsonDecode(c.mine!);
    final written = await _writes.apply(_batch(userId, c.entity, row));
    if (written is Ok) await close(id);
    return written;
  }

  @override
  Future<void> close(String id) =>
      (_db.update(_db.conflicts)..where((c) => c.id.equals(id))).write(
        ConflictsCompanion(
          resolvedAt: Value(_clock.nowUtc().millisecondsSinceEpoch),
        ),
      );

  WriteBatch _batch(
    String userId,
    String entity,
    Map<String, Object?> row,
  ) => switch (entity) {
    'profiles' => WriteBatch(userId: userId, profile: Profile.fromJson(row)),
    'series' => WriteBatch(userId: userId, series: [Series.fromJson(row)]),
    'subtasks' => WriteBatch(userId: userId, subtasks: [Subtask.fromJson(row)]),
    'routines' => WriteBatch(userId: userId, routines: [Routine.fromJson(row)]),
    _ => WriteBatch(userId: userId, occurrences: [Occurrence.fromJson(row)]),
  };

  Future<SyncConflict> _card(
    String userId,
    ConflictRow r,
    tz.Location zone,
  ) async {
    final row = await _rows.find(r.entity, userId, r.entityId);
    String show(String? json) =>
        _display(r.field, json == null ? null : jsonDecode(json), zone);
    return SyncConflict(
      id: r.id,
      title: (row?['title'] ?? row?['display_name'] ?? '') as String,
      field: _fieldOf(r.field),
      mine: show(r.mine),
      theirs: show(r.theirs),
    );
  }

  Future<tz.Location> _zone(String userId) async {
    final p = await _rows.find('profiles', userId, userId);
    try {
      return tz.getLocation((p?['tz_id'] as String?) ?? 'UTC');
    } on tz.LocationNotFoundException {
      return tz.UTC;
    }
  }

  static ConflictField _fieldOf(String field) => switch (field) {
    'title' || 'display_name' => ConflictField.title,
    'start_utc' => ConflictField.time,
    'duration_min' => ConflictField.duration,
    'notes' => ConflictField.notes,
    'color_key' || 'icon_key' => ConflictField.colour,
    'status' || 'done' => ConflictField.status,
    _ => ConflictField.other,
  };

  /// A value as the card says it: times in the person's zone, the rest as
  /// written. Never logged (titles and notes are PII).
  static String _display(String field, Object? value, tz.Location zone) {
    if (value == null) return '—';
    if (isInstantField(field) && value is int) {
      final at = tz.TZDateTime.from(
        DateTime.fromMillisecondsSinceEpoch(value, isUtc: true),
        zone,
      );
      return DateFormat.MMMEd().add_jm().format(at);
    }
    return '$value';
  }
}
