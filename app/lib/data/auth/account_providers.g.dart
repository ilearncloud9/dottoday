// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountService)
final accountServiceProvider = AccountServiceProvider._();

final class AccountServiceProvider
    extends $FunctionalProvider<AccountService, AccountService, AccountService>
    with $Provider<AccountService> {
  AccountServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountServiceHash();

  @$internal
  @override
  $ProviderElement<AccountService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountService create(Ref ref) {
    return accountService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountService>(value),
    );
  }
}

String _$accountServiceHash() => r'895e6d994a4e83c1f1da36f60643e272ac04d5cd';

/// The current account, live.

@ProviderFor(account)
final accountProvider = AccountProvider._();

/// The current account, live.

final class AccountProvider
    extends $FunctionalProvider<AsyncValue<Account>, Account, Stream<Account>>
    with $FutureModifier<Account>, $StreamProvider<Account> {
  /// The current account, live.
  AccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountHash();

  @$internal
  @override
  $StreamProviderElement<Account> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Account> create(Ref ref) {
    return account(ref);
  }
}

String _$accountHash() => r'82e06c3143b95c376243b4cd12a5b6ae5806db20';
