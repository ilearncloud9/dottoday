// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the CR-160 account screens do (A1–A3, G1, G1b, B1, D1, web
/// retry). A port so widget tests check the screens without a database.

@ProviderFor(accountActions)
final accountActionsProvider = AccountActionsProvider._();

/// What the CR-160 account screens do (A1–A3, G1, G1b, B1, D1, web
/// retry). A port so widget tests check the screens without a database.

final class AccountActionsProvider
    extends $FunctionalProvider<AccountActions, AccountActions, AccountActions>
    with $Provider<AccountActions> {
  /// What the CR-160 account screens do (A1–A3, G1, G1b, B1, D1, web
  /// retry). A port so widget tests check the screens without a database.
  AccountActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountActionsHash();

  @$internal
  @override
  $ProviderElement<AccountActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountActions create(Ref ref) {
    return accountActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountActions>(value),
    );
  }
}

String _$accountActionsHash() => r'25b3099725fe90f253e0a9b6dccf42f074e797f0';
