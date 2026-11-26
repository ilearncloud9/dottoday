// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_review.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The last choice on the Mac and the web, while its Undo is offered in
/// the popover (C5), else null. Clears itself after [conflictUndoWindow].

@ProviderFor(LastConflictChoice)
final lastConflictChoiceProvider = LastConflictChoiceProvider._();

/// The last choice on the Mac and the web, while its Undo is offered in
/// the popover (C5), else null. Clears itself after [conflictUndoWindow].
final class LastConflictChoiceProvider
    extends $NotifierProvider<LastConflictChoice, ConflictUndo?> {
  /// The last choice on the Mac and the web, while its Undo is offered in
  /// the popover (C5), else null. Clears itself after [conflictUndoWindow].
  LastConflictChoiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastConflictChoiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastConflictChoiceHash();

  @$internal
  @override
  LastConflictChoice create() => LastConflictChoice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConflictUndo? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConflictUndo?>(value),
    );
  }
}

String _$lastConflictChoiceHash() =>
    r'802fdaebf2d8b5bb19104da8e6ad1d9e55079dd9';

/// The last choice on the Mac and the web, while its Undo is offered in
/// the popover (C5), else null. Clears itself after [conflictUndoWindow].

abstract class _$LastConflictChoice extends $Notifier<ConflictUndo?> {
  ConflictUndo? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConflictUndo?, ConflictUndo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConflictUndo?, ConflictUndo?>,
              ConflictUndo?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
