import 'dart:convert';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/engine_sync_service.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/data/sync/synced_rows.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
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

  static const _ids = UuidV7Generator();

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
  Future<Result<ConflictUndo, AppFailure>> resolve(
    String userId,
    String id,
    ConflictChoice choice, {
    String? combined,
  }) async {
    final c = await (_db.select(
      _db.conflicts,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (c == null) return const Err(NotFoundFailure(EntityKind.occurrence));
    final row = await _rows.find(c.entity, userId, c.entityId);
    if (row == null) return const Err(NotFoundFailure(EntityKind.occurrence));
    // What the field holds after the choice, and what Undo puts back.
    final (String? kept, String? replaced) = switch (choice) {
      ConflictChoice.mine => (c.mine, c.theirs),
      ConflictChoice.theirs => (c.theirs, c.mine),
      ConflictChoice.both => (jsonEncode(combined), c.mine),
    };
    if (choice == ConflictChoice.both &&
        (c.field != 'notes' ||
            combined == null ||
            combined.length > maxNotesLength)) {
      return const Err(
        ValidationFailure(ValidationField.notes, ValidationRule.tooLong),
      );
    }
    // "Keep theirs": the server's value is already the row's.
    if (choice != ConflictChoice.theirs) {
      row[c.field] = kept == null ? null : jsonDecode(kept);
      final written = await _writes.apply(_batch(userId, c.entity, row));
      if (written case Err(:final failure)) return Err(failure);
    }
    await close(id);
    return Ok(
      ConflictUndo(
        entity: c.entity,
        entityId: c.entityId,
        column: c.field,
        restore: replaced,
        expect: kept,
        kept: choice,
        field: _fieldOf(c.field),
        title: (row['title'] ?? row['display_name'] ?? '') as String,
      ),
    );
  }

  @override
  Future<Result<void, AppFailure>> undo(String userId, ConflictUndo u) async {
    final row = await _rows.find(u.entity, userId, u.entityId);
    if (row == null) return const Err(NotFoundFailure(EntityKind.occurrence));
    final now = jsonEncode(row[u.column]);
    if (now != (u.expect ?? 'null')) {
      // Changed since, here or elsewhere: nothing is overwritten; the two
      // values meet again as a new conflict (ED-194).
      await _db
          .into(_db.conflicts)
          .insert(
            ConflictsCompanion.insert(
              id: _ids.newId(),
              userId: userId,
              entity: u.entity,
              entityId: u.entityId,
              field: u.column,
              mine: Value(u.restore),
              theirs: Value(now),
              createdAt: _clock.nowUtc().millisecondsSinceEpoch,
            ),
          );
      return const Ok(null);
    }
    row[u.column] = u.restore == null ? null : jsonDecode(u.restore!);
    final written = await _writes.apply(_batch(userId, u.entity, row));
    return switch (written) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  /// Closes conflict [id] as resolved.
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
    'reveal_hints' => WriteBatch(
      userId: userId,
      revealHints: [RevealHint.fromJson(row)],
    ),
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
      mineNotes: r.field == 'notes' ? _text(r.mine) : null,
      theirsNotes: r.field == 'notes' ? _text(r.theirs) : null,
    );
  }

  /// A stored notes value as text (null when empty).
  static String? _text(String? json) =>
      switch (json == null ? null : jsonDecode(json)) {
        final String text => text,
        _ => null,
      };

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
