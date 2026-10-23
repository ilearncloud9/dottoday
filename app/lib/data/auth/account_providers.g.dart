// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Supabase client, when bootstrap could start one (M6.1); null in
/// tests and when it couldn't, and the app then stays on this device.

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

/// The Supabase client, when bootstrap could start one (M6.1); null in
/// tests and when it couldn't, and the app then stays on this device.

final class SupabaseClientProvider
    extends
        $FunctionalProvider<SupabaseClient?, SupabaseClient?, SupabaseClient?>
    with $Provider<SupabaseClient?> {
  /// The Supabase client, when bootstrap could start one (M6.1); null in
  /// tests and when it couldn't, and the app then stays on this device.
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient? create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient?>(value),
    );
  }
}

String _$supabaseClientHash() => r'e034314418ad8d758342b69de8cf5438dfb7b7e1';

/// Sign-in callbacks from the router (bootstrap overrides it with the
/// inbox the router delivers to).

@ProviderFor(authCallbackInbox)
final authCallbackInboxProvider = AuthCallbackInboxProvider._();

/// Sign-in callbacks from the router (bootstrap overrides it with the
/// inbox the router delivers to).

final class AuthCallbackInboxProvider
    extends
        $FunctionalProvider<
          AuthCallbackInbox,
          AuthCallbackInbox,
          AuthCallbackInbox
        >
    with $Provider<AuthCallbackInbox> {
  /// Sign-in callbacks from the router (bootstrap overrides it with the
  /// inbox the router delivers to).
  AuthCallbackInboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authCallbackInboxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authCallbackInboxHash();

  @$internal
  @override
  $ProviderElement<AuthCallbackInbox> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthCallbackInbox create(Ref ref) {
    return authCallbackInbox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthCallbackInbox value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthCallbackInbox>(value),
    );
  }
}

String _$authCallbackInboxHash() => r'05716f967b7a40df2a44c6be06161c1ec1f5828a';

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

String _$accountServiceHash() => r'33582ab706bd8d80f35647fa9c166791133ecf55';

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
