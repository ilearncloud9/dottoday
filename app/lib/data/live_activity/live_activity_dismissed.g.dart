// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_activity_dismissed.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the user has ever dismissed the live dot themselves: the
/// trigger of minimal mode's widget hint (docs/14 §5, M16). iOS sends one
/// `dismissedByUser` event on `dottoday/live_activity` for a Live Activity
/// (ios/Shared/LiveActivities.swift); Android keeps a swipe of the ongoing
/// notification (OngoingDot.kt) until read with `takeDismissed` on
/// `dottoday/ongoing`, on each build — launch and every resume (R-13). It
/// is kept in `local_meta`, per device and never synced, like the other
/// nudge flags. The hint itself still follows the one-a-day, twice-ever
/// budget.

@ProviderFor(LiveActivityDismissed)
final liveActivityDismissedProvider = LiveActivityDismissedProvider._();

/// Whether the user has ever dismissed the live dot themselves: the
/// trigger of minimal mode's widget hint (docs/14 §5, M16). iOS sends one
/// `dismissedByUser` event on `dottoday/live_activity` for a Live Activity
/// (ios/Shared/LiveActivities.swift); Android keeps a swipe of the ongoing
/// notification (OngoingDot.kt) until read with `takeDismissed` on
/// `dottoday/ongoing`, on each build — launch and every resume (R-13). It
/// is kept in `local_meta`, per device and never synced, like the other
/// nudge flags. The hint itself still follows the one-a-day, twice-ever
/// budget.
final class LiveActivityDismissedProvider
    extends $AsyncNotifierProvider<LiveActivityDismissed, bool> {
  /// Whether the user has ever dismissed the live dot themselves: the
  /// trigger of minimal mode's widget hint (docs/14 §5, M16). iOS sends one
  /// `dismissedByUser` event on `dottoday/live_activity` for a Live Activity
  /// (ios/Shared/LiveActivities.swift); Android keeps a swipe of the ongoing
  /// notification (OngoingDot.kt) until read with `takeDismissed` on
  /// `dottoday/ongoing`, on each build — launch and every resume (R-13). It
  /// is kept in `local_meta`, per device and never synced, like the other
  /// nudge flags. The hint itself still follows the one-a-day, twice-ever
  /// budget.
  LiveActivityDismissedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveActivityDismissedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveActivityDismissedHash();

  @$internal
  @override
  LiveActivityDismissed create() => LiveActivityDismissed();
}

String _$liveActivityDismissedHash() =>
    r'1f3a7e739dc45a1b8554fb32fb30a8d796252848';

/// Whether the user has ever dismissed the live dot themselves: the
/// trigger of minimal mode's widget hint (docs/14 §5, M16). iOS sends one
/// `dismissedByUser` event on `dottoday/live_activity` for a Live Activity
/// (ios/Shared/LiveActivities.swift); Android keeps a swipe of the ongoing
/// notification (OngoingDot.kt) until read with `takeDismissed` on
/// `dottoday/ongoing`, on each build — launch and every resume (R-13). It
/// is kept in `local_meta`, per device and never synced, like the other
/// nudge flags. The hint itself still follows the one-a-day, twice-ever
/// budget.

abstract class _$LiveActivityDismissed extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
