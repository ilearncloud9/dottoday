// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hint_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's hint records by hint (docs/14 §6 `reveal_hints`).

@ProviderFor(revealHints)
final revealHintsProvider = RevealHintsProvider._();

/// The user's hint records by hint (docs/14 §6 `reveal_hints`).

final class RevealHintsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<HintId, RevealHint>>,
          Map<HintId, RevealHint>,
          Stream<Map<HintId, RevealHint>>
        >
    with
        $FutureModifier<Map<HintId, RevealHint>>,
        $StreamProvider<Map<HintId, RevealHint>> {
  /// The user's hint records by hint (docs/14 §6 `reveal_hints`).
  RevealHintsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'revealHintsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$revealHintsHash();

  @$internal
  @override
  $StreamProviderElement<Map<HintId, RevealHint>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<HintId, RevealHint>> create(Ref ref) {
    return revealHints(ref);
  }
}

String _$revealHintsHash() => r'ad448856c27f422e47abff405b35b366b8d1c457';
