import 'package:dottoday/domain/entities/settings.dart';

/// The local owner's profile and settings (docs/05 `profiles`). There is one
/// local profile; before sign-in its id is a client UUID v7 (05 "Local
/// schema"). Writes are for the write path only (M2.3).
abstract interface class SettingsRepository {
  /// The profile [userId], re-emitting on every change; null until created.
  Stream<Profile?> watchProfile(String userId);

  /// The local profile, or null on first launch.
  Future<Profile?> findLocalProfile();

  /// Inserts or replaces the profile by id.
  Future<void> upsert(Profile profile);
}
