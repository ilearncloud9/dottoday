// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tier_seen_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The OS's version string; tests override it.

@ProviderFor(osVersion)
final osVersionProvider = OsVersionProvider._();

/// The OS's version string; tests override it.

final class OsVersionProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The OS's version string; tests override it.
  OsVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'osVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$osVersionHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return osVersion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$osVersionHash() => r'51eda75666481e18843db4194c3ae9e8d9523eb6';

/// When an OS update last brought this phone the alarm tier (docs/15 §11),
/// or null. Each look stores what the device can do now (`local_meta`,
/// this device only), so the next OS update is compared with it. Off a
/// phone, null.

@ProviderFor(alarmTierGainedAt)
final alarmTierGainedAtProvider = AlarmTierGainedAtProvider._();

/// When an OS update last brought this phone the alarm tier (docs/15 §11),
/// or null. Each look stores what the device can do now (`local_meta`,
/// this device only), so the next OS update is compared with it. Off a
/// phone, null.

final class AlarmTierGainedAtProvider
    extends
        $FunctionalProvider<
          AsyncValue<DateTime?>,
          DateTime?,
          FutureOr<DateTime?>
        >
    with $FutureModifier<DateTime?>, $FutureProvider<DateTime?> {
  /// When an OS update last brought this phone the alarm tier (docs/15 §11),
  /// or null. Each look stores what the device can do now (`local_meta`,
  /// this device only), so the next OS update is compared with it. Off a
  /// phone, null.
  AlarmTierGainedAtProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alarmTierGainedAtProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alarmTierGainedAtHash();

  @$internal
  @override
  $FutureProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime?> create(Ref ref) {
    return alarmTierGainedAt(ref);
  }
}

String _$alarmTierGainedAtHash() => r'c2f33c52c395d8e41f55264f01339e39d412281d';
