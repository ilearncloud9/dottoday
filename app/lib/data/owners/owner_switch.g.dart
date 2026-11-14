// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_switch.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Moves on at every change of the owner the app shows (CR-160 I1, I5):
/// sign-in as another owner, sign-out, account removal. Every provider that
/// holds one owner's state (open editors, focus, proposals, undo, caches)
/// watches it, so nothing of the previous owner survives a switch, however
/// late a callback or a rebuild comes.

@ProviderFor(OwnerEpoch)
final ownerEpochProvider = OwnerEpochProvider._();

/// Moves on at every change of the owner the app shows (CR-160 I1, I5):
/// sign-in as another owner, sign-out, account removal. Every provider that
/// holds one owner's state (open editors, focus, proposals, undo, caches)
/// watches it, so nothing of the previous owner survives a switch, however
/// late a callback or a rebuild comes.
final class OwnerEpochProvider extends $NotifierProvider<OwnerEpoch, int> {
  /// Moves on at every change of the owner the app shows (CR-160 I1, I5):
  /// sign-in as another owner, sign-out, account removal. Every provider that
  /// holds one owner's state (open editors, focus, proposals, undo, caches)
  /// watches it, so nothing of the previous owner survives a switch, however
  /// late a callback or a rebuild comes.
  OwnerEpochProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownerEpochProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownerEpochHash();

  @$internal
  @override
  OwnerEpoch create() => OwnerEpoch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$ownerEpochHash() => r'2bd366b5344ab2dc39d321d297a7895c54dca4eb';

/// Moves on at every change of the owner the app shows (CR-160 I1, I5):
/// sign-in as another owner, sign-out, account removal. Every provider that
/// holds one owner's state (open editors, focus, proposals, undo, caches)
/// watches it, so nothing of the previous owner survives a switch, however
/// late a callback or a rebuild comes.

abstract class _$OwnerEpoch extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The one place a change of owner happens on this device (CR-160 policy
/// §2, I1–I8). Every step runs in order; the visible app is invalidated
/// before anything else can read the old owner again.

@ProviderFor(ownerSwitch)
final ownerSwitchProvider = OwnerSwitchProvider._();

/// The one place a change of owner happens on this device (CR-160 policy
/// §2, I1–I8). Every step runs in order; the visible app is invalidated
/// before anything else can read the old owner again.

final class OwnerSwitchProvider
    extends $FunctionalProvider<OwnerSwitch, OwnerSwitch, OwnerSwitch>
    with $Provider<OwnerSwitch> {
  /// The one place a change of owner happens on this device (CR-160 policy
  /// §2, I1–I8). Every step runs in order; the visible app is invalidated
  /// before anything else can read the old owner again.
  OwnerSwitchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownerSwitchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownerSwitchHash();

  @$internal
  @override
  $ProviderElement<OwnerSwitch> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OwnerSwitch create(Ref ref) {
    return ownerSwitch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OwnerSwitch value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OwnerSwitch>(value),
    );
  }
}

String _$ownerSwitchHash() => r'ce68fdb74ced85ee8dc095da8c3a4ebfb2475363';
