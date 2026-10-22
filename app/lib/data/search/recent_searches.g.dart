// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_searches.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Search › RECENT (`A-ios-search`): the last five queries, on this device
/// only (`local_meta`, never synced or exported — search terms can be
/// personal, 06 §5).

@ProviderFor(RecentSearches)
final recentSearchesProvider = RecentSearchesProvider._();

/// Search › RECENT (`A-ios-search`): the last five queries, on this device
/// only (`local_meta`, never synced or exported — search terms can be
/// personal, 06 §5).
final class RecentSearchesProvider
    extends $AsyncNotifierProvider<RecentSearches, List<String>> {
  /// Search › RECENT (`A-ios-search`): the last five queries, on this device
  /// only (`local_meta`, never synced or exported — search terms can be
  /// personal, 06 §5).
  RecentSearchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesHash();

  @$internal
  @override
  RecentSearches create() => RecentSearches();
}

String _$recentSearchesHash() => r'14723123ddb2872dec5329ca2a81169589b6b858';

/// Search › RECENT (`A-ios-search`): the last five queries, on this device
/// only (`local_meta`, never synced or exported — search terms can be
/// personal, 06 §5).

abstract class _$RecentSearches extends $AsyncNotifier<List<String>> {
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
