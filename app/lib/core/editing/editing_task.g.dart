// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editing_task.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The task open in the Mac/web editor panel (docs/10 §4 "editing in a
/// right-hand TaskEditor panel, no sheets", M3e.5); null = closed. Held
/// in core so every screen can open a task without importing the editor.

@ProviderFor(EditingTask)
final editingTaskProvider = EditingTaskProvider._();

/// The task open in the Mac/web editor panel (docs/10 §4 "editing in a
/// right-hand TaskEditor panel, no sheets", M3e.5); null = closed. Held
/// in core so every screen can open a task without importing the editor.
final class EditingTaskProvider
    extends $NotifierProvider<EditingTask, String?> {
  /// The task open in the Mac/web editor panel (docs/10 §4 "editing in a
  /// right-hand TaskEditor panel, no sheets", M3e.5); null = closed. Held
  /// in core so every screen can open a task without importing the editor.
  EditingTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editingTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editingTaskHash();

  @$internal
  @override
  EditingTask create() => EditingTask();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$editingTaskHash() => r'e732d963b0a59598c2e29330ebb371802c0a029c';

/// The task open in the Mac/web editor panel (docs/10 §4 "editing in a
/// right-hand TaskEditor panel, no sheets", M3e.5); null = closed. Held
/// in core so every screen can open a task without importing the editor.

abstract class _$EditingTask extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
