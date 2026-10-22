// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A day in the week the Week board shows; null = this week (follows
/// today). Reset when the board is left.

@ProviderFor(WeekSelection)
final weekSelectionProvider = WeekSelectionProvider._();

/// A day in the week the Week board shows; null = this week (follows
/// today). Reset when the board is left.
final class WeekSelectionProvider
    extends $NotifierProvider<WeekSelection, DateTime?> {
  /// A day in the week the Week board shows; null = this week (follows
  /// today). Reset when the board is left.
  WeekSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weekSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weekSelectionHash();

  @$internal
  @override
  WeekSelection create() => WeekSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$weekSelectionHash() => r'b3289d5bcba3e45813f49c5b5d1f2c7b72dcc0f3';

/// A day in the week the Week board shows; null = this week (follows
/// today). Reset when the board is left.

abstract class _$WeekSelection extends $Notifier<DateTime?> {
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
