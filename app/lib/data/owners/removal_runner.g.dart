// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'removal_runner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// On iPhone, Android and the Mac, a deleted account's removal that an
/// interruption left pending finishes by itself at launch (CR-160 policy
/// §4); a failure retries later, waiting twice as long each time up to
/// [_retryMax], and the copy stays hidden meanwhile. The web asks instead
/// ("Finish removing", the account gate). Watched by the account gate.

@ProviderFor(pendingRemovalRunner)
final pendingRemovalRunnerProvider = PendingRemovalRunnerProvider._();

/// On iPhone, Android and the Mac, a deleted account's removal that an
/// interruption left pending finishes by itself at launch (CR-160 policy
/// §4); a failure retries later, waiting twice as long each time up to
/// [_retryMax], and the copy stays hidden meanwhile. The web asks instead
/// ("Finish removing", the account gate). Watched by the account gate.

final class PendingRemovalRunnerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// On iPhone, Android and the Mac, a deleted account's removal that an
  /// interruption left pending finishes by itself at launch (CR-160 policy
  /// §4); a failure retries later, waiting twice as long each time up to
  /// [_retryMax], and the copy stays hidden meanwhile. The web asks instead
  /// ("Finish removing", the account gate). Watched by the account gate.
  PendingRemovalRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRemovalRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRemovalRunnerHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return pendingRemovalRunner(ref);
  }
}

String _$pendingRemovalRunnerHash() =>
    r'4343507eb13bdd24c2e35e83edd3bdca75faedb8';
