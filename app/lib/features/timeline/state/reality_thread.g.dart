// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reality_thread.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether Today's card shows the Reality thread (11 C3, docs/09 M11.2):
/// a view choice for this session, like the Week/Month switch.

@ProviderFor(RealityMode)
final realityModeProvider = RealityModeProvider._();

/// Whether Today's card shows the Reality thread (11 C3, docs/09 M11.2):
/// a view choice for this session, like the Week/Month switch.
final class RealityModeProvider extends $NotifierProvider<RealityMode, bool> {
  /// Whether Today's card shows the Reality thread (11 C3, docs/09 M11.2):
  /// a view choice for this session, like the Week/Month switch.
  RealityModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realityModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realityModeHash();

  @$internal
  @override
  RealityMode create() => RealityMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$realityModeHash() => r'6fb64826875c282c6233f8cdfbf36ea65abc9c13';

/// Whether Today's card shows the Reality thread (11 C3, docs/09 M11.2):
/// a view choice for this session, like the Week/Month switch.

abstract class _$RealityMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Insight strips put away with OK, by occurrence id, this session.

@ProviderFor(DismissedInsights)
final dismissedInsightsProvider = DismissedInsightsProvider._();

/// Insight strips put away with OK, by occurrence id, this session.
final class DismissedInsightsProvider
    extends $NotifierProvider<DismissedInsights, Set<String>> {
  /// Insight strips put away with OK, by occurrence id, this session.
  DismissedInsightsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dismissedInsightsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dismissedInsightsHash();

  @$internal
  @override
  DismissedInsights create() => DismissedInsights();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$dismissedInsightsHash() => r'bff1e334f9927c5e10f9e60aa39c699b501551cb';

/// Insight strips put away with OK, by occurrence id, this session.

abstract class _$DismissedInsights extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
