import 'dart:async';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:flutter/widgets.dart';

/// The in-app strip in the apps (E-R2-20 "In the app, while Dottoday is
/// open (every platform)", ED-317, ED-468): while the app is on screen,
/// each pending reminder the strip shows ([OsNotification.stripWhileOpen])
/// is shown in it at its time. On iPhone and the Mac the OS still delivers
/// it, to Notification Center with its sound, but holds its banner back
/// while the app is in front (`presentBanner`), so it is seen once. In the
/// background nothing is timed here and the OS shows it as always.
final class ForegroundStrip with WidgetsBindingObserver {
  ForegroundStrip({
    required Future<List<OsNotification>> Function() pending,
    required void Function(OsNotification n) show,
    required Clock clock,
  }) : _pending = pending,
       _show = show,
       _clock = clock;

  final Future<List<OsNotification>> Function() _pending;
  final void Function(OsNotification n) _show;
  final Clock _clock;
  final _timers = <Timer>[];

  /// Bumped by every refresh, so an older one's late answer times nothing.
  var _generation = 0;
  var _open = false;

  /// Starts following the app's lifecycle; times what is pending if the app
  /// is on screen now.
  void attach() {
    WidgetsBinding.instance.addObserver(this);
    _open = _onScreen(WidgetsBinding.instance.lifecycleState);
    unawaited(refresh());
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _open = _onScreen(state);
    if (_open) {
      unawaited(refresh());
    } else {
      _clear();
    }
  }

  /// In front or still on screen: inactive is the app showing under a
  /// system sheet or prompt, where the OS also holds its banner back.
  static bool _onScreen(AppLifecycleState? state) =>
      state == null ||
      state == AppLifecycleState.resumed ||
      state == AppLifecycleState.inactive;

  /// Times the pending reminders again: the app came to the front, or the
  /// schedule changed.
  Future<void> refresh() async {
    _clear();
    if (!_open) return;
    final generation = ++_generation;
    final pending = await _pending();
    if (generation != _generation || !_open) return;
    final now = _clock.nowUtc();
    for (final n in pending) {
      if (!n.stripWhileOpen || !n.fireAtUtc.isAfter(now)) continue;
      _timers.add(
        Timer(n.fireAtUtc.difference(now), () {
          if (_open) _show(n);
        }),
      );
    }
  }

  void _clear() {
    _generation++;
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }
}

/// [inner] with [strip] timed again after every change to the schedule.
final class StripTimedPlatform implements NotificationPlatform {
  StripTimedPlatform(this.inner, this.strip);

  final NotificationPlatform inner;
  final ForegroundStrip strip;

  @override
  Future<void> initialize(void Function(NotificationTap) onTap) =>
      inner.initialize(onTap);

  @override
  Future<NotificationTap?> launchTap() => inner.launchTap();

  @override
  Future<List<(int, String?)>> pending() => inner.pending();

  @override
  Future<void> cancel(int id) async {
    await inner.cancel(id);
    _changed();
  }

  @override
  Future<void> schedule(OsNotification n) async {
    await inner.schedule(n);
    _changed();
  }

  @override
  Future<void> clearAll() async {
    await inner.clearAll();
    _changed();
  }

  @override
  Future<Set<String>> mutedSoundIds() => inner.mutedSoundIds();

  /// One refresh after a burst of changes (a resync schedules many).
  var _queued = false;
  void _changed() {
    if (_queued) return;
    _queued = true;
    scheduleMicrotask(() {
      _queued = false;
      unawaited(strip.refresh());
    });
  }
}
