import 'package:dottoday/data/live_activity/web_live_dot_providers.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/pwa/browser_storage_stub.dart'
    if (dart.library.js_interop) 'package:dottoday/data/pwa/browser_storage_web.dart'
    as platform;
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/storage/browser_storage.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'browser_storage.g.dart';

/// The browser's storage manager (the web's; a stub elsewhere).
final class PlatformBrowserStorage implements BrowserStorageGateway {
  const PlatformBrowserStorage();

  @override
  Future<bool?> persisted() => platform.persisted();

  @override
  Future<bool?> persist() => platform.persist();

  @override
  bool asked(String owner) => platform.asked(owner);

  @override
  void markAsked(String owner) => platform.markAsked(owner);
}

@Riverpod(keepAlive: true)
BrowserStorageGateway browserStorageGateway(Ref ref) =>
    const PlatformBrowserStorage();

/// Whether something has been saved in this browser yet: a task on the
/// day or in the Inbox (the guest's "first saved change", ED-192).
@riverpod
bool savedInBrowser(Ref ref) {
  final s = ref.watch(lastDaySnapshotProvider);
  return s != null && (s.dots.isNotEmpty || s.inboxCount > 0);
}

/// What the browser keeps for Dottoday (E-G4-7 Q2, ED-188 to ED-192;
/// M20.10 part 6, ED-484); null off the web. Checks silently; asks the
/// browser to keep the data once per browser profile and owner, after
/// sign-in, or for a guest after the first saved change; never blocks,
/// never asks again, and an unanswered or missing API counts as
/// "can't be asked".
@Riverpod(keepAlive: true)
Future<BrowserStorageState?> browserStorage(Ref ref) async {
  if (!ref.watch(inBrowserProvider)) return null;
  final gateway = ref.watch(browserStorageGatewayProvider);
  final owner = ref.watch(currentProfileProvider).value?.id;
  final state = ref.watch(syncStatusProvider).value?.state;
  final signedIn = state != null && state != SyncState.localOnly;
  final due = signedIn || ref.watch(savedInBrowserProvider);
  final kept = await gateway.persisted();
  if (kept == null) return BrowserStorageState.unsupported;
  if (kept) return BrowserStorageState.kept;
  if (!due || owner == null || gateway.asked(owner)) {
    return BrowserStorageState.notKept;
  }
  gateway.markAsked(owner);
  return switch (await gateway.persist()) {
    null => BrowserStorageState.unsupported,
    true => BrowserStorageState.kept,
    false => BrowserStorageState.notKept,
  };
}
