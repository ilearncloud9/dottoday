// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_events.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(systemEvents)
final systemEventsProvider = SystemEventsProvider._();

final class SystemEventsProvider
    extends $FunctionalProvider<SystemEvents, SystemEvents, SystemEvents>
    with $Provider<SystemEvents> {
  SystemEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemEventsHash();

  @$internal
  @override
  $ProviderElement<SystemEvents> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SystemEvents create(Ref ref) {
    return systemEvents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SystemEvents value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SystemEvents>(value),
    );
  }
}

String _$systemEventsHash() => r'0e8d542600d71b950b08cae121d207d080574b36';
