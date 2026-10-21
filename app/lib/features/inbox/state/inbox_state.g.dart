// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The picked filter chip; resets when the Inbox is left.

@ProviderFor(InboxFilterChoice)
final inboxFilterChoiceProvider = InboxFilterChoiceProvider._();

/// The picked filter chip; resets when the Inbox is left.
final class InboxFilterChoiceProvider
    extends $NotifierProvider<InboxFilterChoice, InboxFilter> {
  /// The picked filter chip; resets when the Inbox is left.
  InboxFilterChoiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxFilterChoiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxFilterChoiceHash();

  @$internal
  @override
  InboxFilterChoice create() => InboxFilterChoice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxFilter>(value),
    );
  }
}

String _$inboxFilterChoiceHash() => r'e3e79508fc81aa1c1b0f0974449e86b6bd736218';

/// The picked filter chip; resets when the Inbox is left.

abstract class _$InboxFilterChoice extends $Notifier<InboxFilter> {
  InboxFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InboxFilter, InboxFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InboxFilter, InboxFilter>,
              InboxFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The local date of today in the profile zone, read once (the Inbox
/// re-reads it when reopened).

@ProviderFor(inboxToday)
final inboxTodayProvider = InboxTodayProvider._();

/// The local date of today in the profile zone, read once (the Inbox
/// re-reads it when reopened).

final class InboxTodayProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, FutureOr<DateTime>>
    with $FutureModifier<DateTime>, $FutureProvider<DateTime> {
  /// The local date of today in the profile zone, read once (the Inbox
  /// re-reads it when reopened).
  InboxTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxTodayHash();

  @$internal
  @override
  $FutureProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime> create(Ref ref) {
    return inboxToday(ref);
  }
}

String _$inboxTodayHash() => r'd795312bfcd6daf82eb76b5f427c12441175b486';

/// What is left of [date] between Wake Up and Bedtime, live, for fitting
/// inbox items (docs/02 F3 "next free gap today, tomorrow morning").
/// Dependencies are read synchronously (see `timelineData`).

@ProviderFor(dayRoom)
final dayRoomProvider = DayRoomFamily._();

/// What is left of [date] between Wake Up and Bedtime, live, for fitting
/// inbox items (docs/02 F3 "next free gap today, tomorrow morning").
/// Dependencies are read synchronously (see `timelineData`).

final class DayRoomProvider
    extends $FunctionalProvider<AsyncValue<DayRoom>, DayRoom, Stream<DayRoom>>
    with $FutureModifier<DayRoom>, $StreamProvider<DayRoom> {
  /// What is left of [date] between Wake Up and Bedtime, live, for fitting
  /// inbox items (docs/02 F3 "next free gap today, tomorrow morning").
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

/// What is left of [date] between Wake Up and Bedtime, live, for fitting
/// inbox items (docs/02 F3 "next free gap today, tomorrow morning").
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

  /// What is left of [date] between Wake Up and Bedtime, live, for fitting
  /// inbox items (docs/02 F3 "next free gap today, tomorrow morning").
  /// Dependencies are read synchronously (see `timelineData`).

  DayRoomProvider call(DateTime date) =>
      DayRoomProvider._(argument: date, from: this);

  @override
  String toString() => r'dayRoomProvider';
}
