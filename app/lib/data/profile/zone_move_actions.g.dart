// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_move_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The zone the device moved to, when it isn't the one the person plans
/// in (docs/07 travelling, docs/09 M5.9): what the banner offers. Null
/// when they match, while either is loading, or for a zone the tz
/// database doesn't know.

@ProviderFor(zoneMoveOffer)
final zoneMoveOfferProvider = ZoneMoveOfferProvider._();

/// The zone the device moved to, when it isn't the one the person plans
/// in (docs/07 travelling, docs/09 M5.9): what the banner offers. Null
/// when they match, while either is loading, or for a zone the tz
/// database doesn't know.

final class ZoneMoveOfferProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The zone the device moved to, when it isn't the one the person plans
  /// in (docs/07 travelling, docs/09 M5.9): what the banner offers. Null
  /// when they match, while either is loading, or for a zone the tz
  /// database doesn't know.
  ZoneMoveOfferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zoneMoveOfferProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zoneMoveOfferHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return zoneMoveOffer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$zoneMoveOfferHash() => r'6545c87a6c0113eb401f751e17296497ea0492c4';
