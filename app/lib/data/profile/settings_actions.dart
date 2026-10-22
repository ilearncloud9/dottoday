import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The local profile as stored now, for actions outside the widget tree.
///
/// Reads the row, not `currentProfileProvider`: a stream that is only
/// read (never listened to) can be dropped before its first value, and a
/// re-created one starts from the launch-time profile.
Future<Profile> readProfile(ProviderContainer ref) async {
  final stored = await ref.read(settingsRepositoryProvider).findLocalProfile();
  return stored ?? await ref.read<Future<Profile>>(localProfileProvider.future);
}

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
  // Two quick edits must not start from the same stale settings.
  final profile = await readProfile(ref);
  final next = profile.copyWith(
    settings: change(profile.settings),
    updatedAt: ref.read(clockProvider).nowUtc(),
  );
  return ref
      .read(writeUseCaseProvider)
      .apply(WriteBatch(userId: next.id, profile: next));
}

/// Applies [change] to the local profile itself (name, language).
Future<Result<void, AppFailure>> updateProfile(
  ProviderContainer ref,
  Profile Function(Profile profile) change,
) async {
  final profile = await readProfile(ref);
  final next = change(
    profile,
  ).copyWith(id: profile.id, updatedAt: ref.read(clockProvider).nowUtc());
  return ref
      .read(writeUseCaseProvider)
      .apply(WriteBatch(userId: next.id, profile: next));
}
