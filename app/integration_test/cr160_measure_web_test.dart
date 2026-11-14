// CR-160 B8 on the web (docs/cr-160-multipart-export.md §7): the real app
// in a fresh browser profile, its own import, export and backup services
// on the 60 MB reference account. A page can't read its own memory, so
// each step is announced (`CR160_STEP begin|end <step>`) and the host
// (tool/cr160/web_measure.mjs) samples the tab from Chromium while it
// runs. Built with the local-stack defines; never signs in.
import 'dart:convert';

import 'package:dottoday/app.dart';
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/perf_account.dart';
import 'pass_onboarding.dart';

/// Tasks of about 10 KB each: 5,800 is §7's 60 MB reference, 2,900 is
/// 30 MB (CR160_TASKS).
const _tasks = int.fromEnvironment('CR160_TASKS', defaultValue: 5800);

/// Announces [step] and holds still around it, so the host's samples
/// before and after are the step's own.
Future<T> _step<T>(String step, Future<T> Function() body) async {
  debugPrint('CR160_STEP begin $step');
  await Future<void>.delayed(const Duration(seconds: 2));
  final watch = Stopwatch()..start();
  final out = await body();
  debugPrint('CR160_STEP end $step took=${watch.elapsedMilliseconds}ms');
  await Future<void>.delayed(const Duration(seconds: 2));
  return out;
}

void _ok(Result<Object?, AppFailure> r) =>
    expect(r, isA<Ok<Object?, AppFailure>>());

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CR-160 B8 on the web: 60 MB through the app', (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await tester.pump(const Duration(milliseconds: 500));
    final c = ProviderScope.containerOf(
      tester.element(find.byType(DottodayApp)),
    );
    await c.read(accountActionsProvider).useWithoutAccount();
    await passOnboarding(tester);
    final owner = (await c.read(localProfileProvider.future)).id;
    final backups = c.read(backupServiceProvider);
    final exports = c.read(exportServiceProvider);

    final split =
        splitExport(
              perfAccountAt(_tasks, owner, DateTime.utc(2026, 11, 12)),
              exportId: '01928c3e-0000-7000-8000-0000000000bb',
              appVersion: '1',
              schemaVersion: 21,
              purpose: ExportPurpose.export,
              date: '2026-11-12',
            )
            as MultipartSplit;
    final parts = [for (final f in split.files.skip(1)) f.content];
    await _step(
      'import set (${parts.length} parts)',
      () async => _ok(
        await backups.importSet(owner, split.files.first.content, [
          for (final p in parts) () async => p,
        ]),
      ),
    );

    Future<PreparedSet> export(String step) => _step(step, () async {
      final r = await exports.prepareSet(owner, appVersion: () async => '1');
      _ok(r);
      return (r as Ok<PreparedExport, AppFailure>).value as PreparedSet;
    });
    final set = await export('export set, 10 MB parts');

    // Round trip through the app: the exported set imported back, then
    // exported again, holds the same rows.
    await _step(
      'import the exported set back',
      () async => _ok(
        await backups.importSet(owner, _text(set.manifestFile.bytes!), [
          for (final p in set.parts) () async => _text(p.bytes!),
        ]),
      ),
    );
    final again = await export('export again');
    expect(again.manifest.totals, set.manifest.totals);
    debugPrint('CR160_MEASURE web round trip: same counts');

    final made = await _step(
      'backup written',
      () => backups.create(owner, BackupReason.daily),
    );
    _ok(made);
    final id = (made as Ok<BackupInfo, AppFailure>).value.id;
    await _step('restore backup', () async {
      _ok(await backups.restore(owner, id));
    });
    debugPrint('CR160_MEASURE web done');
  }, timeout: const Timeout(Duration(minutes: 30)));
}

String _text(Uint8List bytes) => utf8.decode(bytes);
