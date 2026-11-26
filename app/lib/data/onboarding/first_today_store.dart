import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'first_today_store.g.dart';

/// What the first Today after onboarding still has to show (the
/// prototype's "You're in", M20.11 part 5, ED-490): the rows rising in
/// once, the one-time hint "Tap the circle when it's done", and the "Sign
/// in to sync" card until it is dismissed. In `local_meta`, never synced;
/// a device that never onboarded (an upgrade) shows none of it.
final class FirstTodayState {
  const FirstTodayState({
    this.rise = false,
    this.hint = false,
    this.sync = false,
  });

  final bool rise;
  final bool hint;
  final bool sync;

  Map<String, Object?> toJson() => {'rise': rise, 'hint': hint, 'sync': sync};

  static FirstTodayState fromJson(Object? json) => json is Map
      ? FirstTodayState(
          rise: json['rise'] == true,
          hint: json['hint'] == true,
          sync: json['sync'] == true,
        )
      : const FirstTodayState();

  FirstTodayState copy({bool? rise, bool? hint, bool? sync}) => FirstTodayState(
    rise: rise ?? this.rise,
    hint: hint ?? this.hint,
    sync: sync ?? this.sync,
  );
}

/// This device's first Today (see [FirstTodayState]).
@Riverpod(keepAlive: true)
class FirstToday extends _$FirstToday {
  static const _key = 'first_today';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<FirstTodayState> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    if (row == null) return const FirstTodayState();
    return FirstTodayState.fromJson(jsonDecode(row.value));
  }

  /// Onboarding finished: all three, once.
  Future<void> begin() =>
      _save(const FirstTodayState(rise: true, hint: true, sync: true));

  /// The rows have risen in.
  Future<void> risen() => _change((s) => s.copy(rise: false));

  /// The hint has been seen and tapped away; it never comes back.
  Future<void> hintDone() => _change((s) => s.copy(hint: false));

  /// The sync card was dismissed (✕) or Sign in was tapped.
  Future<void> syncDone() => _change((s) => s.copy(sync: false));

  Future<void> _change(
    FirstTodayState Function(FirstTodayState s) change,
  ) async {
    final now = state.value ?? await future;
    await _save(change(now));
  }

  Future<void> _save(FirstTodayState next) async {
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

/// The link between the hinted task's done circle and the hint.
@Riverpod(keepAlive: true)
LayerLink firstTodayLink(Ref ref) => LayerLink();
