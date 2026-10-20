// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The loaded [Env]. Overridden in `bootstrap()`; reading it without the
/// override is a wiring bug.

@ProviderFor(env)
final envProvider = EnvProvider._();

/// The loaded [Env]. Overridden in `bootstrap()`; reading it without the
/// override is a wiring bug.

final class EnvProvider extends $FunctionalProvider<Env, Env, Env>
    with $Provider<Env> {
  /// The loaded [Env]. Overridden in `bootstrap()`; reading it without the
  /// override is a wiring bug.
  EnvProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'envProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$envHash();

  @$internal
  @override
  $ProviderElement<Env> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Env create(Ref ref) {
    return env(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Env value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Env>(value),
    );
  }
}

String _$envHash() => r'2d8af06ae5ed1161a8172d38551308b6ea869167';
