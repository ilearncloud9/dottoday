import 'dart:async';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';

/// Posts one notification now; false when it couldn't be shown (no
/// permission), so it goes to the in-app banner instead.
typedef ShowNotification = Future<bool> Function(OsNotification n);

/// A [NotificationPlatform] for the web while the tab is open (docs/07 Web
/// "in-app fallback", docs/09 M5.3): browsers can't schedule a local
/// notification ahead, so each pending one is a [Timer]. At its time it is
/// posted through the service worker, or, without permission, handed to
/// [onInApp] for the banner. Closing the tab drops the timers; the next
/// start re-plans (server push covers a closed tab once signed in).
final class TimerNotificationPlatform implements NotificationPlatform {
  TimerNotificationPlatform({
    required Clock clock,
    required ShowNotification show,
    required void Function(OsNotification n) onInApp,
    Stream<NotificationTap> taps = const Stream.empty(),
  }) : _clock = clock,
       _show = show,
       _onInApp = onInApp,
       _taps = taps;

  final Clock _clock;
  final ShowNotification _show;
  final void Function(OsNotification n) _onInApp;
  final Stream<NotificationTap> _taps;
  final _pending = <int, (OsNotification, Timer)>{};
  StreamSubscription<NotificationTap>? _tapSub;

  @override
  Future<void> initialize(void Function(NotificationTap) onTap) async {
    await _tapSub?.cancel();
    _tapSub = _taps.listen(onTap);
  }

  /// A web page is never launched by a notification tap; taps arrive as
  /// messages from the service worker instead.
  @override
  Future<NotificationTap?> launchTap() async => null;

  @override
  Future<List<(int, String?)>> pending() async => [
    for (final (n, _) in _pending.values) (n.id, n.payload),
  ];

  @override
  Future<void> cancel(int id) async => _pending.remove(id)?.$2.cancel();

  /// The browser has no per-sound channels to mute.
  @override
  Future<Set<String>> mutedSoundIds() async => const {};

  @override
  Future<void> schedule(OsNotification n) async {
    // Replaced in the same turn, so overlapping calls can't double a timer.
    _pending.remove(n.id)?.$2.cancel();
    final wait = n.fireAtUtc.difference(_clock.nowUtc());
    if (wait.isNegative) return;
    _pending[n.id] = (n, Timer(wait, () => _fire(n)));
  }

  Future<void> _fire(OsNotification n) async {
    _pending.remove(n.id);
    if (n.silent || !await _show(n)) _onInApp(n);
  }
}
