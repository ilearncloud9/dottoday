// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceAuth)
final deviceAuthProvider = DeviceAuthProvider._();

final class DeviceAuthProvider
    extends $FunctionalProvider<DeviceAuth, DeviceAuth, DeviceAuth>
    with $Provider<DeviceAuth> {
  DeviceAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceAuthHash();

  @$internal
  @override
  $ProviderElement<DeviceAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceAuth create(Ref ref) {
    return deviceAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceAuth>(value),
    );
  }
}

String _$deviceAuthHash() => r'9e5857d434ce5f0c24de717c13f182385c306499';

/// The app-lock setting, kept in `local_meta` on this device only.

@ProviderFor(AppLockSetting)
final appLockSettingProvider = AppLockSettingProvider._();

/// The app-lock setting, kept in `local_meta` on this device only.
final class AppLockSettingProvider
    extends $AsyncNotifierProvider<AppLockSetting, AppLockSettings> {
  /// The app-lock setting, kept in `local_meta` on this device only.
  AppLockSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockSettingHash();

  @$internal
  @override
  AppLockSetting create() => AppLockSetting();
}

String _$appLockSettingHash() => r'7b7bc44cac4e09fbb8bad966c3f4e95424218644';

/// The app-lock setting, kept in `local_meta` on this device only.

abstract class _$AppLockSetting extends $AsyncNotifier<AppLockSettings> {
  FutureOr<AppLockSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppLockSettings>, AppLockSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppLockSettings>, AppLockSettings>,
              AsyncValue<AppLockSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the app is locked now: at start when the lock is on, and again
/// on return after the chosen delay (docs/06 §2, M5.8).

@ProviderFor(AppLocked)
final appLockedProvider = AppLockedProvider._();

/// Whether the app is locked now: at start when the lock is on, and again
/// on return after the chosen delay (docs/06 §2, M5.8).
final class AppLockedProvider extends $NotifierProvider<AppLocked, bool> {
  /// Whether the app is locked now: at start when the lock is on, and again
  /// on return after the chosen delay (docs/06 §2, M5.8).
  AppLockedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockedHash();

  @$internal
  @override
  AppLocked create() => AppLocked();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appLockedHash() => r'6bc31547fc4f70cb708ea2f8a111d5509c9e8680';

/// Whether the app is locked now: at start when the lock is on, and again
/// on return after the chosen delay (docs/06 §2, M5.8).

abstract class _$AppLocked extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
