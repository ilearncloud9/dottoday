import 'dart:ui' show PlatformDispatcher;

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

/// The device's IANA zone. Tests override it with a fixed zone.
@Riverpod(keepAlive: true)
Future<String> deviceTimeZone(Ref ref) async =>
    (await FlutterTimezone.getLocalTimezone()).identifier;

/// The device's zone now, re-read when the app comes back (M5.9): it
/// differs from the profile's after a flight until the person picks
/// keep or shift. [deviceTimeZone] stays the launch value, so the profile
/// isn't rebuilt on every resume.
@Riverpod(keepAlive: true)
Future<String> currentDeviceZone(Ref ref) async =>
    (await FlutterTimezone.getLocalTimezone()).identifier;

/// The first of the device's preferred languages the app speaks, else
/// `en`: what a new profile starts in (docs/09 M8.3). Tests override it.
@Riverpod(keepAlive: true)
String deviceLanguage(Ref ref) => supportedLanguage(
  PlatformDispatcher.instance.locales.map((l) => l.languageCode),
);

/// The first of [preferred] (language codes, most wanted first) that has
/// an ARB file, else `en`.
///
/// ```dart
/// supportedLanguage(['pt', 'fr']); // 'fr'
/// ```
String supportedLanguage(Iterable<String> preferred) {
  final spoken = {
    for (final l in AppLocalizations.supportedLocales) l.languageCode,
  };
  return preferred.where(spoken.contains).firstOrNull ?? 'en';
}

@Riverpod(keepAlive: true)
LocalProfileService localProfileService(Ref ref) => LocalProfileService(
  settings: ref.watch(settingsRepositoryProvider),
  writes: ref.watch(writeUseCaseProvider),
  clock: ref.watch(clockProvider),
  ids: const UuidV7Generator(),
);

/// The local profile, created on first launch. Throws the [AppFailure] if
/// it can't be written (shown by the error state, M3.11).
@Riverpod(keepAlive: true)
Future<Profile> localProfile(Ref ref) async {
  final tzId = await ref.watch(deviceTimeZoneProvider.future);
  final result = await ref
      .read(localProfileServiceProvider)
      .ensure(tzId, language: ref.read(deviceLanguageProvider));
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

/// The local profile, re-emitting whenever it (or its settings) change.
@Riverpod(keepAlive: true)
Stream<Profile> currentProfile(Ref ref) async* {
  final local = await ref.watch(localProfileProvider.future);
  yield local;
  yield* ref
      .watch(settingsRepositoryProvider)
      .watchProfile(local.id)
      .where((p) => p != null)
      .cast<Profile>();
}
