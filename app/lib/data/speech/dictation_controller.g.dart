// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs one dictation at a time (ADR-0014): starts the recognizer, feeds
/// its events through [Dictation] with the injected clock, ticks for
/// pauses in Brain dump, and stops on request. Starting for another field
/// stops the first. Holds no text beyond the session; nothing is logged.

@ProviderFor(DictationController)
final dictationControllerProvider = DictationControllerProvider._();

/// Runs one dictation at a time (ADR-0014): starts the recognizer, feeds
/// its events through [Dictation] with the injected clock, ticks for
/// pauses in Brain dump, and stops on request. Starting for another field
/// stops the first. Holds no text beyond the session; nothing is logged.
final class DictationControllerProvider
    extends $NotifierProvider<DictationController, DictationState> {
  /// Runs one dictation at a time (ADR-0014): starts the recognizer, feeds
  /// its events through [Dictation] with the injected clock, ticks for
  /// pauses in Brain dump, and stops on request. Starting for another field
  /// stops the first. Holds no text beyond the session; nothing is logged.
  DictationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictationControllerHash();

  @$internal
  @override
  DictationController create() => DictationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DictationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DictationState>(value),
    );
  }
}

String _$dictationControllerHash() =>
    r'2813194814c01b30597b83686ae6c5c4c056e6e1';

/// Runs one dictation at a time (ADR-0014): starts the recognizer, feeds
/// its events through [Dictation] with the injected clock, ticks for
/// pauses in Brain dump, and stops on request. Starting for another field
/// stops the first. Holds no text beyond the session; nothing is logged.

abstract class _$DictationController extends $Notifier<DictationState> {
  DictationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DictationState, DictationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DictationState, DictationState>,
              DictationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
