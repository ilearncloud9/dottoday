// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Inbox items picked for the selection bar (docs/09 M3f.9c; the
/// Today one is per day, this one is the Inbox's). Empty = not selecting.

@ProviderFor(InboxSelection)
final inboxSelectionProvider = InboxSelectionProvider._();

/// The Inbox items picked for the selection bar (docs/09 M3f.9c; the
/// Today one is per day, this one is the Inbox's). Empty = not selecting.
final class InboxSelectionProvider
    extends $NotifierProvider<InboxSelection, Set<String>> {
  /// The Inbox items picked for the selection bar (docs/09 M3f.9c; the
  /// Today one is per day, this one is the Inbox's). Empty = not selecting.
  InboxSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxSelectionHash();

  @$internal
  @override
  InboxSelection create() => InboxSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$inboxSelectionHash() => r'b0efaf0e20bba701ec22fb447731407a07d41d34';

/// The Inbox items picked for the selection bar (docs/09 M3f.9c; the
/// Today one is per day, this one is the Inbox's). Empty = not selecting.

abstract class _$InboxSelection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
