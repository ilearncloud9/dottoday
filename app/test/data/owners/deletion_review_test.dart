import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/deletion_world.dart';

// D1 with the verified review (CR-160 W0–W2): the deletion goes to the
// server only with the revision the review verified, only in the owner
// session that verified it, and anything unverified, stale or unknown
// stops it without undoing anything.

const _account = '01928c3e-0000-7000-8000-0000000000aa';
const _other = '01928c3e-0000-7000-8000-0000000000bb';

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late DeletionWorld w;
  setUp(() async {
    w = await DeletionWorld.boot(_account);
    w.server.revision = 41;
  });
  tearDown(() => w.dispose());

  test('verified: the deletion is asked at the reviewed revision', () async {
    await w.actions.summary(_account);
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    expect(w.server.askedAt, [41]);
    expect(w.sync.verified, [_account]);
  });

  test('unverified (offline): no export, the server is never asked, the '
      "check's reason is said", () async {
    w.sync.verify = (_) async =>
        const DeletionUnverified(NetworkFailure(NetworkFailureKind.offline));
    expect(
      await w.actions.exportFirst(_account),
      OwnerExportOutcome.failed,
      reason: "this device's copy is never the account's confirmed export",
    );
    final r = await w.actions.deleteAccount();
    expect(
      (r as Err).failure,
      isA<NetworkFailure>().having(
        (f) => f.kind,
        'kind',
        NetworkFailureKind.offline,
      ),
    );
    expect(w.server.askedAt, isEmpty);
  });

  test(
    'an open conflict: refused with the conflict message, not asked',
    () async {
      w.sync.verify = (_) async =>
          const DeletionUnverified(ConflictFailure(EntityKind.occurrence));
      await w.actions.summary(_account);
      expect(
        (await w.actions.deleteAccount() as Err).failure,
        isA<ConflictFailure>(),
      );
      expect(w.server.askedAt, isEmpty);
    },
  );

  test(
    'W1/W2: the server changed after the review: 409, nothing deleted, '
    'verified again, and the next confirmation uses the new revision',
    () async {
      await w.actions.exportFirst(_account);
      w.server.revision = 42; // another device's write landed on the server
      expect(
        (await w.actions.deleteAccount() as Err).failure,
        isA<ReviewChangedFailure>(),
      );
      expect(w.server.deletes, 1);
      expect(await activeOwnerId(w.db), _account, reason: 'nothing removed');
      expect(w.sync.verified, hasLength(2), reason: 'reviewed again at once');
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
      expect(w.server.askedAt, [41, 42]);
    },
  );

  test('a local write after the export: stopped here, the server is not '
      'asked', () async {
    await w.actions.exportFirst(_account);
    await w.app.write([w.task0.copyWith(title: 'edited after the export')]);
    expect(
      (await w.actions.deleteAccount() as Err).failure,
      isA<ReviewChangedFailure>(),
    );
    expect(w.server.askedAt, isEmpty);
  });

  test(
    'A → B → A after the review: the old verification is never reused',
    () async {
      await w.actions.summary(_account);
      await w.app.signIn(_other);
      await w.app.signIn(_account);
      expect(
        (await w.actions.deleteAccount() as Err).failure,
        isA<ReviewChangedFailure>(),
      );
      expect(w.server.askedAt, isEmpty);
      // Verified again in this session: now it may go.
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
      expect(w.server.askedAt, [41]);
    },
  );

  test('an unknown outcome: nothing removed here, the seal stays, a retry at '
      'the same revision finishes it', () async {
    await w.actions.summary(_account);
    w.server.answer = const NetworkFailure(NetworkFailureKind.timeout);
    expect(
      (await w.actions.deleteAccount() as Err).failure,
      isA<NetworkFailure>(),
    );
    expect(await activeOwnerId(w.db), _account, reason: 'not taken as deleted');
    expect(await w.row(), isNotNull, reason: 'no local data removed');
    expect(
      await w.save(w.task0.copyWith(title: 'while unknown')),
      isA<Err<void, AppFailure>>(),
      reason: 'sealed: nothing local moves while a retry may finish it',
    );
    w.server.answer = null;
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    expect(w.server.askedAt, [41, 41]);
  });

  test('an unknown outcome, then D1 closed: the seal goes', () async {
    await w.actions.summary(_account);
    w.server.answer = const NetworkFailure(NetworkFailureKind.timeout);
    await w.actions.deleteAccount();
    w.actions.endDeletion(_account);
    await pumpEventQueue();
    expect(
      await w.save(w.task0.copyWith(title: 'after closing')),
      isA<Ok<void, AppFailure>>(),
    );
  });

  test(
    'a definite server failure (nothing frozen): unsealed, may retry',
    () async {
      await w.actions.summary(_account);
      w.server.answer = const NetworkFailure(NetworkFailureKind.server);
      await w.actions.deleteAccount();
      expect(
        await w.save(w.task0.copyWith(title: 'saved again')),
        isA<Ok<void, AppFailure>>(),
      );
    },
  );

  test(
    'unknown twice, then finished: the queue refusal ends exactly once',
    () async {
      await w.actions.summary(_account);
      w.server.answer = const NetworkFailure(NetworkFailureKind.timeout);
      await w.actions.deleteAccount();
      expect(w.owners.deleting, isTrue, reason: 'still refusing while unknown');
      await w.actions.deleteAccount();
      w.server.answer = null;
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
      expect(w.owners.deleting, isFalse);
      expect(w.server.askedAt, [
        41,
        41,
        41,
      ], reason: 'the same attempt resumed');
    },
  );

  test(
    'unknown, then a definite failure: unsealed, the refusal ends',
    () async {
      await w.actions.summary(_account);
      w.server.answer = const NetworkFailure(NetworkFailureKind.timeout);
      await w.actions.deleteAccount();
      w.server.answer = const NetworkFailure(NetworkFailureKind.server);
      await w.actions.deleteAccount();
      expect(w.owners.deleting, isFalse);
      expect(
        await w.save(w.task0.copyWith(title: 'saved again')),
        isA<Ok<void, AppFailure>>(),
      );
    },
  );

  test('unknown, then D1 closed: local seal and refusal end; the server is '
      'not asked to release anything', () async {
    await w.actions.summary(_account);
    w.server.answer = const NetworkFailure(NetworkFailureKind.timeout);
    await w.actions.deleteAccount();
    final asked = w.server.deletes;
    w.actions.endDeletion(_account);
    await pumpEventQueue();
    expect(w.owners.deleting, isFalse);
    expect(w.server.deletes, asked, reason: 'closing D1 calls nothing remote');
  });
}
