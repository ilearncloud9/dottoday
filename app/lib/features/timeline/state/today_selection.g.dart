// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// UI state of the Today screen, reset when the screen is left.

@ProviderFor(TodaySelection)
final todaySelectionProvider = TodaySelectionProvider._();

/// UI state of the Today screen, reset when the screen is left.
final class TodaySelectionProvider
    extends $NotifierProvider<TodaySelection, TodayView> {
  /// UI state of the Today screen, reset when the screen is left.
  TodaySelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaySelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaySelectionHash();

  @$internal
  @override
  TodaySelection create() => TodaySelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodayView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodayView>(value),
    );
  }
}

String _$todaySelectionHash() => r'd777a383787a0e5f3ce688fa9f4cf3651db82ee9';

/// UI state of the Today screen, reset when the screen is left.

abstract class _$TodaySelection extends $Notifier<TodayView> {
  TodayView build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TodayView, TodayView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TodayView, TodayView>,
              TodayView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
