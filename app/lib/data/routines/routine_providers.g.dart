// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's routines in their order (11 C2, docs/09 M11.4), live. Read
/// by the Routines page and Add › Suggestions.

@ProviderFor(routines)
final routinesProvider = RoutinesProvider._();

/// The user's routines in their order (11 C2, docs/09 M11.4), live. Read
/// by the Routines page and Add › Suggestions.

final class RoutinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Routine>>,
          List<Routine>,
          Stream<List<Routine>>
        >
    with $FutureModifier<List<Routine>>, $StreamProvider<List<Routine>> {
  /// The user's routines in their order (11 C2, docs/09 M11.4), live. Read
  /// by the Routines page and Add › Suggestions.
  RoutinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routinesHash();

  @$internal
  @override
  $StreamProviderElement<List<Routine>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Routine>> create(Ref ref) {
    return routines(ref);
  }
}

String _$routinesHash() => r'b30f9a06d988d92df09c135629e6395859b51fa6';
