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

/// The Mac/web Sort menu (`A-mac-inbox`); resets when the Inbox is left.

@ProviderFor(InboxSortChoice)
final inboxSortChoiceProvider = InboxSortChoiceProvider._();

/// The Mac/web Sort menu (`A-mac-inbox`); resets when the Inbox is left.
final class InboxSortChoiceProvider
    extends $NotifierProvider<InboxSortChoice, InboxSort> {
  /// The Mac/web Sort menu (`A-mac-inbox`); resets when the Inbox is left.
  InboxSortChoiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxSortChoiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxSortChoiceHash();

  @$internal
  @override
  InboxSortChoice create() => InboxSortChoice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxSort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxSort>(value),
    );
  }
}

String _$inboxSortChoiceHash() => r'18c21d3738ec3b9a13d85166032e08714309527e';

/// The Mac/web Sort menu (`A-mac-inbox`); resets when the Inbox is left.

abstract class _$InboxSortChoice extends $Notifier<InboxSort> {
  InboxSort build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InboxSort, InboxSort>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InboxSort, InboxSort>,
              InboxSort,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The room left on [today] (from now) and the six days after it, live,
/// for "Fits Thu 12:00" and Auto-plan the week (M3e.2).

@ProviderFor(inboxWeekRooms)
final inboxWeekRoomsProvider = InboxWeekRoomsFamily._();

/// The room left on [today] (from now) and the six days after it, live,
/// for "Fits Thu 12:00" and Auto-plan the week (M3e.2).

final class InboxWeekRoomsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DayRoom>>,
          List<DayRoom>,
          FutureOr<List<DayRoom>>
        >
    with $FutureModifier<List<DayRoom>>, $FutureProvider<List<DayRoom>> {
  /// The room left on [today] (from now) and the six days after it, live,
  /// for "Fits Thu 12:00" and Auto-plan the week (M3e.2).
  InboxWeekRoomsProvider._({
    required InboxWeekRoomsFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'inboxWeekRoomsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inboxWeekRoomsHash();

  @override
  String toString() {
    return r'inboxWeekRoomsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DayRoom>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DayRoom>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return inboxWeekRooms(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InboxWeekRoomsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxWeekRoomsHash() => r'fe5567975504baddcbaf7d93b5b01ddf0d80d449';

/// The room left on [today] (from now) and the six days after it, live,
/// for "Fits Thu 12:00" and Auto-plan the week (M3e.2).

final class InboxWeekRoomsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DayRoom>>, DateTime> {
  InboxWeekRoomsFamily._()
    : super(
        retry: null,
        name: r'inboxWeekRoomsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The room left on [today] (from now) and the six days after it, live,
  /// for "Fits Thu 12:00" and Auto-plan the week (M3e.2).

  InboxWeekRoomsProvider call(DateTime today) =>
      InboxWeekRoomsProvider._(argument: today, from: this);

  @override
  String toString() => r'inboxWeekRoomsProvider';
}
