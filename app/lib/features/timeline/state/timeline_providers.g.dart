// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_providers.dart';

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

/// Today's local calendar date in the profile's zone; changes at midnight.

@ProviderFor(todayDate)
final todayDateProvider = TodayDateProvider._();

/// Today's local calendar date in the profile's zone; changes at midnight.

final class TodayDateProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, FutureOr<DateTime>>
    with $FutureModifier<DateTime>, $FutureProvider<DateTime> {
  /// Today's local calendar date in the profile's zone; changes at midnight.
  TodayDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayDateHash();

  @$internal
  @override
  $FutureProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime> create(Ref ref) {
    return todayDate(ref);
  }
}

String _$todayDateHash() => r'b8f272a4818cc95f20649f2827f9ce0026e87e6f';

/// The live contents of [date] (year/month/day) for the local profile.

@ProviderFor(timelineData)
final timelineDataProvider = TimelineDataFamily._();

/// The live contents of [date] (year/month/day) for the local profile.

final class TimelineDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<TimelineData>,
          TimelineData,
          Stream<TimelineData>
        >
    with $FutureModifier<TimelineData>, $StreamProvider<TimelineData> {
  /// The live contents of [date] (year/month/day) for the local profile.
  TimelineDataProvider._({
    required TimelineDataFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'timelineDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$timelineDataHash();

  @override
  String toString() {
    return r'timelineDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<TimelineData> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TimelineData> create(Ref ref) {
    final argument = this.argument as DateTime;
    return timelineData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TimelineDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$timelineDataHash() => r'f31d1251a3ff902d9037fb0863dd0883a7ee131b';

/// The live contents of [date] (year/month/day) for the local profile.

final class TimelineDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TimelineData>, DateTime> {
  TimelineDataFamily._()
    : super(
        retry: null,
        name: r'timelineDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The live contents of [date] (year/month/day) for the local profile.

  TimelineDataProvider call(DateTime date) =>
      TimelineDataProvider._(argument: date, from: this);

  @override
  String toString() => r'timelineDataProvider';
}

/// Which collapsed outside-hours zones the user has opened this session.

@ProviderFor(OutsideHours)
final outsideHoursProvider = OutsideHoursProvider._();

/// Which collapsed outside-hours zones the user has opened this session.
final class OutsideHoursProvider
    extends $NotifierProvider<OutsideHours, ({bool after, bool before})> {
  /// Which collapsed outside-hours zones the user has opened this session.
  OutsideHoursProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outsideHoursProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outsideHoursHash();

  @$internal
  @override
  OutsideHours create() => OutsideHours();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({bool after, bool before}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({bool after, bool before})>(value),
    );
  }
}

String _$outsideHoursHash() => r'68b96e32dbf84713e3cf8ffd9c9348fc513584c2';

/// Which collapsed outside-hours zones the user has opened this session.

abstract class _$OutsideHours extends $Notifier<({bool after, bool before})> {
  ({bool after, bool before}) build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<({bool after, bool before}), ({bool after, bool before})>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({bool after, bool before}),
                ({bool after, bool before})
              >,
              ({bool after, bool before}),
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Subtask progress per occurrence of [date], for the progress rings (R-09:
/// counts are per occurrence, never per series).

@ProviderFor(daySubtaskProgress)
final daySubtaskProgressProvider = DaySubtaskProgressFamily._();

/// Subtask progress per occurrence of [date], for the progress rings (R-09:
/// counts are per occurrence, never per series).

final class DaySubtaskProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, ({int done, int total})>>,
          Map<String, ({int done, int total})>,
          Stream<Map<String, ({int done, int total})>>
        >
    with
        $FutureModifier<Map<String, ({int done, int total})>>,
        $StreamProvider<Map<String, ({int done, int total})>> {
  /// Subtask progress per occurrence of [date], for the progress rings (R-09:
  /// counts are per occurrence, never per series).
  DaySubtaskProgressProvider._({
    required DaySubtaskProgressFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'daySubtaskProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$daySubtaskProgressHash();

  @override
  String toString() {
    return r'daySubtaskProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, ({int done, int total})>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, ({int done, int total})>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return daySubtaskProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DaySubtaskProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$daySubtaskProgressHash() =>
    r'9e827ab163b30adb94b6515218c957a3674d1248';

/// Subtask progress per occurrence of [date], for the progress rings (R-09:
/// counts are per occurrence, never per series).

final class DaySubtaskProgressFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<String, ({int done, int total})>>,
          DateTime
        > {
  DaySubtaskProgressFamily._()
    : super(
        retry: null,
        name: r'daySubtaskProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Subtask progress per occurrence of [date], for the progress rings (R-09:
  /// counts are per occurrence, never per series).

  DaySubtaskProgressProvider call(DateTime date) =>
      DaySubtaskProgressProvider._(argument: date, from: this);

  @override
  String toString() => r'daySubtaskProgressProvider';
}

/// Alerts of each active series, inherited by occurrences without their
/// own (`alerts` null, docs/05).

@ProviderFor(seriesAlerts)
final seriesAlertsProvider = SeriesAlertsProvider._();

/// Alerts of each active series, inherited by occurrences without their
/// own (`alerts` null, docs/05).

final class SeriesAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<Alert>>>,
          Map<String, List<Alert>>,
          Stream<Map<String, List<Alert>>>
        >
    with
        $FutureModifier<Map<String, List<Alert>>>,
        $StreamProvider<Map<String, List<Alert>>> {
  /// Alerts of each active series, inherited by occurrences without their
  /// own (`alerts` null, docs/05).
  SeriesAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seriesAlertsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seriesAlertsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, List<Alert>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, List<Alert>>> create(Ref ref) {
    return seriesAlerts(ref);
  }
}

String _$seriesAlertsHash() => r'e20a7ac5b017378d27419e5c711af314dc87b951';
