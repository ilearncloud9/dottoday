// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Past days over the last twelve months, live from the local tasks
/// (derived on read: no table, no migration; owner, 2026-10-25).
/// Dependencies are read synchronously (see `timelineData`).

@ProviderFor(pastDays)
final pastDaysProvider = PastDaysProvider._();

/// Past days over the last twelve months, live from the local tasks
/// (derived on read: no table, no migration; owner, 2026-10-25).
/// Dependencies are read synchronously (see `timelineData`).

final class PastDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<JournalData>,
          JournalData,
          Stream<JournalData>
        >
    with $FutureModifier<JournalData>, $StreamProvider<JournalData> {
  /// Past days over the last twelve months, live from the local tasks
  /// (derived on read: no table, no migration; owner, 2026-10-25).
  /// Dependencies are read synchronously (see `timelineData`).
  PastDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastDaysHash();

  @$internal
  @override
  $StreamProviderElement<JournalData> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<JournalData> create(Ref ref) {
    return pastDays(ref);
  }
}

String _$pastDaysHash() => r'da36a741ed881eb9b233f8c464b00047e6fbc698';
