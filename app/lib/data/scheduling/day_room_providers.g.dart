// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_room_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What is left of [date] between Wake Up and Wind Down, live, for fitting
/// inbox items (docs/02 F3 "next free gap today, tomorrow morning") and
/// for picking a time in Add (M3c.2). Shared by both features.
/// Dependencies are read synchronously (see `timelineData`).

@ProviderFor(dayRoom)
final dayRoomProvider = DayRoomFamily._();

/// What is left of [date] between Wake Up and Wind Down, live, for fitting
/// inbox items (docs/02 F3 "next free gap today, tomorrow morning") and
/// for picking a time in Add (M3c.2). Shared by both features.
/// Dependencies are read synchronously (see `timelineData`).

final class DayRoomProvider
    extends $FunctionalProvider<AsyncValue<DayRoom>, DayRoom, Stream<DayRoom>>
    with $FutureModifier<DayRoom>, $StreamProvider<DayRoom> {
  /// What is left of [date] between Wake Up and Wind Down, live, for fitting
  /// inbox items (docs/02 F3 "next free gap today, tomorrow morning") and
  /// for picking a time in Add (M3c.2). Shared by both features.
  /// Dependencies are read synchronously (see `timelineData`).
  DayRoomProvider._({
    required DayRoomFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'dayRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayRoomHash();

  @override
  String toString() {
    return r'dayRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DayRoom> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DayRoom> create(Ref ref) {
    final argument = this.argument as DateTime;
    return dayRoom(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayRoomProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayRoomHash() => r'539500b6e291e8dad28a1c961485cbbeb3b67295';

/// What is left of [date] between Wake Up and Wind Down, live, for fitting
/// inbox items (docs/02 F3 "next free gap today, tomorrow morning") and
/// for picking a time in Add (M3c.2). Shared by both features.
/// Dependencies are read synchronously (see `timelineData`).

final class DayRoomFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DayRoom>, DateTime> {
  DayRoomFamily._()
    : super(
        retry: null,
        name: r'dayRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What is left of [date] between Wake Up and Wind Down, live, for fitting
  /// inbox items (docs/02 F3 "next free gap today, tomorrow morning") and
  /// for picking a time in Add (M3c.2). Shared by both features.
  /// Dependencies are read synchronously (see `timelineData`).

  DayRoomProvider call(DateTime date) =>
      DayRoomProvider._(argument: date, from: this);

  @override
  String toString() => r'dayRoomProvider';
}
