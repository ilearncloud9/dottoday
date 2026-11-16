// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_searches.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Search › RECENT (`A-ios-search`): the last five queries of the owner the
/// app shows, on this device only (`local_meta`, never synced or exported —
/// search terms can be personal, 06 §5). Kept per owner and rebuilt at
/// every change of owner (CR-160 I4): the next person never sees them.

@ProviderFor(RecentSearches)
final recentSearchesProvider = RecentSearchesProvider._();

/// Search › RECENT (`A-ios-search`): the last five queries of the owner the
/// app shows, on this device only (`local_meta`, never synced or exported —
/// search terms can be personal, 06 §5). Kept per owner and rebuilt at
/// every change of owner (CR-160 I4): the next person never sees them.
final class RecentSearchesProvider
    extends $AsyncNotifierProvider<RecentSearches, List<String>> {
  /// Search › RECENT (`A-ios-search`): the last five queries of the owner the
  /// app shows, on this device only (`local_meta`, never synced or exported —
  /// search terms can be personal, 06 §5). Kept per owner and rebuilt at
  /// every change of owner (CR-160 I4): the next person never sees them.
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

String _$recentSearchesHash() => r'e4496de601c7049a88e4d49e5ae1dde8b89a4be1';

/// Search › RECENT (`A-ios-search`): the last five queries of the owner the
/// app shows, on this device only (`local_meta`, never synced or exported —
/// search terms can be personal, 06 §5). Kept per owner and rebuilt at
/// every change of owner (CR-160 I4): the next person never sees them.

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
