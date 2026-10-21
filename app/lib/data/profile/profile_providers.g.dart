// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The device's IANA zone. Tests override it with a fixed zone.

@ProviderFor(deviceTimeZone)
final deviceTimeZoneProvider = DeviceTimeZoneProvider._();

/// The device's IANA zone. Tests override it with a fixed zone.

final class DeviceTimeZoneProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The device's IANA zone. Tests override it with a fixed zone.
  DeviceTimeZoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceTimeZoneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceTimeZoneHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return deviceTimeZone(ref);
  }
}

String _$deviceTimeZoneHash() => r'da8435051f5a230e8226ec34f24cb12af69bacea';

@ProviderFor(localProfileService)
final localProfileServiceProvider = LocalProfileServiceProvider._();

final class LocalProfileServiceProvider
    extends
        $FunctionalProvider<
          LocalProfileService,
          LocalProfileService,
          LocalProfileService
        >
    with $Provider<LocalProfileService> {
  LocalProfileServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localProfileServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localProfileServiceHash();

  @$internal
  @override
  $ProviderElement<LocalProfileService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalProfileService create(Ref ref) {
    return localProfileService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalProfileService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalProfileService>(value),
    );
  }
}

String _$localProfileServiceHash() =>
    r'7aa8b451cd2d9ad9414d91fdc07525885ebdc866';

/// The local profile, created on first launch. Throws the [AppFailure] if
/// it can't be written (shown by the error state, M3.11).

@ProviderFor(localProfile)
final localProfileProvider = LocalProfileProvider._();

/// The local profile, created on first launch. Throws the [AppFailure] if
/// it can't be written (shown by the error state, M3.11).

final class LocalProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile>, Profile, FutureOr<Profile>>
    with $FutureModifier<Profile>, $FutureProvider<Profile> {
  /// The local profile, created on first launch. Throws the [AppFailure] if
  /// it can't be written (shown by the error state, M3.11).
  LocalProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile> create(Ref ref) {
    return localProfile(ref);
  }
}

String _$localProfileHash() => r'f2637855d0402658205a4ed4d1bbf82c5a654832';

/// The local profile, re-emitting whenever it (or its settings) change.

@ProviderFor(currentProfile)
final currentProfileProvider = CurrentProfileProvider._();

/// The local profile, re-emitting whenever it (or its settings) change.

final class CurrentProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile>, Profile, Stream<Profile>>
    with $FutureModifier<Profile>, $StreamProvider<Profile> {
  /// The local profile, re-emitting whenever it (or its settings) change.
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  $StreamProviderElement<Profile> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Profile> create(Ref ref) {
    return currentProfile(ref);
  }
}

String _$currentProfileHash() => r'cf72fc349450f73915b747bffe0fd5a38a82798c';
