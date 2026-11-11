import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

// CR-160 I1: the guest-backup fence (guestBackupFence) is one lock per Dart
// isolate, and the queue's private keys open only in the app's process. That
// is enough only while backup work, guest-work moves, restores and privacy
// cleanup run in the app's main isolate and nowhere else. These scans fail
// when any of it starts to be reachable from another runtime (a background
// isolate, an extension, a worker, another process), so a cross-process
// lock is designed before it ships. A scan proves the code's shape, not
// runtime behaviour.

/// Identifiers of backup work, guest-work moves, restores and privacy
/// cleanup.
final _fenced = RegExp(
  r'guestBackupFence\b|prepareFencedBackupWork|recordPendingGuestCutoffs|'
  r'scrubForDeletedAccount|scrubExpiredGuestBackups|scrubLegacy|'
  r'cleanUpGuestBackupsForDeletedAccount|runBackupMaintenance|'
  r'markGuestBackupsPending|backupServiceProvider|backupDatabaseProvider',
);

/// The only files that may name them: the backup data layer, the owner
/// switch and sign-in step, and the main isolate's housekeeping and
/// Settings flows.
const _mainIsolateOnly = {
  'app_lifecycle.dart',
  'data/backup/backup_privacy.dart',
  'data/backup/backup_providers.dart',
  'data/backup/drift_backup_service.dart',
  'data/backup/guest_backup_cutoff.dart',
  'data/backup/guest_backup_scrub.dart',
  'data/backup/legacy_guest_quarantine.dart',
  'data/backup/staged_import.dart',
  'data/backup/staged_import_sources.dart',
  'data/owners/owner_switch.dart',
  'data/sync/account_owners.dart',
  'features/settings/pages/export_flows.dart',
};

/// What the background isolate runs (background_refresh.dart): it must not
/// reach backups, owner changes or account removal.
const _backgroundPath = [
  'background_refresh.dart',
  'data/refresh/daily_refresh.dart',
  'data/intents/action_queue_drainer.dart',
  'data/sync/background_sync.dart',
];

final _ownerChange = RegExp(
  r'ownerSwitchProvider|signInOwner|accountDeleted|finishRemoval|'
  r'finishAccountRemoval|beginAccountRemoval',
);

/// Staged-import work (CR-160 Stage B2): main isolate only. Its stale-import
/// cleanup must never run elsewhere, or it could delete an import the app
/// is staging.
final _staging = RegExp(
  r'staged_import_store|beginStagedImport|stagePart|cleanUpStaleImports|'
  r'discardStagedImport',
);

String _read(String path) => File(path).readAsStringSync();

List<File> _files(String dir, String suffix) => Directory(dir).existsSync()
    ? Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith(suffix))
          .toList()
    : const [];

void main() {
  final sources = readLibSources('lib');

  test('the only other Dart isolate entry point is background refresh', () {
    expect(
      {
        for (final MapEntry(key: path, value: src) in sources.entries)
          if (src.contains("@pragma('vm:entry-point')")) path,
      },
      {'background_refresh.dart'},
    );
  });

  test('backup, promotion, restore and cleanup code is named only by the '
      'main isolate\'s files', () {
    expect({
      for (final MapEntry(key: path, value: src) in sources.entries)
        if (_fenced.hasMatch(src)) path,
    }, _mainIsolateOnly);
  });

  test('the background isolate reaches no backup, owner change or account '
      'removal', () {
    for (final path in _backgroundPath) {
      final src = sources[path]!;
      expect(_fenced.hasMatch(src), isFalse, reason: path);
      expect(_ownerChange.hasMatch(src), isFalse, reason: path);
      expect(_staging.hasMatch(src), isFalse, reason: path);
    }
  });

  test('Apple extensions run no Flutter engine and open no database; only '
      'the app bridges read the queue opened', () {
    for (final dir in [
      'ios/DottodayShare',
      'ios/DottodayWidgets',
      'macos/DottodayShare',
      'ios/Shared',
    ]) {
      for (final f in _files(dir, '.swift')) {
        final src = f.readAsStringSync();
        expect(src, isNot(contains('FlutterEngine')), reason: f.path);
        expect(src, isNot(contains('sqlite3_open')), reason: f.path);
      }
    }
    final readers = {
      for (final dir in ['ios', 'macos'])
        for (final f in _files(dir, '.swift'))
          if (!f.path.contains('/Pods/') &&
              !f.path.contains('Tests/') &&
              RegExp(r'\.readForApp\(\)').hasMatch(f.readAsStringSync()))
            f.path,
    };
    expect(readers, {
      'ios/Runner/AppDelegate.swift',
      'macos/Runner/IntentQueueBridge.swift',
    });
  });

  test('Android opens sealed words only on the app channel\'s read', () {
    final dir = 'android/app/src/main/kotlin/app/dottoday/planner';
    final openers = {
      for (final f in _files(dir, '.kt'))
        if (RegExp(
          r'QueueCipher\.open\(|readOpened\(',
        ).hasMatch(f.readAsStringSync()))
          f.path.split('/').last,
    };
    expect(openers, {'DotQueue.kt', 'IntentQueueBridge.kt'});
  });

  test('web workers touch only their caches, never the databases', () {
    for (final f in _files('web', '.js')) {
      final src = f.readAsStringSync();
      expect(src, isNot(contains('indexedDB')), reason: f.path);
      expect(src, isNot(contains('dottoday-backups')), reason: f.path);
    }
  });

  test('queue test hooks exist only in the debug source set', () {
    final main = 'android/app/src/main';
    for (final f in _files(main, '.kt')) {
      expect(
        f.readAsStringSync(),
        isNot(contains('QueueDebugHooks()')),
        reason: f.path,
      );
      expect(
        f.readAsStringSync(),
        isNot(RegExp(r'debugHooks\s*=\s*\{')),
        reason: f.path,
      );
    }
    for (final m in [
      '$main/AndroidManifest.xml',
      'android/app/src/profile/AndroidManifest.xml',
    ]) {
      expect(_read(m), isNot(contains('queuedebug')), reason: m);
    }
    expect(
      File(
        'android/app/src/debug/kotlin/app/dottoday/planner/intents/'
        'QueueDebugHooks.kt',
      ).existsSync(),
      isTrue,
    );
    expect(
      _read('android/app/src/debug/AndroidManifest.xml'),
      contains('android:exported="false"'),
    );
    expect(Directory('android/app/src/release').existsSync(), isFalse);
  });
}
