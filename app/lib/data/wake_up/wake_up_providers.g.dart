// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wake_up_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The occurrence id of today's one thing (docs/15 §8), or null: none
/// picked, or picked on another day (it clears when the day ends). Every
/// surface that rings it reads this, so they agree.

@ProviderFor(todayOneThingId)
final todayOneThingIdProvider = TodayOneThingIdProvider._();

/// The occurrence id of today's one thing (docs/15 §8), or null: none
/// picked, or picked on another day (it clears when the day ends). Every
/// surface that rings it reads this, so they agree.

final class TodayOneThingIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The occurrence id of today's one thing (docs/15 §8), or null: none
  /// picked, or picked on another day (it clears when the day ends). Every
  /// surface that rings it reads this, so they agree.
  TodayOneThingIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayOneThingIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayOneThingIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return todayOneThingId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$todayOneThingIdHash() => r'8a94f660fbe6346a4054e69f35fde23ff39ed293';

/// The learned Wind Down offer due now (docs/15 §7b): how long after Wake
/// Up the user usually gets up on this phone, and the minutes Wind Down
/// would move earlier; null when it isn't due.

@ProviderFor(learnedWindDownOffer)
final learnedWindDownOfferProvider = LearnedWindDownOfferProvider._();

/// The learned Wind Down offer due now (docs/15 §7b): how long after Wake
/// Up the user usually gets up on this phone, and the minutes Wind Down
/// would move earlier; null when it isn't due.

final class LearnedWindDownOfferProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int more, int usual})?>,
          ({int more, int usual})?,
          FutureOr<({int more, int usual})?>
        >
    with
        $FutureModifier<({int more, int usual})?>,
        $FutureProvider<({int more, int usual})?> {
  /// The learned Wind Down offer due now (docs/15 §7b): how long after Wake
  /// Up the user usually gets up on this phone, and the minutes Wind Down
  /// would move earlier; null when it isn't due.
  LearnedWindDownOfferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learnedWindDownOfferProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learnedWindDownOfferHash();

  @$internal
  @override
  $FutureProviderElement<({int more, int usual})?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({int more, int usual})?> create(Ref ref) {
    return learnedWindDownOffer(ref);
  }
}

String _$learnedWindDownOfferHash() =>
    r'e8ff06c3f17c716e245f73450f9622b3f2b9b581';

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

/// Whether this device can run [kind] now (15 §8), re-read when Settings
/// asks for a permission.

@ProviderFor(missionSupport)
final missionSupportProvider = MissionSupportFamily._();

/// Whether this device can run [kind] now (15 §8), re-read when Settings
/// asks for a permission.

final class MissionSupportProvider
    extends
        $FunctionalProvider<
          AsyncValue<MissionSupport>,
          MissionSupport,
          FutureOr<MissionSupport>
        >
    with $FutureModifier<MissionSupport>, $FutureProvider<MissionSupport> {
  /// Whether this device can run [kind] now (15 §8), re-read when Settings
  /// asks for a permission.
  MissionSupportProvider._({
    required MissionSupportFamily super.from,
    required MissionKind super.argument,
  }) : super(
         retry: null,
         name: r'missionSupportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$missionSupportHash();

  @override
  String toString() {
    return r'missionSupportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MissionSupport> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MissionSupport> create(Ref ref) {
    final argument = this.argument as MissionKind;
    return missionSupport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MissionSupportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$missionSupportHash() => r'01e9bc7cd84b1cb5b8201048cb42712234f6ba47';

/// Whether this device can run [kind] now (15 §8), re-read when Settings
/// asks for a permission.

final class MissionSupportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MissionSupport>, MissionKind> {
  MissionSupportFamily._()
    : super(
        retry: null,
        name: r'missionSupportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether this device can run [kind] now (15 §8), re-read when Settings
  /// asks for a permission.

  MissionSupportProvider call(MissionKind kind) =>
      MissionSupportProvider._(argument: kind, from: this);

  @override
  String toString() => r'missionSupportProvider';
}

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

String _$alarmEventsDrainHash() => r'9bdddbff7e805460811a8c791342f0424f6349a6';

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
