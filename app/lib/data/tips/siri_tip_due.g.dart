// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siri_tip_due.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether Today's one-time Siri card is due (docs/09 M14.3,
/// [showsSiriTip]). Counting starts the first time Today asks after
/// onboarding finished (`tip_siri_armed_at` in `local_meta`, this device
/// only), so onboarding's starter tasks don't count; any way of adding
/// (Add, Quick Add, a share, Siri) does — it reads the rows, not a flow.

@ProviderFor(siriTipDue)
final siriTipDueProvider = SiriTipDueProvider._();

/// Whether Today's one-time Siri card is due (docs/09 M14.3,
/// [showsSiriTip]). Counting starts the first time Today asks after
/// onboarding finished (`tip_siri_armed_at` in `local_meta`, this device
/// only), so onboarding's starter tasks don't count; any way of adding
/// (Add, Quick Add, a share, Siri) does — it reads the rows, not a flow.

final class SiriTipDueProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether Today's one-time Siri card is due (docs/09 M14.3,
  /// [showsSiriTip]). Counting starts the first time Today asks after
  /// onboarding finished (`tip_siri_armed_at` in `local_meta`, this device
  /// only), so onboarding's starter tasks don't count; any way of adding
  /// (Add, Quick Add, a share, Siri) does — it reads the rows, not a flow.
  SiriTipDueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siriTipDueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siriTipDueHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return siriTipDue(ref);
  }
}

String _$siriTipDueHash() => r'28fedd64c433b1677c034d5d72d79b41bfbb7c96';
