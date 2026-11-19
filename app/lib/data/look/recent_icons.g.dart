// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_icons.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The icons last picked on this device, newest first, at most
/// [DotLook.recentIcons] (ED-086 "Recently used"; owner, 4c: on the
/// device, never synced). Kept in `local_meta` as a JSON list of keys.

@ProviderFor(RecentIcons)
final recentIconsProvider = RecentIconsProvider._();

/// The icons last picked on this device, newest first, at most
/// [DotLook.recentIcons] (ED-086 "Recently used"; owner, 4c: on the
/// device, never synced). Kept in `local_meta` as a JSON list of keys.
final class RecentIconsProvider
    extends $AsyncNotifierProvider<RecentIcons, List<String>> {
  /// The icons last picked on this device, newest first, at most
  /// [DotLook.recentIcons] (ED-086 "Recently used"; owner, 4c: on the
  /// device, never synced). Kept in `local_meta` as a JSON list of keys.
  RecentIconsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentIconsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentIconsHash();

  @$internal
  @override
  RecentIcons create() => RecentIcons();
}

String _$recentIconsHash() => r'50190bb9a73f82061a500c4dee34a38121271ea4';

/// The icons last picked on this device, newest first, at most
/// [DotLook.recentIcons] (ED-086 "Recently used"; owner, 4c: on the
/// device, never synced). Kept in `local_meta` as a JSON list of keys.

abstract class _$RecentIcons extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
