// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_live_dot_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The day snapshot the web sink wrote last, kept in memory with its
/// titles (the stored copy has none, M9.1) for the tab (M9.7).

@ProviderFor(LastDaySnapshot)
final lastDaySnapshotProvider = LastDaySnapshotProvider._();

/// The day snapshot the web sink wrote last, kept in memory with its
/// titles (the stored copy has none, M9.1) for the tab (M9.7).
final class LastDaySnapshotProvider
    extends $NotifierProvider<LastDaySnapshot, DaySnapshot?> {
  /// The day snapshot the web sink wrote last, kept in memory with its
  /// titles (the stored copy has none, M9.1) for the tab (M9.7).
  LastDaySnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastDaySnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastDaySnapshotHash();

  @$internal
  @override
  LastDaySnapshot create() => LastDaySnapshot();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DaySnapshot? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DaySnapshot?>(value),
    );
  }
}

String _$lastDaySnapshotHash() => r'd11e8206e55b9de865029d263bcbdb52083b8b45';

/// The day snapshot the web sink wrote last, kept in memory with its
/// titles (the stored copy has none, M9.1) for the tab (M9.7).

abstract class _$LastDaySnapshot extends $Notifier<DaySnapshot?> {
  DaySnapshot? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DaySnapshot?, DaySnapshot?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DaySnapshot?, DaySnapshot?>,
              DaySnapshot?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The tab's title, favicon and badge, moving on every minute (M9.7).

@ProviderFor(webLiveDotState)
final webLiveDotStateProvider = WebLiveDotStateProvider._();

/// The tab's title, favicon and badge, moving on every minute (M9.7).

final class WebLiveDotStateProvider
    extends $FunctionalProvider<WebLiveDot, WebLiveDot, WebLiveDot>
    with $Provider<WebLiveDot> {
  /// The tab's title, favicon and badge, moving on every minute (M9.7).
  WebLiveDotStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webLiveDotStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webLiveDotStateHash();

  @$internal
  @override
  $ProviderElement<WebLiveDot> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WebLiveDot create(Ref ref) {
    return webLiveDotState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebLiveDot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebLiveDot>(value),
    );
  }
}

String _$webLiveDotStateHash() => r'3790b1837affa310515ce2cda36d7950ee3ca188';
