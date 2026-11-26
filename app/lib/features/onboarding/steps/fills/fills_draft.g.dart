// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fills_draft.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What is picked on "What fills your days?": kept while you go Back and
/// forth, as the prototype keeps it (`st.routines`, `st.custom`). Typed
/// ones stay as chips when unpicked. Every chip has its series id from
/// the start, so saving twice updates the same tasks.

@ProviderFor(FillsDraft)
final fillsDraftProvider = FillsDraftProvider._();

/// What is picked on "What fills your days?": kept while you go Back and
/// forth, as the prototype keeps it (`st.routines`, `st.custom`). Typed
/// ones stay as chips when unpicked. Every chip has its series id from
/// the start, so saving twice updates the same tasks.
final class FillsDraftProvider
    extends $NotifierProvider<FillsDraft, FillsDraftState> {
  /// What is picked on "What fills your days?": kept while you go Back and
  /// forth, as the prototype keeps it (`st.routines`, `st.custom`). Typed
  /// ones stay as chips when unpicked. Every chip has its series id from
  /// the start, so saving twice updates the same tasks.
  FillsDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fillsDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fillsDraftHash();

  @$internal
  @override
  FillsDraft create() => FillsDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FillsDraftState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FillsDraftState>(value),
    );
  }
}

String _$fillsDraftHash() => r'4ed372b2dc6c98c7b3392c82c419ae13d37ccb1c';

/// What is picked on "What fills your days?": kept while you go Back and
/// forth, as the prototype keeps it (`st.routines`, `st.custom`). Typed
/// ones stay as chips when unpicked. Every chip has its series id from
/// the start, so saving twice updates the same tasks.

abstract class _$FillsDraft extends $Notifier<FillsDraftState> {
  FillsDraftState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FillsDraftState, FillsDraftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FillsDraftState, FillsDraftState>,
              FillsDraftState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
