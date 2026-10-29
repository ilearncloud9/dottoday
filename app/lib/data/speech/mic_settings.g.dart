// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mic_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether Dottoday shows its own words before the OS asks for the
/// microphone (D5): Android's dialog has no usage text of its own; iOS
/// and macOS show Info.plist's. Read here so widgets never check the
/// platform.

@ProviderFor(micNeedsRationale)
final micNeedsRationaleProvider = MicNeedsRationaleProvider._();

/// Whether Dottoday shows its own words before the OS asks for the
/// microphone (D5): Android's dialog has no usage text of its own; iOS
/// and macOS show Info.plist's. Read here so widgets never check the
/// platform.

final class MicNeedsRationaleProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether Dottoday shows its own words before the OS asks for the
  /// microphone (D5): Android's dialog has no usage text of its own; iOS
  /// and macOS show Info.plist's. Read here so widgets never check the
  /// platform.
  MicNeedsRationaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'micNeedsRationaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$micNeedsRationaleHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return micNeedsRationale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$micNeedsRationaleHash() => r'89165f5113795524f838dec56a9e2db84aaa42bc';

@ProviderFor(micSettingsOpener)
final micSettingsOpenerProvider = MicSettingsOpenerProvider._();

final class MicSettingsOpenerProvider
    extends
        $FunctionalProvider<
          MicSettingsOpener,
          MicSettingsOpener,
          MicSettingsOpener
        >
    with $Provider<MicSettingsOpener> {
  MicSettingsOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'micSettingsOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$micSettingsOpenerHash();

  @$internal
  @override
  $ProviderElement<MicSettingsOpener> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MicSettingsOpener create(Ref ref) {
    return micSettingsOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MicSettingsOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MicSettingsOpener>(value),
    );
  }
}

String _$micSettingsOpenerHash() => r'e6fe89ced544ae8af71488fe49422c0adfc7e8a5';
