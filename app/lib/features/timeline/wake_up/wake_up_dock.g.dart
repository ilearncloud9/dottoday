// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wake_up_dock.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the Wake Up card is docked beside Today (E-R2-19-B "iPad · the
/// card docks beside Today"; every platform from the expanded width,
/// ED-456). Opened by Today's gate or by the card's route; × and Later
/// close it.

@ProviderFor(WakeUpDocked)
final wakeUpDockedProvider = WakeUpDockedProvider._();

/// Whether the Wake Up card is docked beside Today (E-R2-19-B "iPad · the
/// card docks beside Today"; every platform from the expanded width,
/// ED-456). Opened by Today's gate or by the card's route; × and Later
/// close it.
final class WakeUpDockedProvider extends $NotifierProvider<WakeUpDocked, bool> {
  /// Whether the Wake Up card is docked beside Today (E-R2-19-B "iPad · the
  /// card docks beside Today"; every platform from the expanded width,
  /// ED-456). Opened by Today's gate or by the card's route; × and Later
  /// close it.
  WakeUpDockedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wakeUpDockedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wakeUpDockedHash();

  @$internal
  @override
  WakeUpDocked create() => WakeUpDocked();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$wakeUpDockedHash() => r'ca78acd96837f8f30331d8be414096f85137721e';

/// Whether the Wake Up card is docked beside Today (E-R2-19-B "iPad · the
/// card docks beside Today"; every platform from the expanded width,
/// ED-456). Opened by Today's gate or by the card's route; × and Later
/// close it.

abstract class _$WakeUpDocked extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
