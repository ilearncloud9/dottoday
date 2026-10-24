// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the imported event linked by [linkId] happens (docs/09 M7.5,
/// R-17), as its calendar gave it at the last import; null without a
/// place or once the link is gone. Read on this device only.

@ProviderFor(calendarEventLocation)
final calendarEventLocationProvider = CalendarEventLocationFamily._();

/// Where the imported event linked by [linkId] happens (docs/09 M7.5,
/// R-17), as its calendar gave it at the last import; null without a
/// place or once the link is gone. Read on this device only.

final class CalendarEventLocationProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// Where the imported event linked by [linkId] happens (docs/09 M7.5,
  /// R-17), as its calendar gave it at the last import; null without a
  /// place or once the link is gone. Read on this device only.
  CalendarEventLocationProvider._({
    required CalendarEventLocationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'calendarEventLocationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarEventLocationHash();

  @override
  String toString() {
    return r'calendarEventLocationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as String;
    return calendarEventLocation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventLocationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarEventLocationHash() =>
    r'f53f74af47bee8c83a484b0da47e1611c265c62e';

/// Where the imported event linked by [linkId] happens (docs/09 M7.5,
/// R-17), as its calendar gave it at the last import; null without a
/// place or once the link is gone. Read on this device only.

final class CalendarEventLocationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, String> {
  CalendarEventLocationFamily._()
    : super(
        retry: null,
        name: r'calendarEventLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Where the imported event linked by [linkId] happens (docs/09 M7.5,
  /// R-17), as its calendar gave it at the last import; null without a
  /// place or once the link is gone. Read on this device only.

  CalendarEventLocationProvider call(String linkId) =>
      CalendarEventLocationProvider._(argument: linkId, from: this);

  @override
  String toString() => r'calendarEventLocationProvider';
}
