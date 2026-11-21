// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_pick.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The day picked on the Calendar tab's month (E-Phones Calendar,
/// ED-075): its card shows under the grid. Kept for the session, so
/// coming back to the tab keeps the pick; null until a day is tapped.

@ProviderFor(CalendarPick)
final calendarPickProvider = CalendarPickProvider._();

/// The day picked on the Calendar tab's month (E-Phones Calendar,
/// ED-075): its card shows under the grid. Kept for the session, so
/// coming back to the tab keeps the pick; null until a day is tapped.
final class CalendarPickProvider
    extends $NotifierProvider<CalendarPick, DateTime?> {
  /// The day picked on the Calendar tab's month (E-Phones Calendar,
  /// ED-075): its card shows under the grid. Kept for the session, so
  /// coming back to the tab keeps the pick; null until a day is tapped.
  CalendarPickProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarPickProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarPickHash();

  @$internal
  @override
  CalendarPick create() => CalendarPick();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$calendarPickHash() => r'5595a8d0d30612783b8178915d03800a51f1e58d';

/// The day picked on the Calendar tab's month (E-Phones Calendar,
/// ED-075): its card shows under the grid. Kept for the session, so
/// coming back to the tab keeps the pick; null until a day is tapped.

abstract class _$CalendarPick extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
