// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_return.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the phones' Settings goes back to (ED-238: "Back and Close return
/// to the screen the user came from"): the address the "Settings and
/// account" button was pressed on; null opens Today.

@ProviderFor(SettingsReturn)
final settingsReturnProvider = SettingsReturnProvider._();

/// Where the phones' Settings goes back to (ED-238: "Back and Close return
/// to the screen the user came from"): the address the "Settings and
/// account" button was pressed on; null opens Today.
final class SettingsReturnProvider
    extends $NotifierProvider<SettingsReturn, String?> {
  /// Where the phones' Settings goes back to (ED-238: "Back and Close return
  /// to the screen the user came from"): the address the "Settings and
  /// account" button was pressed on; null opens Today.
  SettingsReturnProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsReturnProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsReturnHash();

  @$internal
  @override
  SettingsReturn create() => SettingsReturn();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$settingsReturnHash() => r'5de453a9bc63f68a98ecb5694e636f3f013e64bc';

/// Where the phones' Settings goes back to (ED-238: "Back and Close return
/// to the screen the user came from"): the address the "Settings and
/// account" button was pressed on; null opens Today.

abstract class _$SettingsReturn extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
