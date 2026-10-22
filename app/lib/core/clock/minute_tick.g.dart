// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minute_tick.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Now", emitted immediately and then on every minute boundary, so the
/// now-line moves once per minute (docs/03 §3.1) without a busy timer.

@ProviderFor(minuteTick)
final minuteTickProvider = MinuteTickProvider._();

/// "Now", emitted immediately and then on every minute boundary, so the
/// now-line moves once per minute (docs/03 §3.1) without a busy timer.

final class MinuteTickProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  /// "Now", emitted immediately and then on every minute boundary, so the
  /// now-line moves once per minute (docs/03 §3.1) without a busy timer.
  MinuteTickProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'minuteTickProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$minuteTickHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return minuteTick(ref);
  }
}

String _$minuteTickHash() => r'1c6c50f9cc2af9aa369dffb07367c98d8b1e6a7d';
