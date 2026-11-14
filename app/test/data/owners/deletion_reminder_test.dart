import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/deletion_world.dart';
import '../../support/owner_app.dart';

// CR-160 policy §4, reminder actions (owner 2026-11-09, Option 1): a
// reminder's Done, Snooze or +15 after D1's review stops the deletion until
// the person reviews again; while the deletion runs it is refused, said
// so, and D1 stays; outside a deletion nothing changes.

const _a = '01928c3e-0000-7000-8000-00000000000a';

/// What each reminder action changed on the stored row.
final _changed = <String, bool Function(DeletionWorld, OccurrenceRow?)>{
  'done': (_, r) => r?.status == OccurrenceStatus.done.name,
  'snooze': (_, r) => r?.snoozedUntilUtc != null,
  'plus15': (w, r) => r?.durationMin == w.task0.durationMin + 15,
};

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late DeletionWorld w;
  setUp(() async {
    ownerAppLogs.records.clear();
    w = await DeletionWorld.boot(_a);
  });
  tearDown(() => w.dispose());

  for (final MapEntry(key: action, value: changed) in _changed.entries) {
    test('$action from a reminder after the export stops the deletion; the '
        'next export holds it and the renewed confirmation deletes', () async {
      await w.actions.summary(_a);
      expect(await w.actions.exportFirst(_a), OwnerExportOutcome.done);
      final first = w.exported();
      await w.responder.handle(w.tap(action));
      expect(changed(w, await w.row()), isTrue, reason: 'saved as usual');
      expect(w.refused, isEmpty);
      expect(w.opened, isEmpty);
      expect(
        await w.actions.deleteAccount(),
        const Err<void, AppFailure>(ReviewChangedFailure()),
      );
      expect(w.server.deletes, 0, reason: 'nothing deleted');
      expect(await w.row(), isNotNull);
      // Saves work again once the deletion stopped.
      await w.responder.handle(w.tap('open'));
      expect(w.opened, isNotEmpty);
      expect(await w.actions.exportFirst(_a), OwnerExportOutcome.done);
      expect(w.exported(), isNot(first), reason: 'the change is in the file');
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
      expect(await w.anyRows(), isEmpty);
    });
  }

  test('a reminder action before the export is in it: the deletion goes '
      'ahead', () async {
    await w.actions.summary(_a);
    await w.responder.handle(w.tap('done'));
    expect(await w.actions.exportFirst(_a), OwnerExportOutcome.done);
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    expect(w.server.deletes, 1);
  });

  for (final action in _changed.keys) {
    test('$action while the server deletes is refused and said so; D1 '
        'stays; nothing is saved for anyone', () async {
      await w.actions.summary(_a);
      OccurrenceRow? during;
      w.server.during = () async {
        await w.responder.handle(w.tap(action));
        during = await w.row();
      };
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
      expect(w.refused, [const StorageFailure()]);
      expect(w.opened, isEmpty, reason: 'D1 is not navigated away');
      expect(_changed[action]!(w, during), isFalse);
      expect(await w.anyRows(), isEmpty);
    });
  }

  test('Open, Start and the other taps never navigate while the deletion '
      'runs, then do again', () async {
    await w.actions.summary(_a);
    w.server.during = () async {
      expect(w.owners.deleting, isTrue);
      await w.responder.handle(w.tap('open'));
      await w.responder.handle(w.tap(null));
      await w.responder.handle(w.tap('start'));
      await w.responder.handle(
        w.tap(null, purpose: NotificationPurpose.windDown),
      );
      await w.responder.handle(
        w.tap(null, purpose: NotificationPurpose.daySummary),
      );
    };
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    expect(w.opened, isEmpty);
    expect(w.refused, isEmpty, reason: 'nothing was saved or refused');
    expect(w.owners.deleting, isFalse);
    await w.responder.handle(
      w.tap(null, purpose: NotificationPurpose.windDown),
    );
    expect(w.opened, hasLength(1));
  });

  test('a failed server deletion releases the gate: saves resume', () async {
    await w.actions.summary(_a);
    w.server.fails = true;
    w.server.during = () => w.responder.handle(w.tap('done'));
    expect(
      await w.actions.deleteAccount(),
      const Err<void, AppFailure>(NetworkFailure(NetworkFailureKind.server)),
    );
    expect(w.refused, [const StorageFailure()]);
    expect((await w.row())!.status, OccurrenceStatus.planned.name);
    w.actions.endDeletion(_a);
    await w.responder.handle(w.tap('done'));
    expect((await w.row())!.status, OccurrenceStatus.done.name);
    expect(w.refused, hasLength(1));
  });

  test('outside a deletion a reminder action saves and counts once', () async {
    final before = await writeRevision(w.db, _a);
    await w.responder.handle(w.tap('snooze'));
    expect((await w.row())!.snoozedUntilUtc, isNotNull);
    expect(await writeRevision(w.db, _a), before + 1);
    expect(w.refused, isEmpty);
    expect(w.opened, isEmpty);
  });

  test('Wake Up through the common write path is refused while the '
      'deletion runs (the Check ping hint)', () async {
    await w.actions.summary(_a);
    Result<void, AppFailure>? during;
    w.server.during = () async => during = await recordHintShown(
      w.app.container,
      HintId.wakeUpCheckPing,
      spendDay: false,
    );
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    expect(during, isA<Err<void, AppFailure>>());
    final hints = await w.db.select(w.db.revealHintsTable).get();
    expect(hints.where((h) => h.userId == _a), isEmpty);
  });
}
