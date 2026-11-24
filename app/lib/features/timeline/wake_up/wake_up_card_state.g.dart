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
/// `wakeUpCardDue`). Every platform (ED-456: tablets ring; the Mac and the
/// web open it on the first open after Wake Up), never in Minimal: there
/// the card is folded into a phone's Now ([wakeUpCardInNow]; owner,
/// E-R2-26 frame 4), so no card opens by itself (15 §10).

@ProviderFor(wakeUpCardDueNow)
final wakeUpCardDueNowProvider = WakeUpCardDueNowProvider._();

/// Today's key when the card should open by itself now, else null (15 §5,
/// `wakeUpCardDue`). Every platform (ED-456: tablets ring; the Mac and the
/// web open it on the first open after Wake Up), never in Minimal: there
/// the card is folded into a phone's Now ([wakeUpCardInNow]; owner,
/// E-R2-26 frame 4), so no card opens by itself (15 §10).

final class WakeUpCardDueNowProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Today's key when the card should open by itself now, else null (15 §5,
  /// `wakeUpCardDue`). Every platform (ED-456: tablets ring; the Mac and the
  /// web open it on the first open after Wake Up), never in Minimal: there
  /// the card is folded into a phone's Now ([wakeUpCardInNow]; owner,
  /// E-R2-26 frame 4), so no card opens by itself (15 §10).
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

String _$wakeUpCardDueNowHash() => r'33ea7dc0b953745430c92b796f90eaf7d3810355';

/// The card Minimal's Now shows in place of its body on a phone, else
/// null: the same once-a-day window as the card's own screen, until Start
/// the day or Later answers it (E-R2-26 frame 4, ED-329).

@ProviderFor(wakeUpCardInNow)
final wakeUpCardInNowProvider = WakeUpCardInNowProvider._();

/// The card Minimal's Now shows in place of its body on a phone, else
/// null: the same once-a-day window as the card's own screen, until Start
/// the day or Later answers it (E-R2-26 frame 4, ED-329).

final class WakeUpCardInNowProvider
    extends
        $FunctionalProvider<
          AsyncValue<WakeUpCardModel?>,
          WakeUpCardModel?,
          FutureOr<WakeUpCardModel?>
        >
    with $FutureModifier<WakeUpCardModel?>, $FutureProvider<WakeUpCardModel?> {
  /// The card Minimal's Now shows in place of its body on a phone, else
  /// null: the same once-a-day window as the card's own screen, until Start
  /// the day or Later answers it (E-R2-26 frame 4, ED-329).
  WakeUpCardInNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wakeUpCardInNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wakeUpCardInNowHash();

  @$internal
  @override
  $FutureProviderElement<WakeUpCardModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WakeUpCardModel?> create(Ref ref) {
    return wakeUpCardInNow(ref);
  }
}

String _$wakeUpCardInNowHash() => r'27f53a262307d7b827ec27799cdc8ddb78749eee';
