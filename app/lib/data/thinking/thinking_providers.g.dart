// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thinking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Saved breakdowns and the local prompt log.

@ProviderFor(thinkingMemory)
final thinkingMemoryProvider = ThinkingMemoryProvider._();

/// Saved breakdowns and the local prompt log.

final class ThinkingMemoryProvider
    extends
        $FunctionalProvider<
          LocalThinkingMemory,
          LocalThinkingMemory,
          LocalThinkingMemory
        >
    with $Provider<LocalThinkingMemory> {
  /// Saved breakdowns and the local prompt log.
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

String _$thinkingMemoryHash() => r'f20120049315a860669ab2ed16e28642f6a93677';

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

String _$thinkingServiceHash() => r'c2aed232f410ba8bedcf5a987f9f6a15fb2bef58';

/// Whose model this platform would use (docs/09 M14.1). Read here, in
/// the data layer, so widgets never branch on the platform.

@ProviderFor(thinkingVendor)
final thinkingVendorProvider = ThinkingVendorProvider._();

/// Whose model this platform would use (docs/09 M14.1). Read here, in
/// the data layer, so widgets never branch on the platform.

final class ThinkingVendorProvider
    extends $FunctionalProvider<ThinkingVendor, ThinkingVendor, ThinkingVendor>
    with $Provider<ThinkingVendor> {
  /// Whose model this platform would use (docs/09 M14.1). Read here, in
  /// the data layer, so widgets never branch on the platform.
  ThinkingVendorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thinkingVendorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thinkingVendorHash();

  @$internal
  @override
  $ProviderElement<ThinkingVendor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThinkingVendor create(Ref ref) {
    return thinkingVendor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThinkingVendor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThinkingVendor>(value),
    );
  }
}

String _$thinkingVendorHash() => r'50c2eb20d7e8cecf11b8ab6f401daad2e44e1f9e';

/// The model's state on this device and whose it is (Settings › Privacy,
/// the proposal sheets' hint, Brain dump's "Plans with …"). Reads only the
/// transport, so the page never opens the database for it. Re-read with
/// `ref.invalidate` on resume: Apple Intelligence can be switched on in
/// Settings while the app waits.

@ProviderFor(thinkingStatus)
final thinkingStatusProvider = ThinkingStatusProvider._();

/// The model's state on this device and whose it is (Settings › Privacy,
/// the proposal sheets' hint, Brain dump's "Plans with …"). Reads only the
/// transport, so the page never opens the database for it. Re-read with
/// `ref.invalidate` on resume: Apple Intelligence can be switched on in
/// Settings while the app waits.

final class ThinkingStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<ThinkingStatus>,
          ThinkingStatus,
          FutureOr<ThinkingStatus>
        >
    with $FutureModifier<ThinkingStatus>, $FutureProvider<ThinkingStatus> {
  /// The model's state on this device and whose it is (Settings › Privacy,
  /// the proposal sheets' hint, Brain dump's "Plans with …"). Reads only the
  /// transport, so the page never opens the database for it. Re-read with
  /// `ref.invalidate` on resume: Apple Intelligence can be switched on in
  /// Settings while the app waits.
  ThinkingStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thinkingStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thinkingStatusHash();

  @$internal
  @override
  $FutureProviderElement<ThinkingStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ThinkingStatus> create(Ref ref) {
    return thinkingStatus(ref);
  }
}

String _$thinkingStatusHash() => r'536fb3a97d52f1d81398f0634270d5c348c1838b';
