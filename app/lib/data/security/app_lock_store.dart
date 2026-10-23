import 'dart:convert';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/security/device_auth.dart';
import 'package:dottoday/data/security/secure_window.dart';
import 'package:dottoday/domain/security/app_lock.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lock_store.g.dart';

/// Whether this platform can lock the app (docs/06 §2, M5.8): iOS,
/// Android and macOS; the web has no device check to ask.
bool get appLockSupported =>
    !kIsWeb &&
    {
      TargetPlatform.iOS,
      TargetPlatform.android,
      TargetPlatform.macOS,
    }.contains(defaultTargetPlatform);

@Riverpod(keepAlive: true)
DeviceAuth deviceAuth(Ref ref) => LocalDeviceAuth();

/// The app-lock setting, kept in `local_meta` on this device only.
@Riverpod(keepAlive: true)
class AppLockSetting extends _$AppLockSetting {
  static const _key = 'app_lock';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<AppLockSettings> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    final settings = row == null
        ? const AppLockSettings()
        : AppLockSettings.fromJson(jsonDecode(row.value));
    await ref.read(secureWindowProvider).set(secure: settings.enabled);
    return settings;
  }

  /// Saves [settings]; turning the lock on asks first, so nobody locks
  /// themselves out of a device that can't ask. False if that failed.
  Future<bool> save(AppLockSettings settings, {required String reason}) async {
    final turningOn = settings.enabled && !(state.value?.enabled ?? false);
    if (turningOn && !await ref.read(deviceAuthProvider).authenticate(reason)) {
      return false;
    }
    state = AsyncData(settings);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(
            key: _key,
            value: jsonEncode(settings.toJson()),
          ),
        );
    await ref.read(secureWindowProvider).set(secure: settings.enabled);
    return true;
  }
}

/// Whether the app is locked now: at start when the lock is on, and again
/// on return after the chosen delay (docs/06 §2, M5.8).
@Riverpod(keepAlive: true)
class AppLocked extends _$AppLocked {
  DateTime? _leftUtc;
  var _unlocked = false;

  /// The setting as first loaded; later changes come from Settings.
  bool? _loaded;

  @override
  bool build() {
    final enabled = ref.watch(appLockSettingProvider).value?.enabled;
    if (enabled == null) return false;
    // On at launch: locked. Turned on in Settings: they just passed the
    // check, so it locks next time, not now.
    if (_loaded == null) {
      _loaded = enabled;
    } else if (enabled && !_loaded!) {
      _unlocked = true;
    }
    return enabled && !_unlocked;
  }

  /// The app went to the background (not because our own prompt is up:
  /// Android's PIN screen pauses the app, found on the emulator, M5.8).
  void left() {
    if (ref.read(deviceAuthProvider).asking) return;
    _leftUtc = ref.read(clockProvider).nowUtc();
  }

  /// The app came back: lock again if it was away long enough.
  void returned() {
    final settings = ref.read(appLockSettingProvider).value;
    final left = _leftUtc;
    _leftUtc = null;
    // Nothing recorded: back from our own prompt, or never left.
    if (settings == null || left == null) return;
    final now = ref.read(clockProvider).nowUtc();
    if (!shouldRelock(settings, leftUtc: left, nowUtc: now)) return;
    _unlocked = false;
    state = true;
  }

  /// Asks the device; unlocks when the person passes.
  Future<void> unlock(String reason) async {
    if (!await ref.read(deviceAuthProvider).authenticate(reason)) return;
    markUnlocked();
  }

  /// The person just proved it's them (unlocking, or turning the lock on).
  void markUnlocked() {
    _unlocked = true;
    state = false;
  }
}
