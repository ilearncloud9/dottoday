// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wake_up_card_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today's Wake Up card (docs/15 §5, M17.3).

@ProviderFor(wakeUpCard)
final wakeUpCardProvider = WakeUpCardProvider._();

/// Today's Wake Up card (docs/15 §5, M17.3).

final class WakeUpCardProvider
    extends
        $FunctionalProvider<
          AsyncValue<WakeUpCardModel>,
          WakeUpCardModel,
          FutureOr<WakeUpCardModel>
        >
    with $FutureModifier<WakeUpCardModel>, $FutureProvider<WakeUpCardModel> {
  /// Today's Wake Up card (docs/15 §5, M17.3).
  WakeUpCardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wakeUpCardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wakeUpCardHash();

  @$internal
  @override
  $FutureProviderElement<WakeUpCardModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WakeUpCardModel> create(Ref ref) {
    return wakeUpCard(ref);
  }
}

String _$wakeUpCardHash() => r'5a65b38922d163bfd5a59634c9b449ed12fde32c';

/// Today's key when the card should open by itself now, else null (15 §5,
/// `wakeUpCardDue`). Phones only. Minimal mode opens it only after "I'm
/// up" (15 §10): an unexpected full-screen route is what it avoids.

@ProviderFor(wakeUpCardDueNow)
final wakeUpCardDueNowProvider = WakeUpCardDueNowProvider._();

/// Today's key when the card should open by itself now, else null (15 §5,
/// `wakeUpCardDue`). Phones only. Minimal mode opens it only after "I'm
/// up" (15 §10): an unexpected full-screen route is what it avoids.

final class WakeUpCardDueNowProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Today's key when the card should open by itself now, else null (15 §5,
  /// `wakeUpCardDue`). Phones only. Minimal mode opens it only after "I'm
  /// up" (15 §10): an unexpected full-screen route is what it avoids.
  WakeUpCardDueNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wakeUpCardDueNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wakeUpCardDueNowHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return wakeUpCardDueNow(ref);
  }
}

String _$wakeUpCardDueNowHash() => r'1b14e7478b95328f559d86c57886ab14fd007520';
