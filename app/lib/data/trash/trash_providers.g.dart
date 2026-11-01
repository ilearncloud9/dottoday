// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trash_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide so a token from one screen can be redeemed by the snackbar.

@ProviderFor(undoService)
final undoServiceProvider = UndoServiceProvider._();

/// App-wide so a token from one screen can be redeemed by the snackbar.

final class UndoServiceProvider
    extends $FunctionalProvider<UndoService, UndoService, UndoService>
    with $Provider<UndoService> {
  /// App-wide so a token from one screen can be redeemed by the snackbar.
  UndoServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'undoServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$undoServiceHash();

  @$internal
  @override
  $ProviderElement<UndoService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UndoService create(Ref ref) {
    return undoService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UndoService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UndoService>(value),
    );
  }
}

String _$undoServiceHash() => r'6d1603fe43d2127508fd58eddafbdec1d8cc7bea';

@ProviderFor(trashService)
final trashServiceProvider = TrashServiceProvider._();

final class TrashServiceProvider
    extends $FunctionalProvider<TrashService, TrashService, TrashService>
    with $Provider<TrashService> {
  TrashServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trashServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trashServiceHash();

  @$internal
  @override
  $ProviderElement<TrashService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrashService create(Ref ref) {
    return trashService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrashService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrashService>(value),
    );
  }
}

String _$trashServiceHash() => r'bdab517d005e85a80f11fffb09e926d76a0874e7';
