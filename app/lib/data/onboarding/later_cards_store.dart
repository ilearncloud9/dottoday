import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'later_cards_store.g.dart';

/// "Later, when it helps" (the onboarding prototype, M20.11 part 6,
/// ED-491): what each one-time card on Today has already done. In
/// `local_meta`, never synced; a device that never onboarded has none.
final class LaterCardsState {
  const LaterCardsState({
    this.onboardedUtc,
    this.habits = const [],
    this.habitsOffered = const {},
    this.simpler = false,
    this.close = false,
    this.sync = false,
  });

  /// When this device finished onboarding; null: no cards here.
  final DateTime? onboardedUtc;

  /// The tasks What fills your days saved (their series ids).
  final List<String> habits;

  /// Those already offered "Make it a habit" (once each).
  final Set<String> habitsOffered;

  /// Done with: "Want it simpler?", "Close the day", the second "Sign in
  /// to sync".
  final bool simpler;
  final bool close;
  final bool sync;

  Map<String, Object?> toJson() => {
    'onboarded': onboardedUtc?.millisecondsSinceEpoch,
    'habits': habits,
    'offered': habitsOffered.toList(),
    'simpler': simpler,
    'close': close,
    'sync': sync,
  };

  static LaterCardsState fromJson(Object? json) {
    if (json is! Map) return const LaterCardsState();
    final at = json['onboarded'];
    return LaterCardsState(
      onboardedUtc: at is int
          ? DateTime.fromMillisecondsSinceEpoch(at, isUtc: true)
          : null,
      habits: [for (final h in json['habits'] as List? ?? const []) '$h'],
      habitsOffered: {
        for (final h in json['offered'] as List? ?? const []) '$h',
      },
      simpler: json['simpler'] == true,
      close: json['close'] == true,
      sync: json['sync'] == true,
    );
  }

  LaterCardsState copy({
    DateTime? onboardedUtc,
    List<String>? habits,
    Set<String>? habitsOffered,
    bool? simpler,
    bool? close,
    bool? sync,
  }) => LaterCardsState(
    onboardedUtc: onboardedUtc ?? this.onboardedUtc,
    habits: habits ?? this.habits,
    habitsOffered: habitsOffered ?? this.habitsOffered,
    simpler: simpler ?? this.simpler,
    close: close ?? this.close,
    sync: sync ?? this.sync,
  );
}

/// This device's later cards (see [LaterCardsState]).
@Riverpod(keepAlive: true)
class LaterCards extends _$LaterCards {
  static const _key = 'later_cards';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<LaterCardsState> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    if (row == null) return const LaterCardsState();
    return LaterCardsState.fromJson(jsonDecode(row.value));
  }

  /// Onboarding finished at [nowUtc]: the cards start counting from here.
  Future<void> begin(DateTime nowUtc) =>
      _change((s) => LaterCardsState(onboardedUtc: nowUtc, habits: s.habits));

  /// What fills your days saved [ids]; each may be offered "Make it a
  /// habit" once.
  Future<void> addHabits(Iterable<String> ids) =>
      _change((s) => s.copy(habits: {...s.habits, ...ids}.toList()));

  Future<void> habitDone(String id) =>
      _change((s) => s.copy(habitsOffered: {...s.habitsOffered, id}));

  Future<void> simplerDone() => _change((s) => s.copy(simpler: true));

  Future<void> closeDone() => _change((s) => s.copy(close: true));

  Future<void> syncDone() => _change((s) => s.copy(sync: true));

  Future<void> _change(LaterCardsState Function(LaterCardsState s) f) async {
    final now = state.value ?? await future;
    final next = f(now);
    state = AsyncData(next);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(
            key: _key,
            value: jsonEncode(next.toJson()),
          ),
        );
  }
}
