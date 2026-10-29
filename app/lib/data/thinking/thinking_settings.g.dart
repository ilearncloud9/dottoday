// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thinking_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(thinkingSettingsOpener)
final thinkingSettingsOpenerProvider = ThinkingSettingsOpenerProvider._();

final class ThinkingSettingsOpenerProvider
    extends
        $FunctionalProvider<
          ThinkingSettingsOpener,
          ThinkingSettingsOpener,
          ThinkingSettingsOpener
        >
    with $Provider<ThinkingSettingsOpener> {
  ThinkingSettingsOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thinkingSettingsOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thinkingSettingsOpenerHash();

  @$internal
  @override
  $ProviderElement<ThinkingSettingsOpener> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ThinkingSettingsOpener create(Ref ref) {
    return thinkingSettingsOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThinkingSettingsOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThinkingSettingsOpener>(value),
    );
  }
}

String _$thinkingSettingsOpenerHash() =>
    r'c6c1e604aceb74271e1340a0bd2ada504982ba98';
