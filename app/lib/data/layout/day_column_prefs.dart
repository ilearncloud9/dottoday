import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'day_column_prefs.g.dart';

/// Whether the person hid Minimal's Day column beside Now on the Mac and
/// the web (ED-218: ⌥⌘I, its ✕, View › Show Day Column). A view setting,
/// not a place: remembered on this device in `local_meta`, never synced,
/// and it never changes the address (ED-097).
@Riverpod(keepAlive: true)
class DayColumnHidden extends _$DayColumnHidden {
  static const _key = 'day_column_hidden';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<bool> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    return row?.value == 'true';
  }

  /// Shows it when hidden, hides it when shown.
  Future<void> toggle() => set(hidden: !(state.value ?? false));

  /// Hides or shows it, and remembers that on this device.
  Future<void> set({required bool hidden}) async {
    state = AsyncData(hidden);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: _key, value: '$hidden'),
        );
  }
}
