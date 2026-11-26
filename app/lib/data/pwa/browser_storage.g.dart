// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(browserStorageGateway)
final browserStorageGatewayProvider = BrowserStorageGatewayProvider._();

final class BrowserStorageGatewayProvider
    extends
        $FunctionalProvider<
          BrowserStorageGateway,
          BrowserStorageGateway,
          BrowserStorageGateway
        >
    with $Provider<BrowserStorageGateway> {
  BrowserStorageGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserStorageGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserStorageGatewayHash();

  @$internal
  @override
  $ProviderElement<BrowserStorageGateway> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BrowserStorageGateway create(Ref ref) {
    return browserStorageGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrowserStorageGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrowserStorageGateway>(value),
    );
  }
}

String _$browserStorageGatewayHash() =>
    r'eebd652f7c35864b9fc0610b8e1c36002b71229c';

/// Whether something has been saved in this browser yet: a task on the
/// day or in the Inbox (the guest's "first saved change", ED-192).

@ProviderFor(savedInBrowser)
final savedInBrowserProvider = SavedInBrowserProvider._();

/// Whether something has been saved in this browser yet: a task on the
/// day or in the Inbox (the guest's "first saved change", ED-192).

final class SavedInBrowserProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether something has been saved in this browser yet: a task on the
  /// day or in the Inbox (the guest's "first saved change", ED-192).
  SavedInBrowserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedInBrowserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedInBrowserHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return savedInBrowser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$savedInBrowserHash() => r'351e2bfde9706066e4a8879ba6ec4b49439a0b14';

/// What the browser keeps for Dottoday (E-G4-7 Q2, ED-188 to ED-192;
/// M20.10 part 6, ED-484); null off the web. Checks silently; asks the
/// browser to keep the data once per browser profile and owner, after
/// sign-in, or for a guest after the first saved change; never blocks,
/// never asks again, and an unanswered or missing API counts as
/// "can't be asked".

@ProviderFor(browserStorage)
final browserStorageProvider = BrowserStorageProvider._();

/// What the browser keeps for Dottoday (E-G4-7 Q2, ED-188 to ED-192;
/// M20.10 part 6, ED-484); null off the web. Checks silently; asks the
/// browser to keep the data once per browser profile and owner, after
/// sign-in, or for a guest after the first saved change; never blocks,
/// never asks again, and an unanswered or missing API counts as
/// "can't be asked".

final class BrowserStorageProvider
    extends
        $FunctionalProvider<
          AsyncValue<BrowserStorageState?>,
          BrowserStorageState?,
          FutureOr<BrowserStorageState?>
        >
    with
        $FutureModifier<BrowserStorageState?>,
        $FutureProvider<BrowserStorageState?> {
  /// What the browser keeps for Dottoday (E-G4-7 Q2, ED-188 to ED-192;
  /// M20.10 part 6, ED-484); null off the web. Checks silently; asks the
  /// browser to keep the data once per browser profile and owner, after
  /// sign-in, or for a guest after the first saved change; never blocks,
  /// never asks again, and an unanswered or missing API counts as
  /// "can't be asked".
  BrowserStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserStorageHash();

  @$internal
  @override
  $FutureProviderElement<BrowserStorageState?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BrowserStorageState?> create(Ref ref) {
    return browserStorage(ref);
  }
}

String _$browserStorageHash() => r'420187544ca1597e20fb4f660481ca1794f50f26';
