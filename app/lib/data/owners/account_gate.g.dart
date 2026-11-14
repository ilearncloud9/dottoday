// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_gate.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether this build runs in a browser: the copy says "this browser", and
/// an interrupted removal waits for "Finish removing" (policy §4). Tests
/// override it.

@ProviderFor(inBrowser)
final inBrowserProvider = InBrowserProvider._();

/// Whether this build runs in a browser: the copy says "this browser", and
/// an interrupted removal waits for "Finish removing" (policy §4). Tests
/// override it.

final class InBrowserProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether this build runs in a browser: the copy says "this browser", and
  /// an interrupted removal waits for "Finish removing" (policy §4). Tests
  /// override it.
  InBrowserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inBrowserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inBrowserHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return inBrowser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$inBrowserHash() => r'2c4f8fa0ad2cf4332f75035517c38099286009f2';

/// The signed-in account's auth id, or null; tests override it.

@ProviderFor(signedInAccountId)
final signedInAccountIdProvider = SignedInAccountIdProvider._();

/// The signed-in account's auth id, or null; tests override it.

final class SignedInAccountIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// The signed-in account's auth id, or null; tests override it.
  SignedInAccountIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signedInAccountIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signedInAccountIdHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return signedInAccountId(ref);
  }
}

String _$signedInAccountIdHash() => r'6e567b2409c69e008a52102ae63883ce63fed174';

/// The gate in front of the planner, live.

@ProviderFor(accountGate)
final accountGateProvider = AccountGateProvider._();

/// The gate in front of the planner, live.

final class AccountGateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountGate>,
          AccountGate,
          Stream<AccountGate>
        >
    with $FutureModifier<AccountGate>, $StreamProvider<AccountGate> {
  /// The gate in front of the planner, live.
  AccountGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountGateHash();

  @$internal
  @override
  $StreamProviderElement<AccountGate> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AccountGate> create(Ref ref) {
    return accountGate(ref);
  }
}

String _$accountGateHash() => r'211d5dab25ae188a33114ea0f66dbd8e5c41a7d0';

/// Whether Settings › Account offers "Choose settings" (B1 deferred).

@ProviderFor(settingsChoiceLater)
final settingsChoiceLaterProvider = SettingsChoiceLaterProvider._();

/// Whether Settings › Account offers "Choose settings" (B1 deferred).

final class SettingsChoiceLaterProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether Settings › Account offers "Choose settings" (B1 deferred).
  SettingsChoiceLaterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsChoiceLaterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsChoiceLaterHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return settingsChoiceLater(ref);
  }
}

String _$settingsChoiceLaterHash() =>
    r'a43b928b172fe001f4b06f0a9b03310ee843abec';

/// The shown owner's changes not yet synced (A1 vs A2, D1's summary).

@ProviderFor(ownerPending)
final ownerPendingProvider = OwnerPendingFamily._();

/// The shown owner's changes not yet synced (A1 vs A2, D1's summary).

final class OwnerPendingProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// The shown owner's changes not yet synced (A1 vs A2, D1's summary).
  OwnerPendingProvider._({
    required OwnerPendingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ownerPendingProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ownerPendingHash();

  @override
  String toString() {
    return r'ownerPendingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return ownerPending(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OwnerPendingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ownerPendingHash() => r'013fc174dd5866d08f84fe675f628ff7ea8f773b';

/// The shown owner's changes not yet synced (A1 vs A2, D1's summary).

final class OwnerPendingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  OwnerPendingFamily._()
    : super(
        retry: null,
        name: r'ownerPendingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The shown owner's changes not yet synced (A1 vs A2, D1's summary).

  OwnerPendingProvider call(String owner) =>
      OwnerPendingProvider._(argument: owner, from: this);

  @override
  String toString() => r'ownerPendingProvider';
}
