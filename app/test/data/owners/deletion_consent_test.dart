import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/deletion_world.dart';

// D1's export outcome and the explicit "Delete without a saved copy"
// choice (CR-160 Stage C): an export that left no restorable copy is never
// consent by itself; the choice holds only for the review it was made on,
// and never relaxes any other check.

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
    w.server.revision = 7;
    await w.actions.summary(_account); // D1 opened
  });
  tearDown(() => w.dispose());

  AppFailure failure(Result<void, AppFailure> r) => (r as Err).failure;

  test(
    'no export asked for: the typed confirmation deletes, as before',
    () async {
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
      expect(w.server.askedAt, [7]);
    },
  );

  test('an export handed over: deletes, as before', () async {
    expect(await w.actions.exportFirst(_account), OwnerExportOutcome.done);
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
  });

  for (final (name, setUpGateway) in [
    (
      'cancelled',
      (DeletionWorld w) => w.files.outcome = DeliveryOutcome.cancelled,
    ),
    ('failed', (DeletionWorld w) => w.files.throws = Exception('disk full')),
  ]) {
    test('$name export: deleting is refused until the person chooses, the '
        'server is never asked', () async {
      setUpGateway(w);
      final outcome = await w.actions.exportFirst(_account);
      expect(outcome, isNot(OwnerExportOutcome.done));
      final r = failure(await w.actions.deleteAccount());
      expect(r, isA<ExportNotSavedFailure>());
      expect((r as ExportNotSavedFailure).retryable, isTrue);
      expect(w.server.askedAt, isEmpty);
      expect(w.actions.waiveExport(_account), isTrue);
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
      expect(w.server.askedAt, [7]);
    });
  }

  test(
    'too large: refused, not retryable; the choice still lets it go',
    () async {
      // Too large is one row larger than any part (CR-160 B7c, §10): an
      // account over 25 MB is a set now. Parts of 1,500 bytes here.
      await w.dispose();
      w = await DeletionWorld.boot(_account, partTarget: 1500);
      await DriftOccurrenceRepository(w.db).upsertAll([
        occurrenceFixture().copyWith(
          id: '01928c3e-0000-7000-9000-000000000001',
          userId: _account,
          notes: 'n' * 2000,
        ),
      ]);
      expect(
        await w.actions.exportFirst(_account),
        OwnerExportOutcome.tooLarge,
      );
      final r =
          failure(await w.actions.deleteAccount()) as ExportNotSavedFailure;
      expect(r.retryable, isFalse, reason: 'exporting again can\'t help');
      expect(w.actions.waiveExport(_account), isTrue);
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('nothing to waive without a failed export', () async {
    expect(w.actions.waiveExport(_account), isFalse);
    expect(await w.actions.exportFirst(_account), OwnerExportOutcome.done);
    expect(w.actions.waiveExport(_account), isFalse);
  });

  test('the choice never passes a failed server verification', () async {
    w.files.outcome = DeliveryOutcome.cancelled;
    w.sync.verify = (_) async =>
        const DeletionUnverified(NetworkFailure(NetworkFailureKind.offline));
    await w.actions.exportFirst(_account);
    w.actions.waiveExport(_account);
    expect(failure(await w.actions.deleteAccount()), isA<NetworkFailure>());
    expect(w.server.askedAt, isEmpty);
  });

  test(
    'a change after the choice voids it: reviewed again, asked again',
    () async {
      w.files.outcome = DeliveryOutcome.cancelled;
      await w.actions.exportFirst(_account);
      expect(w.actions.waiveExport(_account), isTrue);
      await w.app.write([w.task0.copyWith(title: 'edited after the choice')]);
      expect(
        failure(await w.actions.deleteAccount()),
        isA<ReviewChangedFailure>(),
      );
      expect(
        failure(await w.actions.deleteAccount()),
        isA<ExportNotSavedFailure>(),
        reason: 'the old choice was for the old review',
      );
      expect(w.server.askedAt, isEmpty);
      expect(w.actions.waiveExport(_account), isTrue);
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    },
  );

  test('A → B → A: the choice is never reused', () async {
    w.files.outcome = DeliveryOutcome.cancelled;
    await w.actions.exportFirst(_account);
    expect(w.actions.waiveExport(_account), isTrue);
    await w.app.signIn(_other);
    await w.app.signIn(_account);
    expect(
      failure(await w.actions.deleteAccount()),
      isA<ReviewChangedFailure>(),
    );
    expect(w.server.askedAt, isEmpty);
  });

  test(
    'a new export attempt replaces the outcome and voids the choice',
    () async {
      w.files.outcome = DeliveryOutcome.cancelled;
      await w.actions.exportFirst(_account);
      expect(w.actions.waiveExport(_account), isTrue);
      await w.actions.exportFirst(_account); // cancelled again
      expect(
        failure(await w.actions.deleteAccount()),
        isA<ExportNotSavedFailure>(),
      );
      w.files.outcome = DeliveryOutcome.delivered;
      expect(await w.actions.exportFirst(_account), OwnerExportOutcome.done);
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    },
  );

  test(
    'D1 closed and opened again: a new session, nothing carried over',
    () async {
      w.files.outcome = DeliveryOutcome.cancelled;
      await w.actions.exportFirst(_account);
      w.actions.endDeletion(_account);
      await w.actions.summary(_account);
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    },
  );

  test(
    'an export still running blocks deleting (never slips through)',
    () async {
      final running = w.actions.exportFirst(_account);
      final r =
          failure(await w.actions.deleteAccount()) as ExportNotSavedFailure;
      expect(r.retryable, isFalse);
      expect(
        w.actions.waiveExport(_account),
        isFalse,
        reason: 'nothing to waive yet',
      );
      expect(await running, OwnerExportOutcome.done);
      expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    },
  );

  test('an export that ends after D1 closed records nothing in the next '
      'session', () async {
    w.files.outcome = DeliveryOutcome.cancelled;
    final late = w.actions.exportFirst(_account);
    w.actions.endDeletion(_account);
    await late;
    await w.actions.summary(_account);
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
  });
}
