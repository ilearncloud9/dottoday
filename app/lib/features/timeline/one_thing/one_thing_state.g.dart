// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'one_thing_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today's dots still to do and the Inbox (owner, 2026-11-01). [mission]
/// caps each at five, as the morning mission offers (15 §8).

@ProviderFor(oneThingOffer)
final oneThingOfferProvider = OneThingOfferFamily._();

/// Today's dots still to do and the Inbox (owner, 2026-11-01). [mission]
/// caps each at five, as the morning mission offers (15 §8).

final class OneThingOfferProvider
    extends
        $FunctionalProvider<
          AsyncValue<OneThingOffer>,
          OneThingOffer,
          FutureOr<OneThingOffer>
        >
    with $FutureModifier<OneThingOffer>, $FutureProvider<OneThingOffer> {
  /// Today's dots still to do and the Inbox (owner, 2026-11-01). [mission]
  /// caps each at five, as the morning mission offers (15 §8).
  OneThingOfferProvider._({
    required OneThingOfferFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'oneThingOfferProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$oneThingOfferHash();

  @override
  String toString() {
    return r'oneThingOfferProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OneThingOffer> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OneThingOffer> create(Ref ref) {
    final argument = this.argument as bool;
    return oneThingOffer(ref, mission: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OneThingOfferProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$oneThingOfferHash() => r'63816913274d2fe5114723ea928df9edcf9505f8';

/// Today's dots still to do and the Inbox (owner, 2026-11-01). [mission]
/// caps each at five, as the morning mission offers (15 §8).

final class OneThingOfferFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OneThingOffer>, bool> {
  OneThingOfferFamily._()
    : super(
        retry: null,
        name: r'oneThingOfferProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Today's dots still to do and the Inbox (owner, 2026-11-01). [mission]
  /// caps each at five, as the morning mission offers (15 §8).

  OneThingOfferProvider call({required bool mission}) =>
      OneThingOfferProvider._(argument: mission, from: this);

  @override
  String toString() => r'oneThingOfferProvider';
}
