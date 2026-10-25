// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whats_new_seen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The newest version whose notes this device has seen (PRD F11, R-19),
/// kept in `local_meta` (per device, never synced: each device updates on
/// its own). The first run records the running version, so a fresh install
/// never hears about "what's new".

@ProviderFor(WhatsNewSeen)
final whatsNewSeenProvider = WhatsNewSeenProvider._();

/// The newest version whose notes this device has seen (PRD F11, R-19),
/// kept in `local_meta` (per device, never synced: each device updates on
/// its own). The first run records the running version, so a fresh install
/// never hears about "what's new".
final class WhatsNewSeenProvider
    extends $AsyncNotifierProvider<WhatsNewSeen, String> {
  /// The newest version whose notes this device has seen (PRD F11, R-19),
  /// kept in `local_meta` (per device, never synced: each device updates on
  /// its own). The first run records the running version, so a fresh install
  /// never hears about "what's new".
  WhatsNewSeenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsNewSeenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsNewSeenHash();

  @$internal
  @override
  WhatsNewSeen create() => WhatsNewSeen();
}

String _$whatsNewSeenHash() => r'4ce11c2b8f9630335478d0bb2883a975e4c1086b';

/// The newest version whose notes this device has seen (PRD F11, R-19),
/// kept in `local_meta` (per device, never synced: each device updates on
/// its own). The first run records the running version, so a fresh install
/// never hears about "what's new".

abstract class _$WhatsNewSeen extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Releases this device hasn't seen the notes of, newest first; empty
/// while loading, on a fresh install or when up to date.

@ProviderFor(unseenReleasesNow)
final unseenReleasesNowProvider = UnseenReleasesNowProvider._();

/// Releases this device hasn't seen the notes of, newest first; empty
/// while loading, on a fresh install or when up to date.

final class UnseenReleasesNowProvider
    extends $FunctionalProvider<List<Release>, List<Release>, List<Release>>
    with $Provider<List<Release>> {
  /// Releases this device hasn't seen the notes of, newest first; empty
  /// while loading, on a fresh install or when up to date.
  UnseenReleasesNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unseenReleasesNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unseenReleasesNowHash();

  @$internal
  @override
  $ProviderElement<List<Release>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Release> create(Ref ref) {
    return unseenReleasesNow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Release> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Release>>(value),
    );
  }
}

String _$unseenReleasesNowHash() => r'b76acf583abffcfae8470c447c9cbd0112599b92';
