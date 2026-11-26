// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'later_cards_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This device's later cards (see [LaterCardsState]).

@ProviderFor(LaterCards)
final laterCardsProvider = LaterCardsProvider._();

/// This device's later cards (see [LaterCardsState]).
final class LaterCardsProvider
    extends $AsyncNotifierProvider<LaterCards, LaterCardsState> {
  /// This device's later cards (see [LaterCardsState]).
  LaterCardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'laterCardsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$laterCardsHash();

  @$internal
  @override
  LaterCards create() => LaterCards();
}

String _$laterCardsHash() => r'c9f681b295028d14d042d464ce662709636b0e03';

/// This device's later cards (see [LaterCardsState]).

abstract class _$LaterCards extends $AsyncNotifier<LaterCardsState> {
  FutureOr<LaterCardsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LaterCardsState>, LaterCardsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LaterCardsState>, LaterCardsState>,
              AsyncValue<LaterCardsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
