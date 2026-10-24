// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_nudge_seen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The local day the "Plan your inbox" card was last put away (docs/02
/// F3.3), kept in `local_meta` per device and never synced (docs/05): a
/// nudge is a suggestion, and each device's Today asks on its own. Null
/// until the first time.

@ProviderFor(InboxNudgeSeen)
final inboxNudgeSeenProvider = InboxNudgeSeenProvider._();

/// The local day the "Plan your inbox" card was last put away (docs/02
/// F3.3), kept in `local_meta` per device and never synced (docs/05): a
/// nudge is a suggestion, and each device's Today asks on its own. Null
/// until the first time.
final class InboxNudgeSeenProvider
    extends $AsyncNotifierProvider<InboxNudgeSeen, DateTime?> {
  /// The local day the "Plan your inbox" card was last put away (docs/02
  /// F3.3), kept in `local_meta` per device and never synced (docs/05): a
  /// nudge is a suggestion, and each device's Today asks on its own. Null
  /// until the first time.
  InboxNudgeSeenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxNudgeSeenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxNudgeSeenHash();

  @$internal
  @override
  InboxNudgeSeen create() => InboxNudgeSeen();
}

String _$inboxNudgeSeenHash() => r'53397b6c92adadfeccf60ab1bffcf2889d671369';

/// The local day the "Plan your inbox" card was last put away (docs/02
/// F3.3), kept in `local_meta` per device and never synced (docs/05): a
/// nudge is a suggestion, and each device's Today asks on its own. Null
/// until the first time.

abstract class _$InboxNudgeSeen extends $AsyncNotifier<DateTime?> {
  FutureOr<DateTime?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DateTime?>, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DateTime?>, DateTime?>,
              AsyncValue<DateTime?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
