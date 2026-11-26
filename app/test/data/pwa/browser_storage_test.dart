import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/pwa/browser_storage.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/storage/browser_storage.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/sync_fakes.dart';
import '../../support/timeline_fakes.dart' show testProfile;

/// The browser's storage manager, as the test sets it.
final class _FakeGateway implements BrowserStorageGateway {
  _FakeGateway({this.kept = false, this.grant});

  bool? kept;
  final bool? grant;
  final Set<String> _asked = {};
  int asks = 0;

  @override
  Future<bool?> persisted() async => kept;

  @override
  Future<bool?> persist() async {
    asks++;
    return grant;
  }

  @override
  bool asked(String owner) => _asked.contains(owner);

  @override
  void markAsked(String owner) => _asked.add(owner);
}

// What the browser keeps (E-G4-7 Q2, ED-188 to ED-192; ED-484): checked
// silently, asked once per owner, after sign-in or a guest's first save.
void main() {
  Future<BrowserStorageState?> read(
    _FakeGateway gateway, {
    bool browser = true,
    SyncState state = SyncState.synced,
    bool saved = false,
  }) {
    final c = ProviderContainer(
      overrides: [
        inBrowserProvider.overrideWithValue(browser),
        browserStorageGatewayProvider.overrideWithValue(gateway),
        currentProfileProvider.overrideWith(
          (ref) => Stream.value(testProfile()),
        ),
        syncServiceProvider.overrideWithValue(
          FakeSyncService(SyncStatus(state: state)),
        ),
        savedInBrowserProvider.overrideWithValue(saved),
      ],
    );
    addTearDown(c.dispose);
    // Let the profile and status streams land first.
    c
      ..listen(currentProfileProvider, (_, _) {})
      ..listen(syncStatusProvider, (_, _) {});
    return Future<void>.delayed(
      Duration.zero,
    ).then((_) => c.read(browserStorageProvider.future));
  }

  test('off the web there is nothing to say', () async {
    expect(await read(_FakeGateway(), browser: false), isNull);
  });

  test('already kept: kept, and nothing is asked', () async {
    final g = _FakeGateway(kept: true, grant: true);
    expect(await read(g), BrowserStorageState.kept);
    expect(g.asks, 0);
  });

  test('a browser without the API: cannot be asked', () async {
    expect(
      await read(_FakeGateway(kept: null)),
      BrowserStorageState.unsupported,
    );
  });

  test('signed in: asks once; a yes is kept', () async {
    final g = _FakeGateway(grant: true);
    expect(await read(g), BrowserStorageState.kept);
    expect(g.asks, 1);
  });

  test('a no is not kept, and is never asked again', () async {
    final g = _FakeGateway(grant: false);
    expect(await read(g), BrowserStorageState.notKept);
    expect(await read(g), BrowserStorageState.notKept);
    expect(g.asks, 1);
  });

  test('no answer: cannot be asked', () async {
    expect(await read(_FakeGateway()), BrowserStorageState.unsupported);
  });

  test('a guest is asked only after the first saved change', () async {
    final g = _FakeGateway(grant: true);
    expect(
      await read(g, state: SyncState.localOnly),
      BrowserStorageState.notKept,
    );
    expect(g.asks, 0);
    expect(
      await read(g, state: SyncState.localOnly, saved: true),
      BrowserStorageState.kept,
    );
    expect(g.asks, 1);
  });
}
