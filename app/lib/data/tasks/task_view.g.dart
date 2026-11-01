// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The live task [id] of the current user, or null when there is none:
/// unknown, deleted or another user's id all read as not found (06 §9:
/// the id is looked up under the current user only).

@ProviderFor(taskView)
final taskViewProvider = TaskViewFamily._();

/// The live task [id] of the current user, or null when there is none:
/// unknown, deleted or another user's id all read as not found (06 §9:
/// the id is looked up under the current user only).

final class TaskViewProvider
    extends
        $FunctionalProvider<AsyncValue<TaskView?>, TaskView?, Stream<TaskView?>>
    with $FutureModifier<TaskView?>, $StreamProvider<TaskView?> {
  /// The live task [id] of the current user, or null when there is none:
  /// unknown, deleted or another user's id all read as not found (06 §9:
  /// the id is looked up under the current user only).
  TaskViewProvider._({
    required TaskViewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskViewHash();

  @override
  String toString() {
    return r'taskViewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<TaskView?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<TaskView?> create(Ref ref) {
    final argument = this.argument as String;
    return taskView(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskViewHash() => r'e41b208ff78fe6effc8077a2acd6cd41027a3457';

/// The live task [id] of the current user, or null when there is none:
/// unknown, deleted or another user's id all read as not found (06 §9:
/// the id is looked up under the current user only).

final class TaskViewFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TaskView?>, String> {
  TaskViewFamily._()
    : super(
        retry: null,
        name: r'taskViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The live task [id] of the current user, or null when there is none:
  /// unknown, deleted or another user's id all read as not found (06 §9:
  /// the id is looked up under the current user only).

  TaskViewProvider call(String id) =>
      TaskViewProvider._(argument: id, from: this);

  @override
  String toString() => r'taskViewProvider';
}
