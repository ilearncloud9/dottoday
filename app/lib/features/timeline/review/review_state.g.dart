// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The review shown beside the day (ED-099, ED-297): the pane on an iPad
/// or Android tablet's Workspace, or Minimal's Day column on the Mac and
/// the web. Null = none. Cleared at every change of owner (CR-160 I5).

@ProviderFor(ReviewBeside)
final reviewBesideProvider = ReviewBesideProvider._();

/// The review shown beside the day (ED-099, ED-297): the pane on an iPad
/// or Android tablet's Workspace, or Minimal's Day column on the Mac and
/// the web. Null = none. Cleared at every change of owner (CR-160 I5).
final class ReviewBesideProvider
    extends $NotifierProvider<ReviewBeside, ReviewOpen?> {
  /// The review shown beside the day (ED-099, ED-297): the pane on an iPad
  /// or Android tablet's Workspace, or Minimal's Day column on the Mac and
  /// the web. Null = none. Cleared at every change of owner (CR-160 I5).
  ReviewBesideProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewBesideProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewBesideHash();

  @$internal
  @override
  ReviewBeside create() => ReviewBeside();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewOpen? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewOpen?>(value),
    );
  }
}

String _$reviewBesideHash() => r'6bfdd405a027b3fad82940dfb467d735708b27d9';

/// The review shown beside the day (ED-099, ED-297): the pane on an iPad
/// or Android tablet's Workspace, or Minimal's Day column on the Mac and
/// the web. Null = none. Cleared at every change of owner (CR-160 I5).

abstract class _$ReviewBeside extends $Notifier<ReviewOpen?> {
  ReviewOpen? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReviewOpen?, ReviewOpen?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReviewOpen?, ReviewOpen?>,
              ReviewOpen?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The day the Review place shows (ED-099): set by the entry that opened
/// it, then stepped with ‹ ›. Null = the review's own day.

@ProviderFor(ReviewPlaceDay)
final reviewPlaceDayProvider = ReviewPlaceDayProvider._();

/// The day the Review place shows (ED-099): set by the entry that opened
/// it, then stepped with ‹ ›. Null = the review's own day.
final class ReviewPlaceDayProvider
    extends $NotifierProvider<ReviewPlaceDay, DateTime?> {
  /// The day the Review place shows (ED-099): set by the entry that opened
  /// it, then stepped with ‹ ›. Null = the review's own day.
  ReviewPlaceDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewPlaceDayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewPlaceDayHash();

  @$internal
  @override
  ReviewPlaceDay create() => ReviewPlaceDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$reviewPlaceDayHash() => r'c5db69061a7c304587b0342e11eaaefe1b50e8a7';

/// The day the Review place shows (ED-099): set by the entry that opened
/// it, then stepped with ‹ ›. Null = the review's own day.

abstract class _$ReviewPlaceDay extends $Notifier<DateTime?> {
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
