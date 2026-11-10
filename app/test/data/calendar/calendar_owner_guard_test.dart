import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/calendar_write_back.dart';
import 'package:dottoday/data/calendar/device_calendar_writer.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/daos/calendar_links_dao.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators, Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';
import '../../support/calendar_fakes.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

// Calendar writes never touch another owner's rows (CR-160 I1): the link
// join only finds the link owner's occurrences, import and write-back
// check each row's actual owner inside their transaction, and both stop
// when the owner session they started in has ended. A write already sent
// to a calendar can't be undone by a local rollback; the session is checked
// before sending, too.

const _a = userId;
const _b = '01928c3e-0000-7000-8000-00000000000b';
const _work = DeviceCalendar(id: 'work', name: 'Work');

void main() {
  late WriteHarness h;
  late FakeDeviceCalendarGateway os;
  late DriftCalendarSourceRepository sources;
  late CalendarWriteBack writeBack;
  late tz.Location berlin;
  Future<void> Function()? duringImport;
  final nine = DateTime.utc(2026, 10, 21, 7);

  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  CalendarImporter importer({String ids = 'cal'}) => CalendarImporter(
    db: h.db,
    gateway: os,
    sources: sources,
    effects: h.effects,
    clock: h.clock,
    ids: FakeIds(ids),
    logger: h.logger,
    heldLinks: (u) async {
      await duringImport?.call();
      return const {};
    },
  );

  setUp(() async {
    duringImport = null;
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    for (final owner in [_a, _b]) {
      await h.writes.apply(
        WriteBatch(
          userId: owner,
          profile: profileFixture().copyWith(id: owner),
        ),
      );
    }
    await h.db.customStatement(
      'INSERT OR REPLACE INTO local_meta (key, value) VALUES (?, ?)',
      [activeOwnerKey, _a],
    );
    await h.db.delete(h.db.changeLog).go();
    os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: const [_work],
      events: {
        'work': [
          ExternalEvent(
            id: 'E1',
            calendarId: 'work',
            title: 'Standup',
            startUtc: nine,
            endUtc: nine.add(const Duration(minutes: 15)),
          ),
        ],
      },
    );
    sources = DriftCalendarSourceRepository(
      h.db,
      provider: CalendarProvider.appleDevice,
      clock: h.clock,
      ids: FakeIds('acc'),
    );
    writeBack = CalendarWriteBack(
      db: h.db,
      writerFor: (_) => DeviceCalendarWriter(os),
      effects: h.effects,
      clock: h.clock,
      logger: h.logger,
    );
  });
  tearDown(() async {
    await pumpEventQueue();
    await h.dispose();
  });

  Future<Result<void, AppFailure>> import({String ids = 'cal'}) async {
    final rows = await sources.watchDevice(_a).first;
    return importer(ids: ids).run(
      userId: _a,
      choices: calendarChoices(os.list, rows, const {}),
      location: berlin,
      untitled: 'Untitled event',
    );
  }

  Future<void> switchTo(String owner) => h.db.transaction(() async {
    await h.db.customStatement(
      'INSERT OR REPLACE INTO local_meta (key, value) VALUES (?, ?)',
      [activeOwnerKey, owner],
    );
    await bumpOwnerGeneration(h.db);
  });

  Future<Occurrence> imported() async => occurrenceFromRow(
    await (h.db.select(h.db.occurrences)
          ..where((o) => o.source.equals('calendar') & o.userId.equals(_a)))
        .getSingle(),
  );

  Future<String> rowOf(String id) async =>
      (await h.db
              .customSelect(
                'SELECT user_id, title, start_utc FROM occurrences WHERE id = ?',
                variables: [Variable<String>(id)],
              )
              .getSingle())
          .data
          .values
          .join('|');

  /// A's imported event, then its row handed to B (as a foreign row with
  /// A's link id would look).
  Future<Occurrence> foreignLinkedRow() async {
    expect(await import(), isA<Ok<void, AppFailure>>());
    final o = await imported();
    await h.db.customStatement(
      'UPDATE occurrences SET user_id = ?, title = ? WHERE id = ?',
      [_b, "B's private title", o.id],
    );
    return o;
  }

  test("A's link never joins B's occurrence", () async {
    final o = await foreignLinkedRow();
    final rows = await CalendarLinksDao(h.db).linked(_a, {'apple_device'});
    expect(rows.single.$2, isNull, reason: "B's row is not A's");
    expect(o.calendarLinkId, rows.single.$1.id);
  });

  test("A's next import leaves B's row untouched", () async {
    final o = await foreignLinkedRow();
    final before = await rowOf(o.id);
    await import(ids: 'again');
    expect(await rowOf(o.id), before);
  });

  test("an import reusing an id B holds is refused whole; B's row and "
      "A's outbox and revision unchanged", () async {
    // B owns the id the importer will give A's first new row.
    await h.writes.apply(
      WriteBatch(
        userId: _b,
        occurrences: [
          occurrenceFixture().copyWith(
            id: 'cal-2',
            userId: _b,
            seriesId: null,
            title: "B's",
          ),
        ],
      ),
    );
    await h.db.delete(h.db.changeLog).go();
    final before = await rowOf('cal-2');
    final revision = await writeRevision(h.db, _a);
    expect(await import(), isA<Err<void, AppFailure>>());
    expect(await rowOf('cal-2'), before);
    expect(await writeRevision(h.db, _a), revision);
    expect(await h.changeLog(), isEmpty);
    expect(
      await (h.db.select(
        h.db.calendarLinks,
      )..where((l) => l.userId.equals(_a))).get(),
      isEmpty,
      reason: 'nothing of the import committed',
    );
  });

  test("write-back never sends B's row to A's calendar", () async {
    await foreignLinkedRow();
    await sources.setWriteBack(_a, _work, writeBack: true);
    expect(await writeBack.pending(_a), isEmpty);
    expect(os.updates, isEmpty);
  });

  test('an owner change between reading and sending stops write-back '
      'before the calendar is written', () async {
    expect(await import(), isA<Ok<void, AppFailure>>());
    await sources.setWriteBack(_a, _work, writeBack: true);
    final o = await imported();
    await h.writes.apply(
      WriteBatch(
        userId: _a,
        occurrences: [o.copyWith(startUtc: nine.add(const Duration(hours: 1)))],
      ),
    );
    final items = await writeBack.pending(_a);
    expect(items, hasLength(1));
    await switchTo(_b);
    await writeBack.push(items, untitled: 'Untitled event');
    expect(os.updates, isEmpty, reason: 'nothing sent for an ended session');
  });

  test('A -> B -> A while write-back was pending: the old items are not '
      'sent; a fresh read sends them', () async {
    expect(await import(), isA<Ok<void, AppFailure>>());
    await sources.setWriteBack(_a, _work, writeBack: true);
    final o = await imported();
    await h.writes.apply(
      WriteBatch(
        userId: _a,
        occurrences: [o.copyWith(startUtc: nine.add(const Duration(hours: 1)))],
      ),
    );
    final stale = await writeBack.pending(_a);
    await switchTo(_b);
    await switchTo(_a);
    await writeBack.push(stale, untitled: 'Untitled event');
    expect(os.updates, isEmpty);
    await writeBack.push(
      await writeBack.pending(_a),
      untitled: 'Untitled event',
    );
    expect(os.updates, hasLength(1), reason: 'same-owner write-back works');
  });

  test('a sealed account sends nothing back and imports nothing', () async {
    expect(await import(), isA<Ok<void, AppFailure>>());
    await sources.setWriteBack(_a, _work, writeBack: true);
    final o = await imported();
    await h.writes.apply(
      WriteBatch(
        userId: _a,
        occurrences: [o.copyWith(startUtc: nine.add(const Duration(hours: 1)))],
      ),
    );
    final items = await writeBack.pending(_a);
    await sealForDeletion(h.db, _a);
    await writeBack.push(items, untitled: 'Untitled event');
    expect(os.updates, isEmpty);
  });

  test('an owner change during an import commits nothing of it', () async {
    duringImport = () => switchTo(_b);
    final revision = await writeRevision(h.db, _a);
    await import();
    expect(
      await (h.db.select(
        h.db.occurrences,
      )..where((o) => o.source.equals('calendar'))).get(),
      isEmpty,
    );
    expect(await writeRevision(h.db, _a), revision);
  });

  test('same owner: import and write-back work as before', () async {
    expect(await import(), isA<Ok<void, AppFailure>>());
    await sources.setWriteBack(_a, _work, writeBack: true);
    final o = await imported();
    await h.writes.apply(
      WriteBatch(
        userId: _a,
        occurrences: [o.copyWith(startUtc: nine.add(const Duration(hours: 1)))],
      ),
    );
    final report = await writeBack.push(
      await writeBack.pending(_a),
      untitled: 'Untitled event',
    );
    expect(report.failed, isEmpty);
    expect(os.updates, hasLength(1));
    expect((await imported()).userId, _a);
  });
}
