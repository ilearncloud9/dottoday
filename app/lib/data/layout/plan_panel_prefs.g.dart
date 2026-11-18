// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_panel_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [PlanPanelPrefs], read once and written on each change.

@ProviderFor(PlanPanel)
final planPanelProvider = PlanPanelProvider._();

/// [PlanPanelPrefs], read once and written on each change.
final class PlanPanelProvider
    extends $AsyncNotifierProvider<PlanPanel, PlanPanelPrefs> {
  /// [PlanPanelPrefs], read once and written on each change.
  PlanPanelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planPanelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planPanelHash();

  @$internal
  @override
  PlanPanel create() => PlanPanel();
}

String _$planPanelHash() => r'ae107886b056d466bd67f7177b83a18b1c9df5df';

/// [PlanPanelPrefs], read once and written on each change.

abstract class _$PlanPanel extends $AsyncNotifier<PlanPanelPrefs> {
  FutureOr<PlanPanelPrefs> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PlanPanelPrefs>, PlanPanelPrefs>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PlanPanelPrefs>, PlanPanelPrefs>,
              AsyncValue<PlanPanelPrefs>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
