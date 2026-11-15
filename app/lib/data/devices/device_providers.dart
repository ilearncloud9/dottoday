import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/devices/device_identity.dart';
import 'package:dottoday/data/devices/device_remote.dart';
import 'package:dottoday/data/devices/device_reporter.dart';
import 'package:dottoday/data/devices/drift_device_repository.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/repositories/device_repository.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_providers.g.dart';

/// The local cache of the account's devices (ED-084).
@Riverpod(keepAlive: true)
DeviceRepository deviceRepository(Ref ref) =>
    DriftDeviceRepository(ref.watch(appDatabaseProvider));

/// This install: its id per account, platform and form.
@Riverpod(keepAlive: true)
DeviceIdentity deviceIdentity(Ref ref) =>
    DeviceIdentity.onDatabase(ref.watch(appDatabaseProvider));

/// Keeps this install's row and decides whether it rings Wake Up.
@Riverpod(keepAlive: true)
DeviceReporter deviceReporter(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return DeviceReporter(
    identity: ref.watch(deviceIdentityProvider),
    devices: ref.watch(deviceRepositoryProvider),
    clock: ref.watch(clockProvider),
    remote: client == null ? null : SupabaseDeviceRemote(client),
    // Read when it runs, not when built: the write path itself re-plans
    // notifications through this reporter.
    claim: (profile, id) async {
      final latest =
          await ref.read(settingsRepositoryProvider).findLocalProfile() ??
          profile;
      if (latest.settings.alarmDeviceId != null) return;
      final next = latest.copyWith(
        settings: latest.settings.copyWith(alarmDeviceId: id),
        updatedAt: ref.read(clockProvider).nowUtc(),
      );
      // Through the container: the write path depends on this reporter
      // (via NotificationSync), so `ref.read` is a CircularDependencyError
      // in debug builds; reading it when the claim runs is not a cycle.
      await ref.container
          .read(writeUseCaseProvider)
          .apply(WriteBatch(userId: next.id, profile: next));
    },
    alarmsAllowed: () async {
      final caps = await ref.read(alarmGatewayProvider).capabilities();
      return !caps.blockers.contains(AlarmBlocker.permissionDenied);
    },
    logger: ref.watch(loggerProvider),
  );
}

/// [userId]'s devices as last seen, most recent first.
@riverpod
Stream<List<Device>> devices(Ref ref, String userId) =>
    ref.watch(deviceRepositoryProvider).watchAll(userId);

/// This install's id on [userId]'s device list.
@riverpod
Future<String> selfDeviceId(Ref ref, String userId) =>
    ref.watch(deviceIdentityProvider).idFor(userId);
