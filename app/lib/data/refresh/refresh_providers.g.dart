// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dailyRefresh)
final dailyRefreshProvider = DailyRefreshProvider._();

final class DailyRefreshProvider
    extends $FunctionalProvider<DailyRefresh, DailyRefresh, DailyRefresh>
    with $Provider<DailyRefresh> {
  DailyRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyRefreshProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyRefreshHash();

  @$internal
  @override
  $ProviderElement<DailyRefresh> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DailyRefresh create(Ref ref) {
    return dailyRefresh(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyRefresh value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyRefresh>(value),
    );
  }
}

String _$dailyRefreshHash() => r'eefb7d7d0a521d67ffb98d7fee2fecc6b38fd8b0';
