// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month the Mac/web Month page shows (year/month); null = this
/// month. Reset when the page is left.

@ProviderFor(MonthSelection)
final monthSelectionProvider = MonthSelectionProvider._();

/// The month the Mac/web Month page shows (year/month); null = this
/// month. Reset when the page is left.
final class MonthSelectionProvider
    extends $NotifierProvider<MonthSelection, DateTime?> {
  /// The month the Mac/web Month page shows (year/month); null = this
  /// month. Reset when the page is left.
  MonthSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthSelectionHash();

  @$internal
  @override
  MonthSelection create() => MonthSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$monthSelectionHash() => r'f22b2c28b0571bf230db76533956818b0a5da62b';

/// The month the Mac/web Month page shows (year/month); null = this
/// month. Reset when the page is left.

abstract class _$MonthSelection extends $Notifier<DateTime?> {
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
