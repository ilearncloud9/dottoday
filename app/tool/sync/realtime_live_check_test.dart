// Sync's live feed against a real Realtime server (docs/04 §4 "Triggers"):
// the local stack from `supabase start`, never the hosted project. Not in
// CI (it needs the stack); run before changing sync triggers:
//
//   flutter test tool/sync/realtime_live_check_test.dart
//
// Checks: a nudge on joining; a change right after joining (before the
// server's change feed is live) is still followed by a nudge; a nudge for
// a change; after the network drops, a change made meanwhile is caught up
// by the rejoin's nudge; a
// channel closed under it is replaced and nudges again. A throwaway user is
// signed up on the local stack for each run.
import 'dart:async';
import 'dart:math';

import 'package:dottoday/data/sync/supabase_sync_gateway.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _url = 'http://127.0.0.1:54321';
// The local stack's well-known demo anon key (`supabase status`), public.
const _anon =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6'
    'ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
const _inTime = Duration(seconds: 15);

String _uuid(Random r) {
  String hex(int n) =>
      List.generate(n, (_) => r.nextInt(16).toRadixString(16)).join();
  return '${hex(8)}-${hex(4)}-7${hex(3)}-8${hex(3)}-${hex(12)}';
}

String _hlc() =>
    '${DateTime.now().millisecondsSinceEpoch.toString().padLeft(13, '0')}'
    '-0001-00000000000000aa';

void main() {
  late SupabaseClient client;
  late SupabaseSyncGateway gateway;
  final random = Random();
  var nudges = 0;
  StreamSubscription<void>? sub;

  setUpAll(() async {
    client = SupabaseClient(
      _url,
      _anon,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
    final email = 'live-${random.nextInt(1 << 31)}@example.test';
    await client.auth.signUp(email: email, password: _uuid(random));
    await client.realtime.setAuth(client.auth.currentSession!.accessToken);
    gateway = SupabaseSyncGateway(client);
  });
  tearDownAll(() async {
    await sub?.cancel();
    await client.dispose();
  });

  Future<void> nudgedPast(int seen, String what) async {
    final clock = Stopwatch()..start();
    while (nudges <= seen) {
      if (clock.elapsed > _inTime) fail('no nudge: $what');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    // ignore: avoid_print
    print('LIVE $what in ${clock.elapsedMilliseconds} ms');
  }

  Future<void> push() => gateway.push([
    PushChange(
      entity: 'occurrences',
      id: _uuid(random),
      hlc: _hlc(),
      fields: const {'title': 'live check'},
    ),
  ]);

  test('joins, changes, drops, closes: every case nudges', () async {
    sub = gateway.changes().listen((_) => nudges++);
    await nudgedPast(0, 'joined');

    // At once: before the server's change feed is live, the change itself
    // goes unannounced; the "live" nudge must still follow it.
    var seen = nudges;
    await push();
    await nudgedPast(seen, 'a change right after joining');
    await Future<void>.delayed(const Duration(seconds: 2));

    seen = nudges;
    await push();
    await nudgedPast(seen, 'a change');

    // The network drops (the socket ends under the client, not a
    // disconnect() call); a change lands while it is down.
    await Future<void>.delayed(const Duration(seconds: 1));
    seen = nudges;
    await client.realtime.conn!.sink.close();
    await push();
    await nudgedPast(seen, 'rejoined after a drop (catch-up)');

    // The channel is closed under the feed: it is replaced.
    await Future<void>.delayed(const Duration(seconds: 1));
    seen = nudges;
    await client.removeAllChannels();
    await nudgedPast(seen, 'replaced after close');
    seen = nudges;
    await push();
    await nudgedPast(seen, 'a change on the new channel');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
