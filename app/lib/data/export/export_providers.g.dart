// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Share sheet, save dialog and file picker. Tests override with a fake.

@ProviderFor(fileGateway)
final fileGatewayProvider = FileGatewayProvider._();

/// Share sheet, save dialog and file picker. Tests override with a fake.

final class FileGatewayProvider
    extends $FunctionalProvider<FileGateway, FileGateway, FileGateway>
    with $Provider<FileGateway> {
  /// Share sheet, save dialog and file picker. Tests override with a fake.
  FileGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileGatewayHash();

  @$internal
  @override
  $ProviderElement<FileGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileGateway create(Ref ref) {
    return fileGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileGateway>(value),
    );
  }
}

String _$fileGatewayHash() => r'5b450e0b379d530fd8563342d55ea46cb9d721e8';

@ProviderFor(exportService)
final exportServiceProvider = ExportServiceProvider._();

final class ExportServiceProvider
    extends $FunctionalProvider<ExportService, ExportService, ExportService>
    with $Provider<ExportService> {
  ExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportServiceHash();

  @$internal
  @override
  $ProviderElement<ExportService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExportService create(Ref ref) {
    return exportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportService>(value),
    );
  }
}

String _$exportServiceHash() => r'48e0c3d696bdf5023c1774066ffd78d327622e22';
