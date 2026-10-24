// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'write_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The notification scheduler (M5.1, M5.3): the OS on iOS, Android and
/// macOS, timers + service worker on the web.

@ProviderFor(notificationGateway)
final notificationGatewayProvider = NotificationGatewayProvider._();

/// The notification scheduler (M5.1, M5.3): the OS on iOS, Android and
/// macOS, timers + service worker on the web.

final class NotificationGatewayProvider
    extends
        $FunctionalProvider<
          NotificationGateway,
          NotificationGateway,
          NotificationGateway
        >
    with $Provider<NotificationGateway> {
  /// The notification scheduler (M5.1, M5.3): the OS on iOS, Android and
  /// macOS, timers + service worker on the web.
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
    r'2ed6d11ff874122b02b95ef7fe908614b85b3a7e';

/// Where the widget snapshot goes (M5.4, M5.5): home-screen widgets on
/// iOS and Android, the menu-bar "Next up" on the Mac, nothing on the web.

@ProviderFor(widgetSnapshotSink)
final widgetSnapshotSinkProvider = WidgetSnapshotSinkProvider._();

/// Where the widget snapshot goes (M5.4, M5.5): home-screen widgets on
/// iOS and Android, the menu-bar "Next up" on the Mac, nothing on the web.

final class WidgetSnapshotSinkProvider
    extends
        $FunctionalProvider<
          WidgetSnapshotSink,
          WidgetSnapshotSink,
          WidgetSnapshotSink
        >
    with $Provider<WidgetSnapshotSink> {
  /// Where the widget snapshot goes (M5.4, M5.5): home-screen widgets on
  /// iOS and Android, the menu-bar "Next up" on the Mac, nothing on the web.
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
    r'0c403a4200f623c11395c3f07b0dbf467a8f6c20';

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

String _$notificationSyncHash() => r'281790121b5d1826fbbc74db7f69ad9450d96d4e';

@ProviderFor(widgetSnapshotWriter)
final widgetSnapshotWriterProvider = WidgetSnapshotWriterProvider._();

final class WidgetSnapshotWriterProvider
    extends
        $FunctionalProvider<
          WidgetSnapshotWriter,
          WidgetSnapshotWriter,
          WidgetSnapshotWriter
        >
    with $Provider<WidgetSnapshotWriter> {
  WidgetSnapshotWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetSnapshotWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetSnapshotWriterHash();

  @$internal
  @override
  $ProviderElement<WidgetSnapshotWriter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WidgetSnapshotWriter create(Ref ref) {
    return widgetSnapshotWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WidgetSnapshotWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WidgetSnapshotWriter>(value),
    );
  }
}

String _$widgetSnapshotWriterHash() =>
    r'eace0e52516193bd15d764424b882407f953d5d9';

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

String _$afterWriteEffectsHash() => r'e357b5071a1c02cf53eff43218819c935f3829e9';

/// This device's one HLC, shared by the write path and sync (M6.2).

@ProviderFor(sharedHlc)
final sharedHlcProvider = SharedHlcProvider._();

/// This device's one HLC, shared by the write path and sync (M6.2).

final class SharedHlcProvider
    extends $FunctionalProvider<SharedHlc, SharedHlc, SharedHlc>
    with $Provider<SharedHlc> {
  /// This device's one HLC, shared by the write path and sync (M6.2).
  SharedHlcProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedHlcProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedHlcHash();

  @$internal
  @override
  $ProviderElement<SharedHlc> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharedHlc create(Ref ref) {
    return sharedHlc(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedHlc value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedHlc>(value),
    );
  }
}

String _$sharedHlcHash() => r'bde61acbe169c4d817e4ed158596b4ced9ba1784';

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

String _$writeUseCaseHash() => r'8fd52b9178d807874125f0f01fcd83489c3a2452';
