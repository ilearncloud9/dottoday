import 'dart:convert';

import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'learning_meta.g.dart';

/// What this device remembers about learning (docs/13 §8): per-title
/// resets and the reality thread's reveal. In `local_meta`, never synced
/// or exported, so a reset says "on this device".
final class LearningMetaState {
  const LearningMetaState({
    this.resets = const {},
    this.captionDay,
    this.realityRevealed = false,
    this.realityHighlighted = false,
  });

  /// Normalised title → the instant learning starts again from.
  final Map<String, DateTime> resets;

  /// The local day the day card's learning caption was put away.
  final DateTime? captionDay;

  /// Whether the reality threshold was crossed on this device: the toggle
  /// stays even when the 90-day window later empties (docs/13 §4.3).
  final bool realityRevealed;

  /// Whether the one-time toggle highlight has run here.
  final bool realityHighlighted;

  LearningMetaState _copy({
    Map<String, DateTime>? resets,
    DateTime? captionDay,
    bool? realityRevealed,
    bool? realityHighlighted,
  }) => LearningMetaState(
    resets: resets ?? this.resets,
    captionDay: captionDay ?? this.captionDay,
    realityRevealed: realityRevealed ?? this.realityRevealed,
    realityHighlighted: realityHighlighted ?? this.realityHighlighted,
  );
}

/// [LearningMetaState] in `local_meta` (as `InboxNudgeSeen`): each write
/// is persisted before the state is published, and awaited.
@Riverpod(keepAlive: true)
class LearningMeta extends _$LearningMeta {
  static const resetsKey = 'learning_resets';
  static const captionKey = 'learning_caption_day';
  static const revealedKey = 'learning_reality_revealed';
  static const highlightedKey = 'learning_reality_highlighted';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<LearningMetaState> build() async {
    final rows =
        await (_db.select(_db.localMeta)..where(
              (m) => m.key.isIn([
                resetsKey,
                captionKey,
                revealedKey,
                highlightedKey,
              ]),
            ))
            .get();
    final kv = {for (final r in rows) r.key: r.value};
    return LearningMetaState(
      resets: _decodeResets(kv[resetsKey], onUnreadable: _unreadable),
      captionDay: DateTime.tryParse(kv[captionKey] ?? ''),
      realityRevealed: kv[revealedKey] != null,
      realityHighlighted: kv[highlightedKey] != null,
    );
  }

  /// Learning for [title] starts again from [nowUtc] (docs/13 §6); the
  /// previous cutoff, if any, is returned for Undo.
  Future<DateTime?> reset(String title, DateTime nowUtc) async {
    final key = normaliseTitle(title);
    final current = await future;
    final before = current.resets[key];
    await _writeResets({...current.resets, key: nowUtc});
    return before;
  }

  /// [reset], returning its Undo for the snackbar (docs/13 §6).
  Future<Future<void> Function()> resetUndoable(
    String title,
    DateTime nowUtc,
  ) async {
    final before = await reset(title, nowUtc);
    return () => restoreReset(title, before);
  }

  /// Undo of [reset]: [previous] back, or no cutoff at all.
  Future<void> restoreReset(String title, DateTime? previous) async {
    final key = normaliseTitle(title);
    final next = {...(await future).resets}..remove(key);
    if (previous != null) next[key] = previous;
    await _writeResets(next);
  }

  /// The caption is put away for [day] (a local date): it returns tomorrow.
  Future<void> putCaptionAway(DateTime day) async {
    final date = DateTime(day.year, day.month, day.day);
    await persist(captionKey, date.toIso8601String().substring(0, 10));
    state = AsyncData((await future)._copy(captionDay: date));
  }

  /// The reality threshold was seen crossed on [day].
  Future<void> markRealityRevealed(DateTime day) async {
    if ((await future).realityRevealed) return;
    await persist(revealedKey, day.toIso8601String().substring(0, 10));
    state = AsyncData((await future)._copy(realityRevealed: true));
  }

  /// The one-time toggle highlight has run.
  Future<void> markRealityHighlighted() async {
    if ((await future).realityHighlighted) return;
    await persist(highlightedKey, '1');
    state = AsyncData((await future)._copy(realityHighlighted: true));
  }

  // Logged, not thrown: resets are a convenience, never worth a failed
  // launch; learning then simply counts every run again.
  void _unreadable() =>
      ref.read(loggerProvider).warn('learning.resets_unreadable');

  Future<void> _writeResets(Map<String, DateTime> resets) async {
    await persist(
      resetsKey,
      jsonEncode({
        for (final MapEntry(:key, :value) in resets.entries)
          key: value.millisecondsSinceEpoch,
      }),
    );
    state = AsyncData((await future)._copy(resets: resets));
  }

  /// Stores one key; tests replace it to keep the state in memory.
  @protected
  Future<void> persist(String key, String value) => _db
      .into(_db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(key: key, value: value),
      );
}

/// A stored resets map; anything unreadable is reported through
/// [onUnreadable] and counts as no resets.
Map<String, DateTime> _decodeResets(
  String? raw, {
  required void Function() onUnreadable,
}) {
  if (raw == null) return const {};
  final Object? json;
  try {
    json = jsonDecode(raw);
  } on FormatException {
    onUnreadable();
    return const {};
  }
  if (json is! Map<String, Object?>) {
    onUnreadable();
    return const {};
  }
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (value is int)
        key: DateTime.fromMillisecondsSinceEpoch(value, isUtc: true),
  };
}
