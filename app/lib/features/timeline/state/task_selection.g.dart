// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Multi-select on the Today screen. Picking on another day starts over
/// there: the bar acts on one day at a time.

@ProviderFor(TaskSelection)
final taskSelectionProvider = TaskSelectionProvider._();

/// Multi-select on the Today screen. Picking on another day starts over
/// there: the bar acts on one day at a time.
final class TaskSelectionProvider
    extends $NotifierProvider<TaskSelection, Picked> {
  /// Multi-select on the Today screen. Picking on another day starts over
  /// there: the bar acts on one day at a time.
  TaskSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskSelectionHash();

  @$internal
  @override
  TaskSelection create() => TaskSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Picked value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Picked>(value),
    );
  }
}

String _$taskSelectionHash() => r'486c086ebe24b13182a918136cd371bd01e53053';

/// Multi-select on the Today screen. Picking on another day starts over
/// there: the bar acts on one day at a time.

abstract class _$TaskSelection extends $Notifier<Picked> {
  Picked build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Picked, Picked>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Picked, Picked>,
              Picked,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
