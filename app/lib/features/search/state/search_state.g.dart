// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Search tab's field and chip (kept while the tab is alive).

@ProviderFor(SearchInputState)
final searchInputStateProvider = SearchInputStateProvider._();

/// The Search tab's field and chip (kept while the tab is alive).
final class SearchInputStateProvider
    extends $NotifierProvider<SearchInputState, SearchInput> {
  /// The Search tab's field and chip (kept while the tab is alive).
  SearchInputStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchInputStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchInputStateHash();

  @$internal
  @override
  SearchInputState create() => SearchInputState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchInput>(value),
    );
  }
}

String _$searchInputStateHash() => r'df06ce292cf0ce66d358aae9536fedb2d43cf6ea';

/// The Search tab's field and chip (kept while the tab is alive).

abstract class _$SearchInputState extends $Notifier<SearchInput> {
  SearchInput build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchInput, SearchInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchInput, SearchInput>,
              SearchInput,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Live FTS hits for [query] (docs/02 F8, R-11: done tasks included).
/// Dependencies are read synchronously (see `timelineData`).

@ProviderFor(searchHits)
final searchHitsProvider = SearchHitsFamily._();

/// Live FTS hits for [query] (docs/02 F8, R-11: done tasks included).
/// Dependencies are read synchronously (see `timelineData`).

final class SearchHitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Occurrence>>,
          List<Occurrence>,
          Stream<List<Occurrence>>
        >
    with $FutureModifier<List<Occurrence>>, $StreamProvider<List<Occurrence>> {
  /// Live FTS hits for [query] (docs/02 F8, R-11: done tasks included).
  /// Dependencies are read synchronously (see `timelineData`).
  SearchHitsProvider._({
    required SearchHitsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchHitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchHitsHash();

  @override
  String toString() {
    return r'searchHitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Occurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Occurrence>> create(Ref ref) {
    final argument = this.argument as String;
    return searchHits(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchHitsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchHitsHash() => r'd407d643241d32c85cef1f4e0c7d747a154dabec';

/// Live FTS hits for [query] (docs/02 F8, R-11: done tasks included).
/// Dependencies are read synchronously (see `timelineData`).

final class SearchHitsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Occurrence>>, String> {
  SearchHitsFamily._()
    : super(
        retry: null,
        name: r'searchHitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live FTS hits for [query] (docs/02 F8, R-11: done tasks included).
  /// Dependencies are read synchronously (see `timelineData`).

  SearchHitsProvider call(String query) =>
      SearchHitsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchHitsProvider';
}

/// The hits for the current input, filtered and grouped (null while
/// loading; an empty query gives no groups).

@ProviderFor(searchView)
final searchViewProvider = SearchViewProvider._();

/// The hits for the current input, filtered and grouped (null while
/// loading; an empty query gives no groups).

final class SearchViewProvider
    extends $FunctionalProvider<SearchView?, SearchView?, SearchView?>
    with $Provider<SearchView?> {
  /// The hits for the current input, filtered and grouped (null while
  /// loading; an empty query gives no groups).
  SearchViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchViewHash();

  @$internal
  @override
  $ProviderElement<SearchView?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchView? create(Ref ref) {
    return searchView(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchView? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchView?>(value),
    );
  }
}

String _$searchViewHash() => r'247325eece714cc4f30eb0238a2bef1efb875857';
