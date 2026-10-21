// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current user's live inbox (docs/02 F3): open and completed items
/// with no start, in `sortOrder`. Shared by the Inbox tab and Today's
/// "Pull from inbox · 5". Dependencies are read synchronously (see
/// `timelineData`).

@ProviderFor(inboxItems)
final inboxItemsProvider = InboxItemsProvider._();

/// The current user's live inbox (docs/02 F3): open and completed items
/// with no start, in `sortOrder`. Shared by the Inbox tab and Today's
/// "Pull from inbox · 5". Dependencies are read synchronously (see
/// `timelineData`).

final class InboxItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Occurrence>>,
          List<Occurrence>,
          Stream<List<Occurrence>>
        >
    with $FutureModifier<List<Occurrence>>, $StreamProvider<List<Occurrence>> {
  /// The current user's live inbox (docs/02 F3): open and completed items
  /// with no start, in `sortOrder`. Shared by the Inbox tab and Today's
  /// "Pull from inbox · 5". Dependencies are read synchronously (see
  /// `timelineData`).
  InboxItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<Occurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Occurrence>> create(Ref ref) {
    return inboxItems(ref);
  }
}

String _$inboxItemsHash() => r'caf19b022d50313d67089224c7a7c11d23bc2f32';
