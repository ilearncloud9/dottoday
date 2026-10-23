// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'write_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// OS notification scheduler (M5.1): the OS on iOS, Android and macOS;
/// unwired on the web until web push (M5.3).

@ProviderFor(notificationGateway)
final notificationGatewayProvider = NotificationGatewayProvider._();

/// OS notification scheduler (M5.1): the OS on iOS, Android and macOS;
/// unwired on the web until web push (M5.3).

final class NotificationGatewayProvider
    extends
        $FunctionalProvider<
          NotificationGateway,
          NotificationGateway,
          NotificationGateway
        >
    with $Provider<NotificationGateway> {
  /// OS notification scheduler (M5.1): the OS on iOS, Android and macOS;
  /// unwired on the web until web push (M5.3).
  NotificationGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationGatewayHash();

  @$internal
  @override
  $ProviderElement<NotificationGateway> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationGateway create(Ref ref) {
    return notificationGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationGateway>(value),
    );
  }
}

String _$notificationGatewayHash() =>
    r'404d3d1b2c336bb4ad52d9bcec5c5d894850639f';

/// Home-screen widget snapshot target; replaced in M5.4.

@ProviderFor(widgetSnapshotSink)
final widgetSnapshotSinkProvider = WidgetSnapshotSinkProvider._();

/// Home-screen widget snapshot target; replaced in M5.4.

final class WidgetSnapshotSinkProvider
    extends
        $FunctionalProvider<
          WidgetSnapshotSink,
          WidgetSnapshotSink,
          WidgetSnapshotSink
        >
    with $Provider<WidgetSnapshotSink> {
  /// Home-screen widget snapshot target; replaced in M5.4.
  WidgetSnapshotSinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetSnapshotSinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetSnapshotSinkHash();

  @$internal
  @override
  $ProviderElement<WidgetSnapshotSink> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WidgetSnapshotSink create(Ref ref) {
    return widgetSnapshotSink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WidgetSnapshotSink value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WidgetSnapshotSink>(value),
    );
  }
}

String _$widgetSnapshotSinkHash() =>
    r'7e61b5f03388e413d85d362d418f37a8e17181da';

@ProviderFor(notificationSync)
final notificationSyncProvider = NotificationSyncProvider._();

final class NotificationSyncProvider
    extends
        $FunctionalProvider<
          NotificationSync,
          NotificationSync,
          NotificationSync
        >
    with $Provider<NotificationSync> {
  NotificationSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSyncHash();

  @$internal
  @override
  $ProviderElement<NotificationSync> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationSync create(Ref ref) {
    return notificationSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationSync value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationSync>(value),
    );
  }
}

String _$notificationSyncHash() => r'19a04226f2610c9877c6e13a64b331582d64c250';

@ProviderFor(afterWriteEffects)
final afterWriteEffectsProvider = AfterWriteEffectsProvider._();

final class AfterWriteEffectsProvider
    extends
        $FunctionalProvider<
          AfterWriteEffects,
          AfterWriteEffects,
          AfterWriteEffects
        >
    with $Provider<AfterWriteEffects> {
  AfterWriteEffectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'afterWriteEffectsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$afterWriteEffectsHash();

  @$internal
  @override
  $ProviderElement<AfterWriteEffects> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AfterWriteEffects create(Ref ref) {
    return afterWriteEffects(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AfterWriteEffects value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AfterWriteEffects>(value),
    );
  }
}

String _$afterWriteEffectsHash() => r'309e17b1f68d058571e05455b0025169f35f5d3d';

/// The single write path (docs/09 M2.3).

@ProviderFor(writeUseCase)
final writeUseCaseProvider = WriteUseCaseProvider._();

/// The single write path (docs/09 M2.3).

final class WriteUseCaseProvider
    extends $FunctionalProvider<WriteUseCase, WriteUseCase, WriteUseCase>
    with $Provider<WriteUseCase> {
  /// The single write path (docs/09 M2.3).
  WriteUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writeUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writeUseCaseHash();

  @$internal
  @override
  $ProviderElement<WriteUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WriteUseCase create(Ref ref) {
    return writeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WriteUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WriteUseCase>(value),
    );
  }
}

String _$writeUseCaseHash() => r'2df2267a43a0a32d2bdaf8c5e2ccce34b7492ec7';
