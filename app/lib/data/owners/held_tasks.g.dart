// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'held_tasks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tasks an old build gave the wrong account, held on this device
/// (CR-160 blocker 8): Settings › Account says so when there are any.

@ProviderFor(heldTasks)
final heldTasksProvider = HeldTasksProvider._();

/// Tasks an old build gave the wrong account, held on this device
/// (CR-160 blocker 8): Settings › Account says so when there are any.

final class HeldTasksProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Tasks an old build gave the wrong account, held on this device
  /// (CR-160 blocker 8): Settings › Account says so when there are any.
  HeldTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heldTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heldTasksHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return heldTasks(ref);
  }
}

String _$heldTasksHash() => r'bec2b9b80abef70858f4d5d5db3676ebb5448bca';
