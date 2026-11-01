// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wake_up_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The sensors the missions read (docs/15 §8); tests override it.

@ProviderFor(missionSensors)
final missionSensorsProvider = MissionSensorsProvider._();

/// The sensors the missions read (docs/15 §8); tests override it.

final class MissionSensorsProvider
    extends $FunctionalProvider<MissionSensors, MissionSensors, MissionSensors>
    with $Provider<MissionSensors> {
  /// The sensors the missions read (docs/15 §8); tests override it.
  MissionSensorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionSensorsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionSensorsHash();

  @$internal
  @override
  $ProviderElement<MissionSensors> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MissionSensors create(Ref ref) {
    return missionSensors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MissionSensors value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MissionSensors>(value),
    );
  }
}

String _$missionSensorsHash() => r'1f3af2a30c5704b92683a86ac3a118e3e85efd64';

/// Today's row on this device, null until the alarm or the card did
/// something (docs/15 §3, M17.3).

@ProviderFor(wakeUpToday)
final wakeUpTodayProvider = WakeUpTodayProvider._();

/// Today's row on this device, null until the alarm or the card did
/// something (docs/15 §3, M17.3).

final class WakeUpTodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<WakeUpDay?>,
          WakeUpDay?,
          Stream<WakeUpDay?>
        >
    with $FutureModifier<WakeUpDay?>, $StreamProvider<WakeUpDay?> {
  /// Today's row on this device, null until the alarm or the card did
  /// something (docs/15 §3, M17.3).
  WakeUpTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wakeUpTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wakeUpTodayHash();

  @$internal
  @override
  $StreamProviderElement<WakeUpDay?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<WakeUpDay?> create(Ref ref) {
    return wakeUpToday(ref);
  }
}

String _$wakeUpTodayHash() => r'b2935d649d596f60aab9de45d7afaeb77185c992';

/// The newest morning the alarm rang or was stopped on this device, for
/// Notification health's "Last wake-up" line (docs/15 §4).

@ProviderFor(lastWakeUp)
final lastWakeUpProvider = LastWakeUpProvider._();

/// The newest morning the alarm rang or was stopped on this device, for
/// Notification health's "Last wake-up" line (docs/15 §4).

final class LastWakeUpProvider
    extends
        $FunctionalProvider<
          AsyncValue<WakeUpDay?>,
          WakeUpDay?,
          FutureOr<WakeUpDay?>
        >
    with $FutureModifier<WakeUpDay?>, $FutureProvider<WakeUpDay?> {
  /// The newest morning the alarm rang or was stopped on this device, for
  /// Notification health's "Last wake-up" line (docs/15 §4).
  LastWakeUpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastWakeUpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastWakeUpHash();

  @$internal
  @override
  $FutureProviderElement<WakeUpDay?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<WakeUpDay?> create(Ref ref) {
    return lastWakeUp(ref);
  }
}

String _$lastWakeUpHash() => r'3e1e17859d137d422190c5f376e204b0234d17d9';

/// Folds what the alarms did while the app was closed (rang, snoozed,
/// "I'm up") into `wake_up_days`: run on launch and every resume, before
/// Today decides whether the Wake Up card opens (M17.3).

@ProviderFor(AlarmEventsDrain)
final alarmEventsDrainProvider = AlarmEventsDrainProvider._();

/// Folds what the alarms did while the app was closed (rang, snoozed,
/// "I'm up") into `wake_up_days`: run on launch and every resume, before
/// Today decides whether the Wake Up card opens (M17.3).
final class AlarmEventsDrainProvider
    extends $NotifierProvider<AlarmEventsDrain, void> {
  /// Folds what the alarms did while the app was closed (rang, snoozed,
  /// "I'm up") into `wake_up_days`: run on launch and every resume, before
  /// Today decides whether the Wake Up card opens (M17.3).
  AlarmEventsDrainProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alarmEventsDrainProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alarmEventsDrainHash();

  @$internal
  @override
  AlarmEventsDrain create() => AlarmEventsDrain();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$alarmEventsDrainHash() => r'f09380da0c1c948d465598521a39f0e1181a37b6';

/// Folds what the alarms did while the app was closed (rang, snoozed,
/// "I'm up") into `wake_up_days`: run on launch and every resume, before
/// Today decides whether the Wake Up card opens (M17.3).

abstract class _$AlarmEventsDrain extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
