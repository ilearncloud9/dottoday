// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_moves.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Imported events the calendar moved since launch, by occurrence id,
/// until Today's "moved · Rebalance?" prompt is used or put away
/// (docs/09 M11.1b). Session-only, like Today's other prompts: a
/// suggestion is not worth syncing.

@ProviderFor(CalendarMoves)
final calendarMovesProvider = CalendarMovesProvider._();

/// Imported events the calendar moved since launch, by occurrence id,
/// until Today's "moved · Rebalance?" prompt is used or put away
/// (docs/09 M11.1b). Session-only, like Today's other prompts: a
/// suggestion is not worth syncing.
final class CalendarMovesProvider
    extends $NotifierProvider<CalendarMoves, Map<String, CalendarMove>> {
  /// Imported events the calendar moved since launch, by occurrence id,
  /// until Today's "moved · Rebalance?" prompt is used or put away
  /// (docs/09 M11.1b). Session-only, like Today's other prompts: a
  /// suggestion is not worth syncing.
  CalendarMovesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarMovesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarMovesHash();

  @$internal
  @override
  CalendarMoves create() => CalendarMoves();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, CalendarMove> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, CalendarMove>>(value),
    );
  }
}

String _$calendarMovesHash() => r'8e1d59162684ac453acab7548165a6d9955da511';

/// Imported events the calendar moved since launch, by occurrence id,
/// until Today's "moved · Rebalance?" prompt is used or put away
/// (docs/09 M11.1b). Session-only, like Today's other prompts: a
/// suggestion is not worth syncing.

abstract class _$CalendarMoves extends $Notifier<Map<String, CalendarMove>> {
  Map<String, CalendarMove> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<Map<String, CalendarMove>, Map<String, CalendarMove>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, CalendarMove>, Map<String, CalendarMove>>,
              Map<String, CalendarMove>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
