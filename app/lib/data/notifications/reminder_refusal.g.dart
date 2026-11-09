// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_refusal.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// See [Refusal]. Never persisted; a refusal not shown yet is dropped at
/// the next change of owner, and one from an ended session is never taken.

@ProviderFor(ReminderRefusal)
final reminderRefusalProvider = ReminderRefusalProvider._();

/// See [Refusal]. Never persisted; a refusal not shown yet is dropped at
/// the next change of owner, and one from an ended session is never taken.
final class ReminderRefusalProvider
    extends $NotifierProvider<ReminderRefusal, Refusal?> {
  /// See [Refusal]. Never persisted; a refusal not shown yet is dropped at
  /// the next change of owner, and one from an ended session is never taken.
  ReminderRefusalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderRefusalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderRefusalHash();

  @$internal
  @override
  ReminderRefusal create() => ReminderRefusal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Refusal? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Refusal?>(value),
    );
  }
}

String _$reminderRefusalHash() => r'90093eacbd9a2b8e5d580a1ee4352a3c17905399';

/// See [Refusal]. Never persisted; a refusal not shown yet is dropped at
/// the next change of owner, and one from an ended session is never taken.

abstract class _$ReminderRefusal extends $Notifier<Refusal?> {
  Refusal? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Refusal?, Refusal?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Refusal?, Refusal?>,
              Refusal?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Open D1 dialogs (CR-160 §4, wider windows). The root's SnackBar would
/// sit under a dialog's barrier, unseen and never announced, so while one
/// is open it shows reminder refusals in its own error line instead.

@ProviderFor(refusalDialogs)
final refusalDialogsProvider = RefusalDialogsProvider._();

/// Open D1 dialogs (CR-160 §4, wider windows). The root's SnackBar would
/// sit under a dialog's barrier, unseen and never announced, so while one
/// is open it shows reminder refusals in its own error line instead.

final class RefusalDialogsProvider
    extends $FunctionalProvider<RefusalDialogs, RefusalDialogs, RefusalDialogs>
    with $Provider<RefusalDialogs> {
  /// Open D1 dialogs (CR-160 §4, wider windows). The root's SnackBar would
  /// sit under a dialog's barrier, unseen and never announced, so while one
  /// is open it shows reminder refusals in its own error line instead.
  RefusalDialogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refusalDialogsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refusalDialogsHash();

  @$internal
  @override
  $ProviderElement<RefusalDialogs> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RefusalDialogs create(Ref ref) {
    return refusalDialogs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefusalDialogs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefusalDialogs>(value),
    );
  }
}

String _$refusalDialogsHash() => r'90c0081fc39892965326fe854f47f13e80554304';
