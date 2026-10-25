import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';

/// The write path with a count of the batches that went through it.
final class CountingWrites implements WriteUseCase {
  CountingWrites(this._inner);

  final WriteUseCase _inner;
  final batches = <WriteBatch>[];

  /// The next batch fails as the database would (R-08 paths).
  bool failNext = false;

  @override
  Future<Result<void, AppFailure>> apply(WriteBatch batch) async {
    batches.add(batch);
    if (failNext) {
      failNext = false;
      return const Err(StorageFailure());
    }
    return _inner.apply(batch);
  }
}

/// A real in-memory database and write path (with Undo through the app's
/// own providers) for proposal flows (docs/09 M10.2). Rows seeded with
/// [seed] are not counted.
final class ProposalHarness {
  ProposalHarness(DateTime now, {Profile? profile})
    : base = WriteHarness(now),
      profile = profile ?? profileFixture() {
    writes = CountingWrites(base.writes);
  }

  final WriteHarness base;

  /// The signed-in profile the flows read (zone, week start).
  final Profile profile;
  late final CountingWrites writes;

  List<Override> get overrides => [
    appDatabaseProvider.overrideWithValue(base.db),
    clockProvider.overrideWithValue(base.clock),
    writeUseCaseProvider.overrideWithValue(writes),
    currentProfileProvider.overrideWith((ref) => Stream.value(profile)),
  ];

  Future<void> seed(WidgetTester tester, WriteBatch batch) async {
    final result = await tester.runAsync(() => base.writes.apply(batch));
    expect(result, isA<Ok<void, AppFailure>>(), reason: 'seed');
  }

  /// `change_log` rows: every field the write path recorded for sync.
  Future<int> changeLogRows(WidgetTester tester) async =>
      (await tester.runAsync(base.changeLog))!.length;

  Future<void> dispose(WidgetTester tester) =>
      tester.runAsync(base.dispose).then((_) {});
}

/// The proposal rule (CLAUDE.md §11, ADR-0009 §3): [open] must bring up a
/// `ProposalSheet`, and neither it nor [edit] (dropping lines, changing
/// steps) nor [leave] (Discard, ×, a swipe) may write anything — no batch
/// through the write path, no `change_log` row. Every flow that proposes
/// (Break it down, brain-dump, Rebalance, routines, the reality thread)
/// calls this in its tests.
Future<void> expectNothingWrittenBeforeAccept(
  WidgetTester tester,
  ProposalHarness harness, {
  required Future<void> Function() open,
  Future<void> Function()? edit,
  Future<void> Function()? leave,
}) async {
  final batches = harness.writes.batches.length;
  final rows = await harness.changeLogRows(tester);
  await open();
  await tester.pumpAndSettle();
  expect(
    find.byType(ProposalSheet),
    findsOneWidget,
    reason: 'the flow must show its proposal before writing',
  );
  Future<void> check(String when) async {
    expect(
      harness.writes.batches.length,
      batches,
      reason: 'a write-path batch $when',
    );
    expect(
      await harness.changeLogRows(tester),
      rows,
      reason: 'change_log rows $when',
    );
  }

  await check('on open');
  if (edit != null) {
    await edit();
    await tester.pumpAndSettle();
    await check('while editing');
  }
  if (leave != null) {
    await leave();
    await tester.pumpAndSettle();
    expect(find.byType(ProposalSheet), findsNothing);
    await check('after leaving without Accept');
  }
}
