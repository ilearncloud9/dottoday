import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
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
  final result = await ref.read(localProfileServiceProvider).ensure(tzId);
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}
