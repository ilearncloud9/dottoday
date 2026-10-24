// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_shift_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Imported events a shift never carries, even with "Move calendar events
/// too" on (docs/03 §3.2, docs/09 M7.6): their calendar won't take the
/// change back (read-only calendar, repeating or all-day event), so moving
/// them in bulk would leave Dottoday disagreeing with the real meeting.
///
/// Read synchronously and returns the stream (see `timelineData`).

@ProviderFor(readOnlyCalendarIds)
final readOnlyCalendarIdsProvider = ReadOnlyCalendarIdsProvider._();

/// Imported events a shift never carries, even with "Move calendar events
/// too" on (docs/03 §3.2, docs/09 M7.6): their calendar won't take the
/// change back (read-only calendar, repeating or all-day event), so moving
/// them in bulk would leave Dottoday disagreeing with the real meeting.
///
/// Read synchronously and returns the stream (see `timelineData`).

final class ReadOnlyCalendarIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  /// Imported events a shift never carries, even with "Move calendar events
  /// too" on (docs/03 §3.2, docs/09 M7.6): their calendar won't take the
  /// change back (read-only calendar, repeating or all-day event), so moving
  /// them in bulk would leave Dottoday disagreeing with the real meeting.
  ///
  /// Read synchronously and returns the stream (see `timelineData`).
  ReadOnlyCalendarIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readOnlyCalendarIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readOnlyCalendarIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return readOnlyCalendarIds(ref);
  }
}

String _$readOnlyCalendarIdsHash() =>
    r'6a8023e6312193cfe477710be6d31da1385336ba';
