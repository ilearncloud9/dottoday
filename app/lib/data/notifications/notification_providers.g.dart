// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The plugin, one per app.

@ProviderFor(localNotificationsPlugin)
final localNotificationsPluginProvider = LocalNotificationsPluginProvider._();

/// The plugin, one per app.

final class LocalNotificationsPluginProvider
    extends
        $FunctionalProvider<
          FlutterLocalNotificationsPlugin,
          FlutterLocalNotificationsPlugin,
          FlutterLocalNotificationsPlugin
        >
    with $Provider<FlutterLocalNotificationsPlugin> {
  /// The plugin, one per app.
  LocalNotificationsPluginProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNotificationsPluginProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNotificationsPluginHash();

  @$internal
  @override
  $ProviderElement<FlutterLocalNotificationsPlugin> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterLocalNotificationsPlugin create(Ref ref) {
    return localNotificationsPlugin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterLocalNotificationsPlugin value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterLocalNotificationsPlugin>(
        value,
      ),
    );
  }
}

String _$localNotificationsPluginHash() =>
    r'c1cef212231ef607c2087a0d83df4ad9637c1af6';

/// Plays a bundled reminder sound in the app (picker preview, web strip).

@ProviderFor(soundPlayer)
final soundPlayerProvider = SoundPlayerProvider._();

/// Plays a bundled reminder sound in the app (picker preview, web strip).

final class SoundPlayerProvider
    extends $FunctionalProvider<SoundPlayer, SoundPlayer, SoundPlayer>
    with $Provider<SoundPlayer> {
  /// Plays a bundled reminder sound in the app (picker preview, web strip).
  SoundPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundPlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundPlayerHash();

  @$internal
  @override
  $ProviderElement<SoundPlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SoundPlayer create(Ref ref) {
    return soundPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoundPlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoundPlayer>(value),
    );
  }
}

String _$soundPlayerHash() => r'b81ef35325558f2c9231bd4c47bce2925f9566cf';

/// The scheduler under the gateway: the OS on iOS, Android and macOS; on
/// the web, timers while the tab is open, posting through the service
/// worker or the in-app banner (M5.3).

@ProviderFor(notificationPlatform)
final notificationPlatformProvider = NotificationPlatformProvider._();

/// The scheduler under the gateway: the OS on iOS, Android and macOS; on
/// the web, timers while the tab is open, posting through the service
/// worker or the in-app banner (M5.3).

final class NotificationPlatformProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationPlatform>,
          NotificationPlatform,
          FutureOr<NotificationPlatform>
        >
    with
        $FutureModifier<NotificationPlatform>,
        $FutureProvider<NotificationPlatform> {
  /// The scheduler under the gateway: the OS on iOS, Android and macOS; on
  /// the web, timers while the tab is open, posting through the service
  /// worker or the in-app banner (M5.3).
  NotificationPlatformProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPlatformProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPlatformHash();

  @$internal
  @override
  $FutureProviderElement<NotificationPlatform> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationPlatform> create(Ref ref) {
    return notificationPlatform(ref);
  }
}

String _$notificationPlatformHash() =>
    r'8fe31cffa4971b37b35ca5f0edc71a982c8726fe';

@ProviderFor(notificationResponder)
final notificationResponderProvider = NotificationResponderProvider._();

final class NotificationResponderProvider
    extends
        $FunctionalProvider<
          NotificationResponder,
          NotificationResponder,
          NotificationResponder
        >
    with $Provider<NotificationResponder> {
  NotificationResponderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationResponderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationResponderHash();

  @$internal
  @override
  $ProviderElement<NotificationResponder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationResponder create(Ref ref) {
    return notificationResponder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationResponder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationResponder>(value),
    );
  }
}

String _$notificationResponderHash() =>
    r'16ef0bc1027896656c9d77133d715fe1cecab948';

/// Initialises the platform once (channels, actions, the tap handler) and
/// handles the tap that launched the app. The gateway waits on this before
/// touching the OS.

@ProviderFor(notificationsStarted)
final notificationsStartedProvider = NotificationsStartedProvider._();

/// Initialises the platform once (channels, actions, the tap handler) and
/// handles the tap that launched the app. The gateway waits on this before
/// touching the OS.

final class NotificationsStartedProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationPlatform>,
          NotificationPlatform,
          FutureOr<NotificationPlatform>
        >
    with
        $FutureModifier<NotificationPlatform>,
        $FutureProvider<NotificationPlatform> {
  /// Initialises the platform once (channels, actions, the tap handler) and
  /// handles the tap that launched the app. The gateway waits on this before
  /// touching the OS.
  NotificationsStartedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsStartedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsStartedHash();

  @$internal
  @override
  $FutureProviderElement<NotificationPlatform> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationPlatform> create(Ref ref) {
    return notificationsStarted(ref);
  }
}

String _$notificationsStartedHash() =>
    r'6bb50a63b24f41186d941ccb04715632b2abfa64';
