@Tags(['supabase'])
library;

import 'dart:async';

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/router/auth_callback.dart';
import 'package:dottoday/data/auth/supabase_account_service.dart';
import 'package:dottoday/data/sync/account_adoption.dart';
import 'package:dottoday/data/sync/supabase_sync_gateway.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';
import '../support/memory_log_sink.dart';
import 'local_supabase.dart';

// Settings › Account › Delete account against local Supabase (docs/09
// M6.5, 06 §6): the delete-account function removes the user and every
// synced row; the device keeps its copy and is signed out.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  test(
    'delete: the user and their rows are gone, the device keeps its copy',
    () async {
      final client = localClient();
      final callbacks = StreamController<Uri>();
      final h = WriteHarness(DateTime.now().toUtc());
      final service = SupabaseAccountService(
        client.auth,
        redirectTo: authCallbackLink,
        callbacks: callbacks.stream,
        logger: Logger(MemoryLogSink(), h.clock),
        deleteRemote: () => client.functions.invoke('delete-account'),
      );
      addTearDown(() async {
        await service.dispose();
        await callbacks.close();
        await h.dispose();
        await client.dispose();
      });
      final email = 'm65-${DateTime.now().microsecondsSinceEpoch}@example.com';
      await service.sendMagicLink(email);
      final signedIn = service.watch().firstWhere((a) => a is SignedIn);
      callbacks.add(await magicLinkCallback(email));
      await signedIn;
      final uid = client.auth.currentUser!.id;

      // A task on the device, synced up.
      await h.writes.apply(
        WriteBatch(
          userId: 'device-local',
          profile: profileFixture().copyWith(id: 'device-local'),
        ),
      );
      await adoptAccount(h.db, uid, h.hlc);
      await h.writes.apply(
        WriteBatch(
          userId: uid,
          occurrences: [occurrenceFixture().copyWith(userId: uid)],
        ),
      );
      await SyncEngine(
        db: h.db,
        gateway: SupabaseSyncGateway(client),
        hlc: h.hlc,
        clock: h.clock,
      ).run(uid);
      expect(await adminRows('occurrences', uid), hasLength(1));

      expect(await service.deleteAccount(), isA<Ok<void, Object?>>());
      expect(await adminRows('occurrences', uid), isEmpty);
      expect(await adminRows('profiles', uid), isEmpty);
      expect(await service.watch().first, isA<LocalOnly>());
      expect(await h.db.select(h.db.occurrences).get(), hasLength(1));
    },
  );
}
