// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'write_back_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Write-back to calendars (docs/09 M7.3): the device writer for device
/// calendars; Google and Microsoft through `calendar-sync`, conditional on
/// the event's HTTP etag (M7.4).

@ProviderFor(calendarWriteBack)
final calendarWriteBackProvider = CalendarWriteBackProvider._();

/// Write-back to calendars (docs/09 M7.3): the device writer for device
/// calendars; Google and Microsoft through `calendar-sync`, conditional on
/// the event's HTTP etag (M7.4).

final class CalendarWriteBackProvider
    extends
        $FunctionalProvider<
          CalendarWriteBack,
          CalendarWriteBack,
          CalendarWriteBack
        >
    with $Provider<CalendarWriteBack> {
  /// Write-back to calendars (docs/09 M7.3): the device writer for device
  /// calendars; Google and Microsoft through `calendar-sync`, conditional on
  /// the event's HTTP etag (M7.4).
  CalendarWriteBackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarWriteBackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarWriteBackHash();

  @$internal
  @override
  $ProviderElement<CalendarWriteBack> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CalendarWriteBack create(Ref ref) {
    return calendarWriteBack(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarWriteBack value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarWriteBack>(value),
    );
  }
}

String _$calendarWriteBackHash() => r'8ebde0dbac6994d4774cd95b2c12d1bd24f56e6c';

/// The write-back status of the imported event linked by [linkId]; null
/// when the link is gone.

@ProviderFor(calendarWriteStatus)
final calendarWriteStatusProvider = CalendarWriteStatusFamily._();

/// The write-back status of the imported event linked by [linkId]; null
/// when the link is gone.

final class CalendarWriteStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<CalendarWriteStatus?>,
          CalendarWriteStatus?,
          Stream<CalendarWriteStatus?>
        >
    with
        $FutureModifier<CalendarWriteStatus?>,
        $StreamProvider<CalendarWriteStatus?> {
  /// The write-back status of the imported event linked by [linkId]; null
  /// when the link is gone.
  CalendarWriteStatusProvider._({
    required CalendarWriteStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'calendarWriteStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarWriteStatusHash();

  @override
  String toString() {
    return r'calendarWriteStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<CalendarWriteStatus?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CalendarWriteStatus?> create(Ref ref) {
    final argument = this.argument as String;
    return calendarWriteStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarWriteStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarWriteStatusHash() =>
    r'329bb119b0b61d90008ec900b614d1e3225e7739';

/// The write-back status of the imported event linked by [linkId]; null
/// when the link is gone.

final class CalendarWriteStatusFamily extends $Family
    with $FunctionalFamilyOverride<Stream<CalendarWriteStatus?>, String> {
  CalendarWriteStatusFamily._()
    : super(
        retry: null,
        name: r'calendarWriteStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The write-back status of the imported event linked by [linkId]; null
  /// when the link is gone.

  CalendarWriteStatusProvider call(String linkId) =>
      CalendarWriteStatusProvider._(argument: linkId, from: this);

  @override
  String toString() => r'calendarWriteStatusProvider';
}

/// Sends edits of imported events back as they happen (a short pause
/// first, so typing a title sends once), and keeps what needs the person
/// for the banner. A failed or clashing item is not retried on its own
/// until it changes again or the person taps Retry (no retry storm).

@ProviderFor(WriteBackController)
final writeBackControllerProvider = WriteBackControllerProvider._();

/// Sends edits of imported events back as they happen (a short pause
/// first, so typing a title sends once), and keeps what needs the person
/// for the banner. A failed or clashing item is not retried on its own
/// until it changes again or the person taps Retry (no retry storm).
final class WriteBackControllerProvider
    extends $NotifierProvider<WriteBackController, WriteBackState> {
  /// Sends edits of imported events back as they happen (a short pause
  /// first, so typing a title sends once), and keeps what needs the person
  /// for the banner. A failed or clashing item is not retried on its own
  /// until it changes again or the person taps Retry (no retry storm).
  WriteBackControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writeBackControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writeBackControllerHash();

  @$internal
  @override
  WriteBackController create() => WriteBackController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WriteBackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WriteBackState>(value),
    );
  }
}

String _$writeBackControllerHash() =>
    r'955358fd6bccb6cfd893821f03251377d8299ee5';

/// Sends edits of imported events back as they happen (a short pause
/// first, so typing a title sends once), and keeps what needs the person
/// for the banner. A failed or clashing item is not retried on its own
/// until it changes again or the person taps Retry (no retry storm).

abstract class _$WriteBackController extends $Notifier<WriteBackState> {
  WriteBackState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WriteBackState, WriteBackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WriteBackState, WriteBackState>,
              WriteBackState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
