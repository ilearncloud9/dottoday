// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_ends.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dayEnds)
final dayEndsProvider = DayEndsFamily._();

final class DayEndsProvider
    extends $FunctionalProvider<AsyncValue<DayEnds>, DayEnds, FutureOr<DayEnds>>
    with $FutureModifier<DayEnds>, $FutureProvider<DayEnds> {
  DayEndsProvider._({
    required DayEndsFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'dayEndsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayEndsHash();

  @override
  String toString() {
    return r'dayEndsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DayEnds> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DayEnds> create(Ref ref) {
    final argument = this.argument as DateTime;
    return dayEnds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayEndsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayEndsHash() => r'2bd5f428313cc0aa0e58d2b5a1ee8aa9d008d0c8';

final class DayEndsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DayEnds>, DateTime> {
  DayEndsFamily._()
    : super(
        retry: null,
        name: r'dayEndsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DayEndsProvider call(DateTime date) =>
      DayEndsProvider._(argument: date, from: this);

  @override
  String toString() => r'dayEndsProvider';
}
