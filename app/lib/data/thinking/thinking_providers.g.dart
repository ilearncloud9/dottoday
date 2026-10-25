// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thinking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Saved breakdowns, past lengths and the local prompt log.

@ProviderFor(thinkingMemory)
final thinkingMemoryProvider = ThinkingMemoryProvider._();

/// Saved breakdowns, past lengths and the local prompt log.

final class ThinkingMemoryProvider
    extends
        $FunctionalProvider<
          LocalThinkingMemory,
          LocalThinkingMemory,
          LocalThinkingMemory
        >
    with $Provider<LocalThinkingMemory> {
  /// Saved breakdowns, past lengths and the local prompt log.
  ThinkingMemoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thinkingMemoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thinkingMemoryHash();

  @$internal
  @override
  $ProviderElement<LocalThinkingMemory> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalThinkingMemory create(Ref ref) {
    return thinkingMemory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalThinkingMemory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalThinkingMemory>(value),
    );
  }
}

String _$thinkingMemoryHash() => r'7aedffe53438378a8fc95e6a031a1ebc22069743';

/// The platform's on-device model transport: the method channel on
/// iOS/macOS/Android, the Prompt API in the browser.

@ProviderFor(thinkingTransport)
final thinkingTransportProvider = ThinkingTransportProvider._();

/// The platform's on-device model transport: the method channel on
/// iOS/macOS/Android, the Prompt API in the browser.

final class ThinkingTransportProvider
    extends
        $FunctionalProvider<
          ThinkingTransport,
          ThinkingTransport,
          ThinkingTransport
        >
    with $Provider<ThinkingTransport> {
  /// The platform's on-device model transport: the method channel on
  /// iOS/macOS/Android, the Prompt API in the browser.
  ThinkingTransportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thinkingTransportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thinkingTransportHash();

  @$internal
  @override
  $ProviderElement<ThinkingTransport> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ThinkingTransport create(Ref ref) {
    return thinkingTransport(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThinkingTransport value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThinkingTransport>(value),
    );
  }
}

String _$thinkingTransportHash() => r'46f58a42452dfe852a010f2f7ea0e5f0d7e8e7bb';

/// B4 (docs/09 M10.1): on-device first, then rules. No remote backend is
/// wired (ADR-0009; a provider is a must-ask).

@ProviderFor(thinkingService)
final thinkingServiceProvider = ThinkingServiceProvider._();

/// B4 (docs/09 M10.1): on-device first, then rules. No remote backend is
/// wired (ADR-0009; a provider is a must-ask).

final class ThinkingServiceProvider
    extends
        $FunctionalProvider<ThinkingService, ThinkingService, ThinkingService>
    with $Provider<ThinkingService> {
  /// B4 (docs/09 M10.1): on-device first, then rules. No remote backend is
  /// wired (ADR-0009; a provider is a must-ask).
  ThinkingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thinkingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thinkingServiceHash();

  @$internal
  @override
  $ProviderElement<ThinkingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThinkingService create(Ref ref) {
    return thinkingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThinkingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThinkingService>(value),
    );
  }
}

String _$thinkingServiceHash() => r'836648fac87317b223a4a305641c6cfe4fb2abdd';

/// Which path answers on this device now (Settings › Privacy): the model
/// when the platform says it is ready, else rules. Reads only the
/// transport, so the page never opens the database for it. Kept: the
/// answer only changes with an OS update or a model download.

@ProviderFor(thinkingPath)
final thinkingPathProvider = ThinkingPathProvider._();

/// Which path answers on this device now (Settings › Privacy): the model
/// when the platform says it is ready, else rules. Reads only the
/// transport, so the page never opens the database for it. Kept: the
/// answer only changes with an OS update or a model download.

final class ThinkingPathProvider
    extends
        $FunctionalProvider<
          AsyncValue<ThinkingPath>,
          ThinkingPath,
          FutureOr<ThinkingPath>
        >
    with $FutureModifier<ThinkingPath>, $FutureProvider<ThinkingPath> {
  /// Which path answers on this device now (Settings › Privacy): the model
  /// when the platform says it is ready, else rules. Reads only the
  /// transport, so the page never opens the database for it. Kept: the
  /// answer only changes with an OS update or a model download.
  ThinkingPathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thinkingPathProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thinkingPathHash();

  @$internal
  @override
  $FutureProviderElement<ThinkingPath> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ThinkingPath> create(Ref ref) {
    return thinkingPath(ref);
  }
}

String _$thinkingPathHash() => r'35171c2981ab286fbab99586833e2032fec20f0b';
