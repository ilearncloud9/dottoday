// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intent_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The five B6 intents (docs/09 M9.2).

@ProviderFor(dotIntents)
final dotIntentsProvider = DotIntentsProvider._();

/// The five B6 intents (docs/09 M9.2).

final class DotIntentsProvider
    extends $FunctionalProvider<DotIntents, DotIntents, DotIntents>
    with $Provider<DotIntents> {
  /// The five B6 intents (docs/09 M9.2).
  DotIntentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dotIntentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dotIntentsHash();

  @$internal
  @override
  $ProviderElement<DotIntents> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DotIntents create(Ref ref) {
    return dotIntents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DotIntents value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DotIntents>(value),
    );
  }
}

String _$dotIntentsHash() => r'cdee753cf347ae80bb25adea47ff04e3c6c8bd00';

/// Where this platform's surfaces queue actions (docs/09 M9.2). On the
/// Mac only the share extension does (M12.4), through the same channel
/// and with no `home_widget` fallback.

@ProviderFor(actionQueueStore)
final actionQueueStoreProvider = ActionQueueStoreProvider._();

/// Where this platform's surfaces queue actions (docs/09 M9.2). On the
/// Mac only the share extension does (M12.4), through the same channel
/// and with no `home_widget` fallback.

final class ActionQueueStoreProvider
    extends
        $FunctionalProvider<
          ActionQueueStore,
          ActionQueueStore,
          ActionQueueStore
        >
    with $Provider<ActionQueueStore> {
  /// Where this platform's surfaces queue actions (docs/09 M9.2). On the
  /// Mac only the share extension does (M12.4), through the same channel
  /// and with no `home_widget` fallback.
  ActionQueueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'actionQueueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$actionQueueStoreHash();

  @$internal
  @override
  $ProviderElement<ActionQueueStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ActionQueueStore create(Ref ref) {
    return actionQueueStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActionQueueStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActionQueueStore>(value),
    );
  }
}

String _$actionQueueStoreHash() => r'0e4baa4733604910271e796a4ff4c3a859db776e';

@ProviderFor(actionQueueDrainer)
final actionQueueDrainerProvider = ActionQueueDrainerProvider._();

final class ActionQueueDrainerProvider
    extends
        $FunctionalProvider<
          ActionQueueDrainer,
          ActionQueueDrainer,
          ActionQueueDrainer
        >
    with $Provider<ActionQueueDrainer> {
  ActionQueueDrainerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'actionQueueDrainerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$actionQueueDrainerHash();

  @$internal
  @override
  $ProviderElement<ActionQueueDrainer> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ActionQueueDrainer create(Ref ref) {
    return actionQueueDrainer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActionQueueDrainer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActionQueueDrainer>(value),
    );
  }
}

String _$actionQueueDrainerHash() =>
    r'1b6cee522a0eee00981be1a49727f44d30b865a2';
