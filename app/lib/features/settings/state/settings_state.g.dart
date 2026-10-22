// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [userId]'s Trash, newest first (R-11).

@ProviderFor(trashItems)
final trashItemsProvider = TrashItemsFamily._();

/// [userId]'s Trash, newest first (R-11).

final class TrashItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Occurrence>>,
          List<Occurrence>,
          Stream<List<Occurrence>>
        >
    with $FutureModifier<List<Occurrence>>, $StreamProvider<List<Occurrence>> {
  /// [userId]'s Trash, newest first (R-11).
  TrashItemsProvider._({
    required TrashItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'trashItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trashItemsHash();

  @override
  String toString() {
    return r'trashItemsProvider'
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
    return trashItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrashItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trashItemsHash() => r'd911a65e5ba2ff93ceea130b48aa1ee55dfbb3b7';

/// [userId]'s Trash, newest first (R-11).

final class TrashItemsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Occurrence>>, String> {
  TrashItemsFamily._()
    : super(
        retry: null,
        name: r'trashItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [userId]'s Trash, newest first (R-11).

  TrashItemsProvider call(String userId) =>
      TrashItemsProvider._(argument: userId, from: this);

  @override
  String toString() => r'trashItemsProvider';
}
