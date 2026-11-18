// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_panel_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Plan panel brought out over the grid while it is hidden (rules
/// §9.16): Esc, a click away or the pin end it. Not remembered.

@ProviderFor(PlanPanelOut)
final planPanelOutProvider = PlanPanelOutProvider._();

/// The Plan panel brought out over the grid while it is hidden (rules
/// §9.16): Esc, a click away or the pin end it. Not remembered.
final class PlanPanelOutProvider extends $NotifierProvider<PlanPanelOut, bool> {
  /// The Plan panel brought out over the grid while it is hidden (rules
  /// §9.16): Esc, a click away or the pin end it. Not remembered.
  PlanPanelOutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planPanelOutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planPanelOutHash();

  @$internal
  @override
  PlanPanelOut create() => PlanPanelOut();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$planPanelOutHash() => r'9af293ea87ebf2777088738ef7648b4b67427bd9';

/// The Plan panel brought out over the grid while it is hidden (rules
/// §9.16): Esc, a click away or the pin end it. Not remembered.

abstract class _$PlanPanelOut extends $Notifier<bool> {
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
