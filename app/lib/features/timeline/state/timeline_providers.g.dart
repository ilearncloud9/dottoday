// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$todayDateHash() => r'196739fb7fb57c61ae77ad5a3776363cfc1d8d09';

/// The live contents of [date] (year/month/day) for the local profile.
///
/// Stream providers here read their dependencies synchronously and return
/// the stream: an `async*` body starts on first listen, by which time a
/// pager page may already be disposed and its ref unusable (Riverpod 3).

@ProviderFor(timelineData)
final timelineDataProvider = TimelineDataFamily._();

/// The live contents of [date] (year/month/day) for the local profile.
///
/// Stream providers here read their dependencies synchronously and return
/// the stream: an `async*` body starts on first listen, by which time a
/// pager page may already be disposed and its ref unusable (Riverpod 3).

final class TimelineDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<TimelineData>,
          TimelineData,
          Stream<TimelineData>
        >
    with $FutureModifier<TimelineData>, $StreamProvider<TimelineData> {
  /// The live contents of [date] (year/month/day) for the local profile.
  ///
  /// Stream providers here read their dependencies synchronously and return
  /// the stream: an `async*` body starts on first listen, by which time a
  /// pager page may already be disposed and its ref unusable (Riverpod 3).
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

String _$timelineDataHash() => r'b856e987e9a6de5dd11903fef316afd0a678a9b3';

/// The live contents of [date] (year/month/day) for the local profile.
///
/// Stream providers here read their dependencies synchronously and return
/// the stream: an `async*` body starts on first listen, by which time a
/// pager page may already be disposed and its ref unusable (Riverpod 3).

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
  ///
  /// Stream providers here read their dependencies synchronously and return
  /// the stream: an `async*` body starts on first listen, by which time a
  /// pager page may already be disposed and its ref unusable (Riverpod 3).

  TimelineDataProvider call(DateTime date) =>
      TimelineDataProvider._(argument: date, from: this);

  @override
  String toString() => r'timelineDataProvider';
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
    r'7e63ba2589346a74b8213a824fc6de8d47665000';

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

/// The first step still to do of each task on [date] whose steps aren't
/// started (Smallest step, 11 B2, docs/09 M10.6), by occurrence id.

@ProviderFor(dayFirstSteps)
final dayFirstStepsProvider = DayFirstStepsFamily._();

/// The first step still to do of each task on [date] whose steps aren't
/// started (Smallest step, 11 B2, docs/09 M10.6), by occurrence id.

final class DayFirstStepsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Subtask>>,
          Map<String, Subtask>,
          Stream<Map<String, Subtask>>
        >
    with
        $FutureModifier<Map<String, Subtask>>,
        $StreamProvider<Map<String, Subtask>> {
  /// The first step still to do of each task on [date] whose steps aren't
  /// started (Smallest step, 11 B2, docs/09 M10.6), by occurrence id.
  DayFirstStepsProvider._({
    required DayFirstStepsFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'dayFirstStepsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayFirstStepsHash();

  @override
  String toString() {
    return r'dayFirstStepsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, Subtask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, Subtask>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return dayFirstSteps(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayFirstStepsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayFirstStepsHash() => r'f1e100cd790242e00abeb0e458e4d2789733e7a1';

/// The first step still to do of each task on [date] whose steps aren't
/// started (Smallest step, 11 B2, docs/09 M10.6), by occurrence id.

final class DayFirstStepsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, Subtask>>, DateTime> {
  DayFirstStepsFamily._()
    : super(
        retry: null,
        name: r'dayFirstStepsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The first step still to do of each task on [date] whose steps aren't
  /// started (Smallest step, 11 B2, docs/09 M10.6), by occurrence id.

  DayFirstStepsProvider call(DateTime date) =>
      DayFirstStepsProvider._(argument: date, from: this);

  @override
  String toString() => r'dayFirstStepsProvider';
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

String _$seriesAlertsHash() => r'a4ca9504e43bbad15604d4d8fe162ea74a89db67';
