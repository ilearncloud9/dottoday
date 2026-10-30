// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Battery optimisation and Do Not Disturb now (Android); re-read with
/// `ref.invalidate` on resume.

@ProviderFor(powerState)
final powerStateProvider = PowerStateProvider._();

/// Battery optimisation and Do Not Disturb now (Android); re-read with
/// `ref.invalidate` on resume.

final class PowerStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<({bool battery, bool dnd})>,
          ({bool battery, bool dnd}),
          FutureOr<({bool battery, bool dnd})>
        >
    with
        $FutureModifier<({bool battery, bool dnd})>,
        $FutureProvider<({bool battery, bool dnd})> {
  /// Battery optimisation and Do Not Disturb now (Android); re-read with
  /// `ref.invalidate` on resume.
  PowerStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'powerStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$powerStateHash();

  @$internal
  @override
  $FutureProviderElement<({bool battery, bool dnd})> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({bool battery, bool dnd})> create(Ref ref) {
    return powerState(ref);
  }
}

String _$powerStateHash() => r'9b399b8c6951632b8debc11e5f8be75892ae0be2';

/// Sounds in use whose Android channel the user muted (docs/12 §4): the
/// default and Start sounds and every pending reminder's. Re-read with
/// `ref.invalidate` on resume.

@ProviderFor(mutedSounds)
final mutedSoundsProvider = MutedSoundsProvider._();

/// Sounds in use whose Android channel the user muted (docs/12 §4): the
/// default and Start sounds and every pending reminder's. Re-read with
/// `ref.invalidate` on resume.

final class MutedSoundsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// Sounds in use whose Android channel the user muted (docs/12 §4): the
  /// default and Start sounds and every pending reminder's. Re-read with
  /// `ref.invalidate` on resume.
  MutedSoundsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mutedSoundsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mutedSoundsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return mutedSounds(ref);
  }
}

String _$mutedSoundsHash() => r'6a2161c7eb1d812720b9a41911a7899e33b2373d';

/// The notification health panel's rows from the real OS state (docs/09
/// M6.5.8, 11 A0), recomputed whenever one of its inputs is re-read.

@ProviderFor(notificationHealthChecks)
final notificationHealthChecksProvider = NotificationHealthChecksProvider._();

/// The notification health panel's rows from the real OS state (docs/09
/// M6.5.8, 11 A0), recomputed whenever one of its inputs is re-read.

final class NotificationHealthChecksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HealthCheck>>,
          List<HealthCheck>,
          FutureOr<List<HealthCheck>>
        >
    with
        $FutureModifier<List<HealthCheck>>,
        $FutureProvider<List<HealthCheck>> {
  /// The notification health panel's rows from the real OS state (docs/09
  /// M6.5.8, 11 A0), recomputed whenever one of its inputs is re-read.
  NotificationHealthChecksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationHealthChecksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationHealthChecksHash();

  @$internal
  @override
  $FutureProviderElement<List<HealthCheck>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HealthCheck>> create(Ref ref) {
    return notificationHealthChecks(ref);
  }
}

String _$notificationHealthChecksHash() =>
    r'57d30a41e7e1bc2e425a3a65fa1550a6c58f241a';
