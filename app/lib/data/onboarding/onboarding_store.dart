import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_store.g.dart';

/// This device's onboarding (docs/09 M4): in `local_meta`, never synced —
/// a new device asks again (O5's sign-in then brings the data).
@Riverpod(keepAlive: true)
class Onboarding extends _$Onboarding {
  static const _key = 'onboarding';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<OnboardingProgress> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    if (row == null) return OnboardingProgress.start;
    return OnboardingProgress.fromJson(jsonDecode(row.value));
  }

  /// Moves to [step] and remembers it (resume after a kill).
  Future<void> go(OnboardingStep step) => _save(OnboardingProgress(step: step));

  /// "Open today": onboarding never shows again on this device.
  Future<void> finish() => _save(
    const OnboardingProgress(step: OnboardingStep.done, finished: true),
  );

  Future<void> _save(OnboardingProgress progress) async {
    state = AsyncData(progress);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(
            key: _key,
            value: jsonEncode(progress.toJson()),
          ),
        );
  }
}
