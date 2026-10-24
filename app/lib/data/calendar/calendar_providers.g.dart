// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The device calendars: `device_calendar` on iOS and Android (M7.1), the
/// EventKit channel on macOS (M7.1b); none on the web (M7.4).

@ProviderFor(deviceCalendarGateway)
final deviceCalendarGatewayProvider = DeviceCalendarGatewayProvider._();

/// The device calendars: `device_calendar` on iOS and Android (M7.1), the
/// EventKit channel on macOS (M7.1b); none on the web (M7.4).

final class DeviceCalendarGatewayProvider
    extends
        $FunctionalProvider<
          DeviceCalendarGateway,
          DeviceCalendarGateway,
          DeviceCalendarGateway
        >
    with $Provider<DeviceCalendarGateway> {
  /// The device calendars: `device_calendar` on iOS and Android (M7.1), the
  /// EventKit channel on macOS (M7.1b); none on the web (M7.4).
  DeviceCalendarGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceCalendarGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceCalendarGatewayHash();

  @$internal
  @override
  $ProviderElement<DeviceCalendarGateway> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceCalendarGateway create(Ref ref) {
    return deviceCalendarGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceCalendarGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceCalendarGateway>(value),
    );
  }
}

String _$deviceCalendarGatewayHash() =>
    r'2acf05f5504656d1a4bdebf86ee16511e141424a';

@ProviderFor(calendarSourceRepository)
final calendarSourceRepositoryProvider = CalendarSourceRepositoryProvider._();

final class CalendarSourceRepositoryProvider
    extends
        $FunctionalProvider<
          CalendarSourceRepository,
          CalendarSourceRepository,
          CalendarSourceRepository
        >
    with $Provider<CalendarSourceRepository> {
  CalendarSourceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarSourceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarSourceRepositoryHash();

  @$internal
  @override
  $ProviderElement<CalendarSourceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CalendarSourceRepository create(Ref ref) {
    return calendarSourceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarSourceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarSourceRepository>(value),
    );
  }
}

String _$calendarSourceRepositoryHash() =>
    r'2e120b9ecc35f8fdae5f32b8d4dd00bf926f3bd7';

/// Device-calendar events → occurrences (docs/09 M7.2).

@ProviderFor(calendarImporter)
final calendarImporterProvider = CalendarImporterProvider._();

/// Device-calendar events → occurrences (docs/09 M7.2).

final class CalendarImporterProvider
    extends $FunctionalProvider<CalendarImport, CalendarImport, CalendarImport>
    with $Provider<CalendarImport> {
  /// Device-calendar events → occurrences (docs/09 M7.2).
  CalendarImporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarImporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarImporterHash();

  @$internal
  @override
  $ProviderElement<CalendarImport> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CalendarImport create(Ref ref) {
    return calendarImporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarImport value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarImport>(value),
    );
  }
}

String _$calendarImporterHash() => r'd17a0106ecbb3402042ca07c37c75683c430875a';

/// The calendar permission now; re-read with `ref.invalidate` (on resume,
/// after asking).

@ProviderFor(calendarPermissionState)
final calendarPermissionStateProvider = CalendarPermissionStateProvider._();

/// The calendar permission now; re-read with `ref.invalidate` (on resume,
/// after asking).

final class CalendarPermissionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<PermissionState>,
          PermissionState,
          FutureOr<PermissionState>
        >
    with $FutureModifier<PermissionState>, $FutureProvider<PermissionState> {
  /// The calendar permission now; re-read with `ref.invalidate` (on resume,
  /// after asking).
  CalendarPermissionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarPermissionStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarPermissionStateHash();

  @$internal
  @override
  $FutureProviderElement<PermissionState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PermissionState> create(Ref ref) {
    return calendarPermissionState(ref);
  }
}

String _$calendarPermissionStateHash() =>
    r'b8b8e6c9ce1f452ae9929ab557133560dd2b33b3';

/// The device's calendars once allowed, else none. Throws the failure
/// when they can't be read (shown by the page's error state).

@ProviderFor(deviceCalendars)
final deviceCalendarsProvider = DeviceCalendarsProvider._();

/// The device's calendars once allowed, else none. Throws the failure
/// when they can't be read (shown by the page's error state).

final class DeviceCalendarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceCalendar>>,
          List<DeviceCalendar>,
          FutureOr<List<DeviceCalendar>>
        >
    with
        $FutureModifier<List<DeviceCalendar>>,
        $FutureProvider<List<DeviceCalendar>> {
  /// The device's calendars once allowed, else none. Throws the failure
  /// when they can't be read (shown by the page's error state).
  DeviceCalendarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceCalendarsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceCalendarsHash();

  @$internal
  @override
  $FutureProviderElement<List<DeviceCalendar>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeviceCalendar>> create(Ref ref) {
    return deviceCalendars(ref);
  }
}

String _$deviceCalendarsHash() => r'8f48463587f1edd3be8d8d8de0cb558693466d19';

/// Each device calendar with its switch and inherited colour.

@ProviderFor(calendarChoiceList)
final calendarChoiceListProvider = CalendarChoiceListProvider._();

/// Each device calendar with its switch and inherited colour.

final class CalendarChoiceListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CalendarChoice>>,
          List<CalendarChoice>,
          Stream<List<CalendarChoice>>
        >
    with
        $FutureModifier<List<CalendarChoice>>,
        $StreamProvider<List<CalendarChoice>> {
  /// Each device calendar with its switch and inherited colour.
  CalendarChoiceListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarChoiceListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarChoiceListHash();

  @$internal
  @override
  $StreamProviderElement<List<CalendarChoice>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CalendarChoice>> create(Ref ref) {
    return calendarChoiceList(ref);
  }
}

String _$calendarChoiceListHash() =>
    r'39a09e89891e8d2a06b3a1f7632424f50cdd3e1c';

/// What Settings and onboarding do with device calendars.

@ProviderFor(calendarActions)
final calendarActionsProvider = CalendarActionsProvider._();

/// What Settings and onboarding do with device calendars.

final class CalendarActionsProvider
    extends
        $FunctionalProvider<CalendarActions, CalendarActions, CalendarActions>
    with $Provider<CalendarActions> {
  /// What Settings and onboarding do with device calendars.
  CalendarActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarActionsHash();

  @$internal
  @override
  $ProviderElement<CalendarActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CalendarActions create(Ref ref) {
    return calendarActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarActions>(value),
    );
  }
}

String _$calendarActionsHash() => r'085454a45919f587388c4c443c48cc8f7cdd2443';
