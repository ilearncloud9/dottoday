// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's on-device recognizer (ADR-0014): the method channel on
/// iOS, macOS and Android, the Web Speech API (on-device mode) in Chrome.

@ProviderFor(speechRecognizer)
final speechRecognizerProvider = SpeechRecognizerProvider._();

/// The platform's on-device recognizer (ADR-0014): the method channel on
/// iOS, macOS and Android, the Web Speech API (on-device mode) in Chrome.

final class SpeechRecognizerProvider
    extends
        $FunctionalProvider<
          SpeechRecognizer,
          SpeechRecognizer,
          SpeechRecognizer
        >
    with $Provider<SpeechRecognizer> {
  /// The platform's on-device recognizer (ADR-0014): the method channel on
  /// iOS, macOS and Android, the Web Speech API (on-device mode) in Chrome.
  SpeechRecognizerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechRecognizerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechRecognizerHash();

  @$internal
  @override
  $ProviderElement<SpeechRecognizer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpeechRecognizer create(Ref ref) {
    return speechRecognizer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechRecognizer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechRecognizer>(value),
    );
  }
}

String _$speechRecognizerHash() => r'147a61ed2cf0cbcd649b700ef764ec135bcb36a6';

/// Whether dictation runs for [localeTag] here; the mic shows only when
/// this is not [SpeechAvailability.unavailable] (D2). Re-read on resume:
/// the microphone may have been switched on in Settings.

@ProviderFor(speechAvailability)
final speechAvailabilityProvider = SpeechAvailabilityFamily._();

/// Whether dictation runs for [localeTag] here; the mic shows only when
/// this is not [SpeechAvailability.unavailable] (D2). Re-read on resume:
/// the microphone may have been switched on in Settings.

final class SpeechAvailabilityProvider
    extends
        $FunctionalProvider<
          AsyncValue<SpeechAvailability>,
          SpeechAvailability,
          FutureOr<SpeechAvailability>
        >
    with
        $FutureModifier<SpeechAvailability>,
        $FutureProvider<SpeechAvailability> {
  /// Whether dictation runs for [localeTag] here; the mic shows only when
  /// this is not [SpeechAvailability.unavailable] (D2). Re-read on resume:
  /// the microphone may have been switched on in Settings.
  SpeechAvailabilityProvider._({
    required SpeechAvailabilityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'speechAvailabilityProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$speechAvailabilityHash();

  @override
  String toString() {
    return r'speechAvailabilityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SpeechAvailability> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SpeechAvailability> create(Ref ref) {
    final argument = this.argument as String;
    return speechAvailability(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SpeechAvailabilityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$speechAvailabilityHash() =>
    r'd72c1eecc835048f099e1e473510dd62ff06ab4c';

/// Whether dictation runs for [localeTag] here; the mic shows only when
/// this is not [SpeechAvailability.unavailable] (D2). Re-read on resume:
/// the microphone may have been switched on in Settings.

final class SpeechAvailabilityFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SpeechAvailability>, String> {
  SpeechAvailabilityFamily._()
    : super(
        retry: null,
        name: r'speechAvailabilityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Whether dictation runs for [localeTag] here; the mic shows only when
  /// this is not [SpeechAvailability.unavailable] (D2). Re-read on resume:
  /// the microphone may have been switched on in Settings.

  SpeechAvailabilityProvider call(String localeTag) =>
      SpeechAvailabilityProvider._(argument: localeTag, from: this);

  @override
  String toString() => r'speechAvailabilityProvider';
}
