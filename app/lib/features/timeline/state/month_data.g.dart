// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Timed tasks of [month] (year/month) bucketed by local start date in the
/// profile zone, for the month dots (docs/10 §3 `MonthGrid`). One range
/// query per month instead of one per day. Dependencies are read
/// synchronously (see `timelineData`).

@ProviderFor(monthOccurrences)
final monthOccurrencesProvider = MonthOccurrencesFamily._();

/// Timed tasks of [month] (year/month) bucketed by local start date in the
/// profile zone, for the month dots (docs/10 §3 `MonthGrid`). One range
/// query per month instead of one per day. Dependencies are read
/// synchronously (see `timelineData`).

final class MonthOccurrencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<DateTime, List<Occurrence>>>,
          Map<DateTime, List<Occurrence>>,
          Stream<Map<DateTime, List<Occurrence>>>
        >
    with
        $FutureModifier<Map<DateTime, List<Occurrence>>>,
        $StreamProvider<Map<DateTime, List<Occurrence>>> {
  /// Timed tasks of [month] (year/month) bucketed by local start date in the
  /// profile zone, for the month dots (docs/10 §3 `MonthGrid`). One range
  /// query per month instead of one per day. Dependencies are read
  /// synchronously (see `timelineData`).
  MonthOccurrencesProvider._({
    required MonthOccurrencesFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'monthOccurrencesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthOccurrencesHash();

  @override
  String toString() {
    return r'monthOccurrencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<DateTime, List<Occurrence>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<DateTime, List<Occurrence>>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return monthOccurrences(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthOccurrencesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthOccurrencesHash() => r'a326fa51a708f916f2960ae11a2930336445a7bb';

/// Timed tasks of [month] (year/month) bucketed by local start date in the
/// profile zone, for the month dots (docs/10 §3 `MonthGrid`). One range
/// query per month instead of one per day. Dependencies are read
/// synchronously (see `timelineData`).

final class MonthOccurrencesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<DateTime, List<Occurrence>>>,
          DateTime
        > {
  MonthOccurrencesFamily._()
    : super(
        retry: null,
        name: r'monthOccurrencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Timed tasks of [month] (year/month) bucketed by local start date in the
  /// profile zone, for the month dots (docs/10 §3 `MonthGrid`). One range
  /// query per month instead of one per day. Dependencies are read
  /// synchronously (see `timelineData`).

  MonthOccurrencesProvider call(DateTime month) =>
      MonthOccurrencesProvider._(argument: month, from: this);

  @override
  String toString() => r'monthOccurrencesProvider';
}

/// Live inbox items (docs/02 F3), e.g. for "Pull from inbox · 5".

@ProviderFor(inboxItems)
final inboxItemsProvider = InboxItemsProvider._();

/// Live inbox items (docs/02 F3), e.g. for "Pull from inbox · 5".

final class InboxItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Occurrence>>,
          List<Occurrence>,
          Stream<List<Occurrence>>
        >
    with $FutureModifier<List<Occurrence>>, $StreamProvider<List<Occurrence>> {
  /// Live inbox items (docs/02 F3), e.g. for "Pull from inbox · 5".
  InboxItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<Occurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Occurrence>> create(Ref ref) {
    return inboxItems(ref);
  }
}

String _$inboxItemsHash() => r'caf19b022d50313d67089224c7a7c11d23bc2f32';
