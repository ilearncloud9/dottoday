import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/push/server_push_mirror.dart';
import 'package:dottoday/data/notifications/push/web_push_wiring.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/fake_clock.dart';
import '../../support/fake_notification_platform.dart';
import '../../support/memory_log_sink.dart';

final class _Granted implements NotificationPermission {
  @override
  Future<PermissionState> status() async => PermissionState.granted;
  @override
  Future<PermissionState> request() async => PermissionState.granted;
  @override
  Future<bool> openSettings() async => true;
}

// When the tab's reminders also go to the server (docs/09 M6.1, M5.3b).
void main() {
  final tab = FakeNotificationPlatform();
  final logger = Logger(MemoryLogSink(), FakeClock(DateTime.utc(2026)));
  final l10n = AppLocalizationsEn();

  test('no client or no VAPID key: the tab alone', () {
    final client = SupabaseClient('http://127.0.0.1:1', 'anon');
    addTearDown(client.dispose);
    for (final (c, key) in [(null, 'vapid'), (client, null)]) {
      expect(
        withServerPush(
          tab,
          client: c,
          vapidPublicKey: key,
          permission: _Granted(),
          l10n: l10n,
          logger: logger,
        ),
        same(tab),
      );
    }
  });

  test('a client and a key: mirrored to the server', () {
    final client = SupabaseClient('http://127.0.0.1:1', 'anon');
    addTearDown(client.dispose);
    expect(
      withServerPush(
        tab,
        client: client,
        vapidPublicKey: 'vapid',
        permission: _Granted(),
        l10n: l10n,
        logger: logger,
      ),
      isA<ServerPushMirror>(),
    );
  });
}
