import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Applies [change] to the local profile's settings through the write path
/// (validated, change-logged, synced later; docs/09 M2.3). Settings apply
/// at once (03 §3.7), so there is no Undo.
///
/// ```dart
/// updateSettings(container, (s) => s.copyWith(durationPresets: [20, 40]));
/// ```
Future<Result<void, AppFailure>> updateSettings(
  ProviderContainer ref,
  Settings Function(Settings settings) change,
) async {
  // The stored row, not a stream's last value: two quick edits must not
  // start from the same stale settings.
  final stored = await ref.read(settingsRepositoryProvider).findLocalProfile();
  final Profile profile =
      stored ?? await ref.read<Future<Profile>>(localProfileProvider.future);
  final next = profile.copyWith(
    settings: change(profile.settings),
    updatedAt: ref.read(clockProvider).nowUtc(),
  );
  return ref
      .read(writeUseCaseProvider)
      .apply(WriteBatch(userId: next.id, profile: next));
}
