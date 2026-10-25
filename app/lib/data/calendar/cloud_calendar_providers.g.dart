// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Google and Microsoft calendars through the backend (docs/09 M7.4);
/// unavailable without a Supabase client (tests, local-only builds).

@ProviderFor(cloudCalendars)
final cloudCalendarsProvider = CloudCalendarsProvider._();

/// Google and Microsoft calendars through the backend (docs/09 M7.4);
/// unavailable without a Supabase client (tests, local-only builds).

final class CloudCalendarsProvider
    extends $FunctionalProvider<CloudCalendars, CloudCalendars, CloudCalendars>
    with $Provider<CloudCalendars> {
  /// Google and Microsoft calendars through the backend (docs/09 M7.4);
  /// unavailable without a Supabase client (tests, local-only builds).
  CloudCalendarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudCalendarsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudCalendarsHash();

  @$internal
  @override
  $ProviderElement<CloudCalendars> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudCalendars create(Ref ref) {
    return cloudCalendars(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudCalendars value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudCalendars>(value),
    );
  }
}

String _$cloudCalendarsHash() => r'73a3dbed7122a16d9c61bcbf9c9f7b210cce365f';

/// The signed-in account's connections; none when signed out. Throws the
/// failure when they can't be listed (the page's error state).

@ProviderFor(cloudAccounts)
final cloudAccountsProvider = CloudAccountsProvider._();

/// The signed-in account's connections; none when signed out. Throws the
/// failure when they can't be listed (the page's error state).

final class CloudAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CloudAccount>>,
          List<CloudAccount>,
          FutureOr<List<CloudAccount>>
        >
    with
        $FutureModifier<List<CloudAccount>>,
        $FutureProvider<List<CloudAccount>> {
  /// The signed-in account's connections; none when signed out. Throws the
  /// failure when they can't be listed (the page's error state).
  CloudAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudAccountsHash();

  @$internal
  @override
  $FutureProviderElement<List<CloudAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CloudAccount>> create(Ref ref) {
    return cloudAccounts(ref);
  }
}

String _$cloudAccountsHash() => r'fac0cb299ebbdcb372c23e64d459a8d3d87244aa';

/// Each connected calendar with its switch and inherited colour, as for
/// device calendars (the switches are this device's).

@ProviderFor(cloudCalendarChoiceList)
final cloudCalendarChoiceListProvider = CloudCalendarChoiceListProvider._();

/// Each connected calendar with its switch and inherited colour, as for
/// device calendars (the switches are this device's).

final class CloudCalendarChoiceListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CalendarChoice>>,
          List<CalendarChoice>,
          Stream<List<CalendarChoice>>
        >
    with
        $FutureModifier<List<CalendarChoice>>,
        $StreamProvider<List<CalendarChoice>> {
  /// Each connected calendar with its switch and inherited colour, as for
  /// device calendars (the switches are this device's).
  CloudCalendarChoiceListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudCalendarChoiceListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudCalendarChoiceListHash();

  @$internal
  @override
  $StreamProviderElement<List<CalendarChoice>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CalendarChoice>> create(Ref ref) {
    return cloudCalendarChoiceList(ref);
  }
}

String _$cloudCalendarChoiceListHash() =>
    r'3d25f3df535440b9337d7d5a64477a1756d87c36';

/// Connected-account events → occurrences, like device calendars' but
/// owning only the Google/Microsoft links (docs/09 M7.4).

@ProviderFor(cloudCalendarImporter)
final cloudCalendarImporterProvider = CloudCalendarImporterProvider._();

/// Connected-account events → occurrences, like device calendars' but
/// owning only the Google/Microsoft links (docs/09 M7.4).

final class CloudCalendarImporterProvider
    extends $FunctionalProvider<CalendarImport, CalendarImport, CalendarImport>
    with $Provider<CalendarImport> {
  /// Connected-account events → occurrences, like device calendars' but
  /// owning only the Google/Microsoft links (docs/09 M7.4).
  CloudCalendarImporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudCalendarImporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudCalendarImporterHash();

  @$internal
  @override
  $ProviderElement<CalendarImport> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CalendarImport create(Ref ref) {
    return cloudCalendarImporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarImport value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarImport>(value),
    );
  }
}

String _$cloudCalendarImporterHash() =>
    r'07b8547d3ef69828e54670dcbfe837da125ebecf';

@ProviderFor(cloudCalendarActions)
final cloudCalendarActionsProvider = CloudCalendarActionsProvider._();

final class CloudCalendarActionsProvider
    extends
        $FunctionalProvider<
          CloudCalendarActions,
          CloudCalendarActions,
          CloudCalendarActions
        >
    with $Provider<CloudCalendarActions> {
  CloudCalendarActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudCalendarActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudCalendarActionsHash();

  @$internal
  @override
  $ProviderElement<CloudCalendarActions> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CloudCalendarActions create(Ref ref) {
    return cloudCalendarActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudCalendarActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudCalendarActions>(value),
    );
  }
}

String _$cloudCalendarActionsHash() =>
    r'a3243a19e9c964eb9fb326731f75b862a2dc95f0';
