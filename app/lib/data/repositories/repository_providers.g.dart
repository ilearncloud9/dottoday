// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(occurrenceRepository)
final occurrenceRepositoryProvider = OccurrenceRepositoryProvider._();

final class OccurrenceRepositoryProvider
    extends
        $FunctionalProvider<
          OccurrenceRepository,
          OccurrenceRepository,
          OccurrenceRepository
        >
    with $Provider<OccurrenceRepository> {
  OccurrenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'occurrenceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$occurrenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<OccurrenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OccurrenceRepository create(Ref ref) {
    return occurrenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OccurrenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OccurrenceRepository>(value),
    );
  }
}

String _$occurrenceRepositoryHash() =>
    r'ac297037922cd1ec9e349e20f07c0c6a345c100b';

@ProviderFor(seriesRepository)
final seriesRepositoryProvider = SeriesRepositoryProvider._();

final class SeriesRepositoryProvider
    extends
        $FunctionalProvider<
          SeriesRepository,
          SeriesRepository,
          SeriesRepository
        >
    with $Provider<SeriesRepository> {
  SeriesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seriesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seriesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SeriesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SeriesRepository create(Ref ref) {
    return seriesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeriesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeriesRepository>(value),
    );
  }
}

String _$seriesRepositoryHash() => r'7e6ca6878a657b13470527634d603adecbf3f02a';

@ProviderFor(subtaskRepository)
final subtaskRepositoryProvider = SubtaskRepositoryProvider._();

final class SubtaskRepositoryProvider
    extends
        $FunctionalProvider<
          SubtaskRepository,
          SubtaskRepository,
          SubtaskRepository
        >
    with $Provider<SubtaskRepository> {
  SubtaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subtaskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subtaskRepositoryHash();

  @$internal
  @override
  $ProviderElement<SubtaskRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubtaskRepository create(Ref ref) {
    return subtaskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubtaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubtaskRepository>(value),
    );
  }
}

String _$subtaskRepositoryHash() => r'b1c4bc3a830ffd8b3e11ba7cdea0ac94771b901b';

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'0eda22c9c7a5e68c8661bf58b528d73264ef9a19';
