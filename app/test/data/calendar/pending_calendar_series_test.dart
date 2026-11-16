import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/calendar/pending_calendar_series.dart';
import 'package:dottoday/data/calendar/pending_series_attach.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/calendar_template_fixtures.dart';
import '../../support/calendar_template_world.dart';
import '../../support/deletion_world.dart';
import '../../support/fake_ids.dart';

// Restored calendar-series templates (CR-160 Stage A): kept pending under
// the importing account, attached only to that account's own calendar
// with the exact provider ids on the install they came from (Apple's
// device store only), never guessed, and gone with the account.

const _a = '01928c3e-0000-7000-8000-0000000000aa';
const _b = '01928c3e-0000-7000-8000-0000000000bb';

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late DeletionWorld w;
  late String tag;
  late FakeIds ids;
  setUp(() async {
    ids = FakeIds('p');
    w = await DeletionWorld.boot(_a);
    tag = await w.deviceTag();
  });
  tearDown(() => w.dispose());

  CalendarSeriesTemplate t({
    String owner = _a,
    CalendarProvider provider = CalendarProvider.appleDevice,
    String calendarId = 'work',
    String? deviceTag = '',
  }) => fullTemplate(
    id: 'file-id',
    userId: owner,
    provider: provider,
    calendarId: calendarId,
    deviceTag: deviceTag == '' ? tag : deviceTag,
  );

  Future<void> stash(String owner, List<CalendarSeriesTemplate> ts) async =>
      expect(
        await stashCalendarSeriesTemplates(w.db, owner, ts, ids),
        isA<Ok<void, AppFailure>>(),
      );

  test('stashed: under the importing account, re-keyed, attaches nothing, '
      'counted as a save', () async {
    await w.connect(_a, workCalendar);
    final before = await writeRevision(w.db, _a);
    await stash(_a, [t(owner: 'someone-in-the-file')]);
    final held = (await w.pending(_a)).single;
    expect((held.userId, held.id), (_a, 'p-1'));
    expect(contents(held.settings), contents(t().settings));
    expect(await w.attached(_a), isEmpty, reason: 'never on import');
    expect(await writeRevision(w.db, _a), before + 1);
  });

  test('the exact calendar on this install: attached whole, once', () async {
    final account = await w.connect(_a, workCalendar);
    await stash(_a, [t()]);
    final before = await writeRevision(w.db, _a);
    expect(await w.attach(_a), 1);
    final s = (await w.attached(_a)).single;
    expect((s.accountId, s.userId), (account, _a));
    expect(contents(s), contents(t().settings));
    expect(s.subtaskTemplate!.map((i) => i.id), ['z', 'a', 'm']);
    expect(await w.pending(_a), isEmpty);
    expect(await writeRevision(w.db, _a), before + 1);
    expect(await w.attach(_a), 0);
  });

  test('a hidden-only template attaches hidden', () async {
    await w.connect(_a, workCalendar);
    await stash(_a, [
      fullTemplate(id: 'h', userId: _a, deviceTag: tag, hidden: true),
    ]);
    await w.attach(_a);
    expect((await w.attached(_a)).single.hidden, isTrue);
  });

  final stays =
      <
        (
          String,
          DeviceCalendar,
          CalendarProvider,
          CalendarSeriesTemplate Function(String),
        )
      >[
        (
          'no calendar with that id (wrong calendar)',
          const DeviceCalendar(id: 'home', name: 'Home'),
          CalendarProvider.appleDevice,
          (tag) => fullTemplate(id: 'x', userId: _a, deviceTag: tag),
        ),
        (
          'another install (device tag differs)',
          workCalendar,
          CalendarProvider.appleDevice,
          (_) =>
              fullTemplate(id: 'x', userId: _a, deviceTag: 'ffffffffffffffff'),
        ),
        (
          'no device tag at all',
          workCalendar,
          CalendarProvider.appleDevice,
          (_) => fullTemplate(id: 'x', userId: _a),
        ),
        (
          'Android: row ids can repeat, never proof',
          androidCalendar,
          CalendarProvider.androidDevice,
          (tag) => fullTemplate(
            id: 'x',
            userId: _a,
            provider: CalendarProvider.androidDevice,
            calendarId: '3',
            deviceTag: tag,
          ),
        ),
        (
          'Google: even the same connection id has no verified identity',
          googleCalendar('conn-1'),
          CalendarProvider.appleDevice,
          (_) => fullTemplate(
            id: 'x',
            userId: _a,
            provider: CalendarProvider.google,
            calendarId: 'conn-1/primary',
          ),
        ),
      ];
  for (final (name, calendar, device, template) in stays) {
    test('stays pending, intact: $name', () async {
      await w.connect(_a, calendar, device: device);
      final file = template(tag);
      await stash(_a, [file]);
      expect(await w.attach(_a), 0);
      expect(await w.attached(_a), isEmpty);
      expect(
        contents((await w.pending(_a)).single.settings),
        contents(file.settings),
      );
    });
  }

  test('the series already set here wins; the template stays', () async {
    final account = await w.connect(_a, workCalendar);
    final mine = fullSeries(
      id: 'mine',
      userId: _a,
      accountId: account,
    ).copyWith(title: 'My standup');
    await w.setSeries(mine);
    await stash(_a, [t()]);
    expect(await w.attach(_a), 0);
    expect((await w.attached(_a)).single.title, 'My standup');
    expect(await w.pending(_a), hasLength(1));
  });

  test("never another owner's: B's calendar can't take A's template, and "
      'B never sees it', () async {
    await stash(_a, [t()]);
    await w.app.signIn(_b);
    await w.connect(_b, workCalendar);
    expect(await w.attach(_b), 0);
    expect(await w.pending(_b), isEmpty);
    expect(await w.attached(_b), isEmpty);
    expect(await w.pending(_a), hasLength(1), reason: 'kept for A');
    // Back on A, which never switched Work on: B's row is not A's.
    await w.app.signIn(_a);
    expect(await w.attach(_a), 0);
    expect(await w.attached(_b), isEmpty);
    expect(await w.pending(_a), hasLength(1));
  });

  test('A → B → A: an attach begun in the old session attaches nothing; the '
      'new session does', () async {
    await w.connect(_a, workCalendar);
    await stash(_a, [t()]);
    final old = await beginPull(w.db, _a);
    await w.app.signIn(_b);
    await w.app.signIn(_a);
    await expectLater(
      attachPendingCalendarSeries(w.db, old, FakeIds('x')),
      throwsA(isA<PullRefusedException>()),
    );
    expect(await w.attached(_a), isEmpty);
    expect(await w.attach(_a), 1);
  });

  test(
    'not while A is sealed for deletion: nothing stashed or attached',
    () async {
      await w.connect(_a, workCalendar);
      await stash(_a, [t()]);
      await sealForDeletion(w.db, _a);
      expect(
        await stashCalendarSeriesTemplates(w.db, _a, [t()], FakeIds('q')),
        isA<Err<void, AppFailure>>(),
      );
      await expectLater(w.attach(_a), throwsA(isA<PullRefusedException>()));
      expect(await w.attached(_a), isEmpty);
    },
  );

  test('not for an account that is not shown', () async {
    await w.app.signIn(_b);
    expect(
      await stashCalendarSeriesTemplates(w.db, _a, [t()], FakeIds('q')),
      isA<Err<void, AppFailure>>(),
    );
    expect(await w.pending(_a), isEmpty);
  });

  test("the account's removal takes its pending templates, no one "
      "else's", () async {
    await stash(_a, [t()]);
    await w.app.signIn(_b);
    await stash(_b, [t(owner: _b)]);
    await beginAccountRemoval(w.db, _a);
    await finishAccountRemoval(w.db, _a);
    expect(await w.pending(_a), isEmpty);
    expect(await w.pending(_b), hasLength(1));
  });
}
