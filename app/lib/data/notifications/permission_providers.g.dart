// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The OS permission on iOS, Android and macOS (M5.1), the browser's on
/// the web (M5.3).

@ProviderFor(notificationPermission)
final notificationPermissionProvider = NotificationPermissionProvider._();

/// The OS permission on iOS, Android and macOS (M5.1), the browser's on
/// the web (M5.3).

final class NotificationPermissionProvider
    extends
        $FunctionalProvider<
          NotificationPermission,
          NotificationPermission,
          NotificationPermission
        >
    with $Provider<NotificationPermission> {
  /// The OS permission on iOS, Android and macOS (M5.1), the browser's on
  /// the web (M5.3).
  NotificationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionHash();

  @$internal
  @override
  $ProviderElement<NotificationPermission> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPermission create(Ref ref) {
    return notificationPermission(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPermission value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPermission>(value),
    );
  }
}

String _$notificationPermissionHash() =>
    r'aa532e40fa6c4abfb6eded1fb8be52385de59370';

/// The permission now; re-read with `ref.invalidate` (on resume, after
/// Open settings).

@ProviderFor(notificationPermissionState)
final notificationPermissionStateProvider =
    NotificationPermissionStateProvider._();

/// The permission now; re-read with `ref.invalidate` (on resume, after
/// Open settings).

final class NotificationPermissionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<PermissionState>,
          PermissionState,
          FutureOr<PermissionState>
        >
    with $FutureModifier<PermissionState>, $FutureProvider<PermissionState> {
  /// The permission now; re-read with `ref.invalidate` (on resume, after
  /// Open settings).
  NotificationPermissionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionStateHash();

  @$internal
  @override
  $FutureProviderElement<PermissionState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PermissionState> create(Ref ref) {
    return notificationPermissionState(ref);
  }
}

String _$notificationPermissionStateHash() =>
    r'052dcc753552c350bac049f8a386d0b21e8f3081';

/// Exact reminder timing (M5.6): gated on Android 12+ only.

@ProviderFor(exactAlarms)
final exactAlarmsProvider = ExactAlarmsProvider._();

/// Exact reminder timing (M5.6): gated on Android 12+ only.

final class ExactAlarmsProvider
    extends $FunctionalProvider<ExactAlarms, ExactAlarms, ExactAlarms>
    with $Provider<ExactAlarms> {
  /// Exact reminder timing (M5.6): gated on Android 12+ only.
  ExactAlarmsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exactAlarmsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exactAlarmsHash();

  @$internal
  @override
  $ProviderElement<ExactAlarms> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExactAlarms create(Ref ref) {
    return exactAlarms(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExactAlarms value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExactAlarms>(value),
    );
  }
}

String _$exactAlarmsHash() => r'b95f05bee03f27aaf5fd0625ff303e16795c6689';

/// Whether exact timing is allowed now; re-read with `ref.invalidate` (on
/// resume, after the system screen).

@ProviderFor(exactAlarmsAllowed)
final exactAlarmsAllowedProvider = ExactAlarmsAllowedProvider._();

/// Whether exact timing is allowed now; re-read with `ref.invalidate` (on
/// resume, after the system screen).

final class ExactAlarmsAllowedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether exact timing is allowed now; re-read with `ref.invalidate` (on
  /// resume, after the system screen).
  ExactAlarmsAllowedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exactAlarmsAllowedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exactAlarmsAllowedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return exactAlarmsAllowed(ref);
  }
}

String _$exactAlarmsAllowedHash() =>
    r'73e8dc8fadea490d2c39abfe044bf5fd1b5c21ad';
