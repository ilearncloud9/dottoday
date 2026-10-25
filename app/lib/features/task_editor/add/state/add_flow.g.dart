// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_flow.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's habits from the last [habitHistoryDays] days (docs/10 §6
/// "Suggestions come from the user's own history"), live.

@ProviderFor(habits)
final habitsProvider = HabitsProvider._();

/// The user's habits from the last [habitHistoryDays] days (docs/10 §6
/// "Suggestions come from the user's own history"), live.

final class HabitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitSuggestion>>,
          List<HabitSuggestion>,
          Stream<List<HabitSuggestion>>
        >
    with
        $FutureModifier<List<HabitSuggestion>>,
        $StreamProvider<List<HabitSuggestion>> {
  /// The user's habits from the last [habitHistoryDays] days (docs/10 §6
  /// "Suggestions come from the user's own history"), live.
  HabitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitsHash();

  @$internal
  @override
  $StreamProviderElement<List<HabitSuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitSuggestion>> create(Ref ref) {
    return habits(ref);
  }
}

String _$habitsHash() => r'c452fb1f499f5a48290aa2400f4f4e5de74d2eb7';

/// The Add sheet's draft (M3c). One per open sheet; disposed with it.

@ProviderFor(AddFlow)
final addFlowProvider = AddFlowFamily._();

/// The Add sheet's draft (M3c). One per open sheet; disposed with it.
final class AddFlowProvider
    extends $AsyncNotifierProvider<AddFlow, AddFlowState> {
  /// The Add sheet's draft (M3c). One per open sheet; disposed with it.
  AddFlowProvider._({
    required AddFlowFamily super.from,
    required AddRequest super.argument,
  }) : super(
         retry: null,
         name: r'addFlowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addFlowHash();

  @override
  String toString() {
    return r'addFlowProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddFlow create() => AddFlow();

  @override
  bool operator ==(Object other) {
    return other is AddFlowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addFlowHash() => r'0672a6ebea23d10eb7e3ed372f0d7a34aadf04b0';

/// The Add sheet's draft (M3c). One per open sheet; disposed with it.

final class AddFlowFamily extends $Family
    with
        $ClassFamilyOverride<
          AddFlow,
          AsyncValue<AddFlowState>,
          AddFlowState,
          FutureOr<AddFlowState>,
          AddRequest
        > {
  AddFlowFamily._()
    : super(
        retry: null,
        name: r'addFlowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The Add sheet's draft (M3c). One per open sheet; disposed with it.

  AddFlowProvider call(AddRequest request) =>
      AddFlowProvider._(argument: request, from: this);

  @override
  String toString() => r'addFlowProvider';
}

/// The Add sheet's draft (M3c). One per open sheet; disposed with it.

abstract class _$AddFlow extends $AsyncNotifier<AddFlowState> {
  late final _$args = ref.$arg as AddRequest;
  AddRequest get request => _$args;

  FutureOr<AddFlowState> build(AddRequest request);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AddFlowState>, AddFlowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AddFlowState>, AddFlowState>,
              AsyncValue<AddFlowState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
