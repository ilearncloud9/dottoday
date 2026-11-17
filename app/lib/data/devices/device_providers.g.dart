// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The local cache of the account's devices (ED-084).

@ProviderFor(deviceRepository)
final deviceRepositoryProvider = DeviceRepositoryProvider._();

/// The local cache of the account's devices (ED-084).

final class DeviceRepositoryProvider
    extends
        $FunctionalProvider<
          DeviceRepository,
          DeviceRepository,
          DeviceRepository
        >
    with $Provider<DeviceRepository> {
  /// The local cache of the account's devices (ED-084).
  DeviceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeviceRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceRepository create(Ref ref) {
    return deviceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceRepository>(value),
    );
  }
}

String _$deviceRepositoryHash() => r'7df67ea79988a0ad0d6b22e2f36e8aeef0556c32';

/// This install: its id per account, platform and form.

@ProviderFor(deviceIdentity)
final deviceIdentityProvider = DeviceIdentityProvider._();

/// This install: its id per account, platform and form.

final class DeviceIdentityProvider
    extends $FunctionalProvider<DeviceIdentity, DeviceIdentity, DeviceIdentity>
    with $Provider<DeviceIdentity> {
  /// This install: its id per account, platform and form.
  DeviceIdentityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceIdentityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceIdentityHash();

  @$internal
  @override
  $ProviderElement<DeviceIdentity> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceIdentity create(Ref ref) {
    return deviceIdentity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceIdentity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceIdentity>(value),
    );
  }
}

String _$deviceIdentityHash() => r'f37658a8d95ecf15f96bd8400ec4a2bf4aa16ab2';

/// Keeps this install's row and decides whether it rings Wake Up.

@ProviderFor(deviceReporter)
final deviceReporterProvider = DeviceReporterProvider._();

/// Keeps this install's row and decides whether it rings Wake Up.

final class DeviceReporterProvider
    extends $FunctionalProvider<DeviceReporter, DeviceReporter, DeviceReporter>
    with $Provider<DeviceReporter> {
  /// Keeps this install's row and decides whether it rings Wake Up.
  DeviceReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceReporterHash();

  @$internal
  @override
  $ProviderElement<DeviceReporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceReporter create(Ref ref) {
    return deviceReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceReporter>(value),
    );
  }
}

String _$deviceReporterHash() => r'e634e9bc87cbf4acbedd2b1228db24fbc15dce1c';

/// [userId]'s devices as last seen, most recent first.

@ProviderFor(devices)
final devicesProvider = DevicesFamily._();

/// [userId]'s devices as last seen, most recent first.

final class DevicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Device>>,
          List<Device>,
          Stream<List<Device>>
        >
    with $FutureModifier<List<Device>>, $StreamProvider<List<Device>> {
  /// [userId]'s devices as last seen, most recent first.
  DevicesProvider._({
    required DevicesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'devicesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$devicesHash();

  @override
  String toString() {
    return r'devicesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Device>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Device>> create(Ref ref) {
    final argument = this.argument as String;
    return devices(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DevicesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$devicesHash() => r'2928f37343179946f14017b7bfacf063c520e410';

/// [userId]'s devices as last seen, most recent first.

final class DevicesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Device>>, String> {
  DevicesFamily._()
    : super(
        retry: null,
        name: r'devicesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [userId]'s devices as last seen, most recent first.

  DevicesProvider call(String userId) =>
      DevicesProvider._(argument: userId, from: this);

  @override
  String toString() => r'devicesProvider';
}

/// This install's id on [userId]'s device list.

@ProviderFor(selfDeviceId)
final selfDeviceIdProvider = SelfDeviceIdFamily._();

/// This install's id on [userId]'s device list.

final class SelfDeviceIdProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// This install's id on [userId]'s device list.
  SelfDeviceIdProvider._({
    required SelfDeviceIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'selfDeviceIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selfDeviceIdHash();

  @override
  String toString() {
    return r'selfDeviceIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return selfDeviceId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SelfDeviceIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selfDeviceIdHash() => r'3d4427edbbdc4c10c90dbac70a7aef4bf9ab09b6';

/// This install's id on [userId]'s device list.

final class SelfDeviceIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  SelfDeviceIdFamily._()
    : super(
        retry: null,
        name: r'selfDeviceIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// This install's id on [userId]'s device list.

  SelfDeviceIdProvider call(String userId) =>
      SelfDeviceIdProvider._(argument: userId, from: this);

  @override
  String toString() => r'selfDeviceIdProvider';
}
