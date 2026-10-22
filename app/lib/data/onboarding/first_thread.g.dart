// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_thread.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tomorrow's tasks with its Wake Up and Bedtime, live.

@ProviderFor(firstThread)
final firstThreadProvider = FirstThreadProvider._();

/// Tomorrow's tasks with its Wake Up and Bedtime, live.

final class FirstThreadProvider
    extends
        $FunctionalProvider<
          AsyncValue<FirstThread>,
          FirstThread,
          Stream<FirstThread>
        >
    with $FutureModifier<FirstThread>, $StreamProvider<FirstThread> {
  /// Tomorrow's tasks with its Wake Up and Bedtime, live.
  FirstThreadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstThreadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstThreadHash();

  @$internal
  @override
  $StreamProviderElement<FirstThread> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<FirstThread> create(Ref ref) {
    return firstThread(ref);
  }
}

String _$firstThreadHash() => r'52e0622d4ca49fe4fc7e19dcc12f93985e06e506';
