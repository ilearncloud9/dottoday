// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_refusal.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A reminder's Done, Snooze or +15 that was refused while an account
/// deletion ran (CR-160 policy §4): its generic message is shown — by an
/// open D1 dialog itself, else by the app root — so a tap never looks like
/// it worked. Carries no task or account detail.

@ProviderFor(ReminderRefusal)
final reminderRefusalProvider = ReminderRefusalProvider._();

/// A reminder's Done, Snooze or +15 that was refused while an account
/// deletion ran (CR-160 policy §4): its generic message is shown — by an
/// open D1 dialog itself, else by the app root — so a tap never looks like
/// it worked. Carries no task or account detail.
final class ReminderRefusalProvider
    extends
        $NotifierProvider<ReminderRefusal, ({AppFailure failure, int seq})?> {
  /// A reminder's Done, Snooze or +15 that was refused while an account
  /// deletion ran (CR-160 policy §4): its generic message is shown — by an
  /// open D1 dialog itself, else by the app root — so a tap never looks like
  /// it worked. Carries no task or account detail.
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
  Override overrideWithValue(({AppFailure failure, int seq})? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({AppFailure failure, int seq})?>(
        value,
      ),
    );
  }
}

String _$reminderRefusalHash() => r'52c26be98895d3ed27039cde2b82c3b5efdf8dd6';

/// A reminder's Done, Snooze or +15 that was refused while an account
/// deletion ran (CR-160 policy §4): its generic message is shown — by an
/// open D1 dialog itself, else by the app root — so a tap never looks like
/// it worked. Carries no task or account detail.

abstract class _$ReminderRefusal
    extends $Notifier<({AppFailure failure, int seq})?> {
  ({AppFailure failure, int seq})? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({AppFailure failure, int seq})?,
              ({AppFailure failure, int seq})?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({AppFailure failure, int seq})?,
                ({AppFailure failure, int seq})?
              >,
              ({AppFailure failure, int seq})?,
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
