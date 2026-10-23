@Tags(['supabase'])
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/router/auth_callback.dart';
import 'package:dottoday/data/auth/supabase_account_service.dart';
import 'package:dottoday/data/notifications/push/push_store.dart';
import 'package:dottoday/data/notifications/push/supabase_push_store.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';
import '../support/memory_log_sink.dart';
import 'local_supabase.dart';

// The real sign-in path against local Supabase (docs/09 M6.1): the email
// link, the server's redirect to dottoday://auth-callback, the PKCE code
// exchange; then the web-push store as that user (RLS, migration 0003).
void main() {
  test(
    'magic link → callback → signed in; push rows are the user\'s own',
    () async {
      final client = localClient();
      final callbacks = StreamController<Uri>();
      final logs = MemoryLogSink();
      final service = SupabaseAccountService(
        client.auth,
        redirectTo: authCallbackLink,
        callbacks: callbacks.stream,
        logger: Logger(logs, FakeClock(DateTime.utc(2026, 10, 23))),
      );
      addTearDown(() async {
        await service.dispose();
        await callbacks.close();
        await client.dispose();
      });
      final email = 'm61-${DateTime.now().microsecondsSinceEpoch}@example.com';

      expect(await service.watch().first, isA<LocalOnly>());
      await service.sendMagicLink(email);
      final callback = await magicLinkCallback(email);
      expect(callback.scheme, 'dottoday');
      expect(callback.host, authCallbackHost);
      expect(callback.queryParameters['code'], isNotEmpty);

      final signedIn = service.watch().firstWhere((a) => a is SignedIn);
      callbacks.add(callback);
      final account = await signedIn.timeout(const Duration(seconds: 10));
      expect((account as SignedIn).email, email);
      expect(account.method, SignInMethod.email);
      expect(logs.records, isEmpty);

      final store = SupabasePushStore(client);
      final id = await store.subscribe('https://push.example.com/$email');
      await store.put(id, [
        PushRow(
          notificationId: 7,
          fireAtUtc: DateTime.utc(2026, 10, 24, 7),
          plan: 'p1',
          ciphertext: Uint8List.fromList([1, 2, 3]),
        ),
      ]);
      final rows = await client
          .from('scheduled_pushes')
          .select('notification_id');
      expect(rows.map((r) => r['notification_id']), [7]);
      await store.clearPending(id);
      expect(await client.from('scheduled_pushes').select(), isEmpty);

      await service.signOut();
      expect(await service.watch().first, isA<LocalOnly>());
    },
  );
}
