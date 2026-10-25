import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:timezone/timezone.dart' as tz;

/// Creates the one local profile on first launch (docs/05 "Local schema":
/// before sign-in its id is a client UUID v7), so the app works fully
/// without an account (docs/02 F7, R-08).
final class LocalProfileService {
  LocalProfileService({
    required SettingsRepository settings,
    required WriteUseCase writes,
    required Clock clock,
    required IdGenerator ids,
  }) : _settings = settings,
       _writes = writes,
       _clock = clock,
       _ids = ids;

  final SettingsRepository _settings;
  final WriteUseCase _writes;
  final Clock _clock;
  final IdGenerator _ids;

  /// The existing local profile, or a new one in [deviceTzId] (falling back
  /// to UTC when the device reports a zone the tz database doesn't know).
  /// Never replaces an existing profile, so it is safe on every start.
  /// [language] is the device's language when the app speaks it (docs/09
  /// M8.3): a new profile starts in it; the user can change it in Settings.
  ///
  /// ```dart
  /// await service.ensure('Europe/Berlin', language: 'de');
  /// ```
  Future<Result<Profile, AppFailure>> ensure(
    String deviceTzId, {
    String language = 'en',
  }) async {
    final existing = await _settings.findLocalProfile();
    if (existing != null) return Ok(existing);
    final now = _clock.nowUtc();
    final profile = Profile(
      id: _ids.newId(),
      tzId: _knownZone(deviceTzId) ? deviceTzId : 'UTC',
      locale: language,
      createdAt: now,
      updatedAt: now,
    );
    final written = await _writes.apply(
      WriteBatch(userId: profile.id, profile: profile),
    );
    return written.map((_) => profile);
  }

  static bool _knownZone(String id) {
    try {
      tz.getLocation(id);
      return true;
    } on tz.LocationNotFoundException {
      return false;
    }
  }
}
