// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$envHash() => r'2d8af06ae5ed1161a8172d38551308b6ea869167';

/// The loaded [Env]. Overridden in `bootstrap()`; reading it without the
/// override is a wiring bug.
///
/// Copied from [env].
@ProviderFor(env)
final envProvider = Provider<Env>.internal(
  env,
  name: r'envProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$envHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EnvRef = ProviderRef<Env>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
