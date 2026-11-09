// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_refusal.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A reminder's Done, Snooze or +15 that was refused while an account
/// deletion ran (CR-160 policy §4): the app root shows [AppFailure]'s
/// generic message, so a tap never looks like it worked. Carries no task
/// or account detail.

@ProviderFor(ReminderRefusal)
final reminderRefusalProvider = ReminderRefusalProvider._();

/// A reminder's Done, Snooze or +15 that was refused while an account
/// deletion ran (CR-160 policy §4): the app root shows [AppFailure]'s
/// generic message, so a tap never looks like it worked. Carries no task
/// or account detail.
final class ReminderRefusalProvider
    extends
        $NotifierProvider<ReminderRefusal, ({AppFailure failure, int seq})?> {
  /// A reminder's Done, Snooze or +15 that was refused while an account
  /// deletion ran (CR-160 policy §4): the app root shows [AppFailure]'s
  /// generic message, so a tap never looks like it worked. Carries no task
  /// or account detail.
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
/// deletion ran (CR-160 policy §4): the app root shows [AppFailure]'s
/// generic message, so a tap never looks like it worked. Carries no task
/// or account detail.

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
