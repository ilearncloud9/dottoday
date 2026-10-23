// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_alerts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reminders shown inside the app instead of by the OS: on the web without
/// notification permission, and quiet-hours ones (docs/07 Web, M5.3).
/// Newest last; the banner shows it until acted on or dismissed.

@ProviderFor(InAppAlerts)
final inAppAlertsProvider = InAppAlertsProvider._();

/// Reminders shown inside the app instead of by the OS: on the web without
/// notification permission, and quiet-hours ones (docs/07 Web, M5.3).
/// Newest last; the banner shows it until acted on or dismissed.
final class InAppAlertsProvider
    extends $NotifierProvider<InAppAlerts, List<OsNotification>> {
  /// Reminders shown inside the app instead of by the OS: on the web without
  /// notification permission, and quiet-hours ones (docs/07 Web, M5.3).
  /// Newest last; the banner shows it until acted on or dismissed.
  InAppAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inAppAlertsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inAppAlertsHash();

  @$internal
  @override
  InAppAlerts create() => InAppAlerts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<OsNotification> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OsNotification>>(value),
    );
  }
}

String _$inAppAlertsHash() => r'da2fba0c2648b82b7be75097a9cd564d51ec4e02';

/// Reminders shown inside the app instead of by the OS: on the web without
/// notification permission, and quiet-hours ones (docs/07 Web, M5.3).
/// Newest last; the banner shows it until acted on or dismissed.

abstract class _$InAppAlerts extends $Notifier<List<OsNotification>> {
  List<OsNotification> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<OsNotification>, List<OsNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<OsNotification>, List<OsNotification>>,
              List<OsNotification>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
