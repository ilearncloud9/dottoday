// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The OS permission on iOS, Android and macOS (M5.1); the web's arrives
/// with web push (M5.3).

@ProviderFor(notificationPermission)
final notificationPermissionProvider = NotificationPermissionProvider._();

/// The OS permission on iOS, Android and macOS (M5.1); the web's arrives
/// with web push (M5.3).

final class NotificationPermissionProvider
    extends
        $FunctionalProvider<
          NotificationPermission,
          NotificationPermission,
          NotificationPermission
        >
    with $Provider<NotificationPermission> {
  /// The OS permission on iOS, Android and macOS (M5.1); the web's arrives
  /// with web push (M5.3).
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
    r'b03e3a21e2df0ee999cd9d139a63e5561038b2ad';

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
