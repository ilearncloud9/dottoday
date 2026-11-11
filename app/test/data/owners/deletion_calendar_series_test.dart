import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/calendar/pending_calendar_series.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/calendar_fakes.dart';
import '../../support/calendar_template_fixtures.dart';
import '../../support/calendar_template_world.dart';
import '../../support/deletion_world.dart';
import '../../support/fake_clock.dart';
import '../../support/fake_ids.dart';
import '../../support/owner_app.dart';

// D1's export carries every calendar-series template (CR-160 Stage A), and
// the full path export → delete → import → reconnect brings each back
// pending under the new account. Apple device calendars on this install
// attach on the next calendar import; Android and Google/Microsoft ones
// stay pending, whole, rather than attach to an unverified calendar.

const _a = '01928c3e-0000-7000-8000-0000000000aa';
const _b = '01928c3e-0000-7000-8000-0000000000bb';

/// A weekly standup in Work, instances from an hour from now.
final _standup = ExternalEvent(
  id: 'EVT-standup',
  calendarId: 'work',
  title: 'Daily sync',
  startUtc: ownerAppNow.add(const Duration(hours: 1)),
  endUtc: ownerAppNow.add(const Duration(hours: 2)),
  repeating: true,
  seriesId: 'EVT-standup',
);

Future<Result<void, AppFailure>> _importCalendar(
  DeletionWorld w,
  String owner,
) async {
  final os = FakeDeviceCalendarGateway(
    state: PermissionState.granted,
    list: const [workCalendar],
    events: {
      'work': [_standup],
    },
  );
  final clock = FakeClock(ownerAppNow);
  final sources = DriftCalendarSourceRepository(
    w.db,
    provider: CalendarProvider.appleDevice,
    clock: clock,
    ids: FakeIds('acc-$owner'),
  );
  final importer = CalendarImporter(
    db: w.db,
    gateway: os,
    sources: sources,
    effects: w.app.container.read(afterWriteEffectsProvider),
    clock: clock,
    ids: FakeIds('cal-$owner'),
    logger: Logger(ownerAppLogs, clock),
  );
  final rows = await sources.watchDevice(owner).first;
  return importer.run(
    userId: owner,
    choices: calendarChoices(os.list, rows, const {}),
    location: tz.getLocation('UTC'),
    untitled: 'Untitled',
  );
}

/// D1's file without the section, as an older build wrote it.
final class _WithoutTemplates implements ExportService {
  _WithoutTemplates(this.real);
  final ExportService real;

  @override
  Future<Result<List<ExportFile>, AppFailure>> build(
    String userId,
    ExportFormat format, {
    bool forAccountDeletion = false,
  }) async {
    final built = await real.build(
      userId,
      format,
      forAccountDeletion: forAccountDeletion,
    );
    final json =
        jsonDecode(
                (built as Ok<List<ExportFile>, AppFailure>)
                    .value
                    .single
                    .content,
              )
              as Map<String, Object?>
          ..remove('calendarSeries');
    return Ok([
      ExportFile(
        name: 'x.json',
        mimeType: 'application/json',
        content: jsonEncode(json),
      ),
    ]);
  }

  @override
  Future<Result<PreparedExport, AppFailure>> prepareSet(
    String userId, {
    required String appVersion,
  }) => real.prepareSet(userId, appVersion: appVersion);
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late DeletionWorld w;
  late String tag;
  setUp(() async {
    w = await DeletionWorld.boot(_a);
    w.server.revision = 7;
    tag = await w.deviceTag();
    // A set an Apple and a Google series (no instance of either here), and
    // has an Android template still pending from an earlier restore.
    final work = await w.connect(_a, workCalendar);
    final google = await w.connect(_a, googleCalendar('conn-a'));
    await w.setSeries(fullSeries(id: 's-apple', userId: _a, accountId: work));
    await w.setSeries(
      fullSeries(
        id: 's-google',
        userId: _a,
        accountId: google,
        seriesKey: 'g-weekly',
      ).copyWith(title: 'Weekly review'),
    );
    await stashCalendarSeriesTemplates(w.db, _a, [
      fullTemplate(
        id: 'x',
        userId: _a,
        provider: CalendarProvider.androidDevice,
        calendarId: '3',
        seriesKey: '57',
        deviceTag: tag,
      ),
    ], FakeIds('p'));
    await w.actions.summary(_a); // D1 opened
  });
  tearDown(() => w.dispose());

  ExportBundle file() =>
      (decodeExportJson(w.exported()) as Ok<ExportBundle, ValidationFailure>)
          .value;

  test('D1 exports every template, attached and pending, with or without '
      'instances; device ones say which install', () async {
    expect(await w.actions.exportFirst(_a), OwnerExportOutcome.done);
    final got = {for (final t in file().calendarSeries) t.seriesKey: t};
    expect(got.keys, {'EVT-standup', 'g-weekly', '57'});
    expect(
      (got['EVT-standup']!.provider, got['EVT-standup']!.externalCalendarId),
      (CalendarProvider.appleDevice, 'work'),
    );
    expect(got['EVT-standup']!.deviceTag, tag);
    expect(got['g-weekly']!.externalCalendarId, 'conn-a/primary');
    expect(got['g-weekly']!.deviceTag, isNull);
    expect(
      contents(got['EVT-standup']!.settings),
      contents(fullSeries(id: '', userId: _a)),
    );
  });

  test('a file missing them fails the check, nothing handed over', () async {
    final outcome = await exportOwnerChecked(
      db: w.db,
      exports: _WithoutTemplates(
        DriftExportService(
          db: w.db,
          clock: FakeClock(ownerAppNow),
          logger: Logger(ownerAppLogs, FakeClock(ownerAppNow)),
        ),
      ),
      files: w.files,
      logger: Logger(ownerAppLogs, FakeClock(ownerAppNow)),
      owner: _a,
    );
    expect(outcome, OwnerExportOutcome.failed);
    expect(w.files.delivered, isEmpty);
  });

  test('a template restored after the review stops the deletion', () async {
    await stashCalendarSeriesTemplates(w.db, _a, [
      fullTemplate(id: 'y', userId: _a, seriesKey: 'EVT-new', deviceTag: tag),
    ], FakeIds('q'));
    expect(
      (await w.actions.deleteAccount() as Err).failure,
      isA<ReviewChangedFailure>(),
    );
    expect(w.server.askedAt, isEmpty);
  });

  test('a template attaching after the review stops the deletion', () async {
    await stashCalendarSeriesTemplates(w.db, _a, [
      fullTemplate(id: 'y', userId: _a, seriesKey: 'EVT-new', deviceTag: tag),
    ], FakeIds('q'));
    await w.actions.summary(_a); // reviewed with it pending
    expect(await w.attach(_a), 1);
    expect(
      (await w.actions.deleteAccount() as Err).failure,
      isA<ReviewChangedFailure>(),
    );
    expect(w.server.askedAt, isEmpty);
  });

  test('export → delete → import into B → B reconnects: Apple attaches on '
      'the import; Android and Google stay pending, intact', () async {
    expect(await w.actions.exportFirst(_a), OwnerExportOutcome.done);
    final exported = w.exported();
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    w.actions.endDeletion(_a);
    expect(await w.pending(_a), isEmpty, reason: 'gone with the account');
    expect(await w.attached(_a), isEmpty);

    await w.app.signIn(_b);
    expect(await w.importFile(_b, exported), isA<Ok<void, AppFailure>>());
    final restored = await w.pending(_b);
    expect(restored.map((t) => t.seriesKey).toSet(), {
      'EVT-standup',
      'g-weekly',
      '57',
    });
    expect(restored.every((t) => t.userId == _b), isTrue);
    expect(await w.attached(_b), isEmpty, reason: 'nothing on import');

    // B connects Google again (a new connection id) and Android's "3".
    await w.connect(_b, googleCalendar('conn-b'));
    await w.connect(
      _b,
      androidCalendar,
      device: CalendarProvider.androidDevice,
    );
    expect(await _importCalendar(w, _b), isA<Ok<void, AppFailure>>());

    final apple = (await w.attached(_b)).single;
    expect(apple.seriesKey, 'EVT-standup');
    expect(contents(apple), contents(fullSeries(id: '', userId: _b)));
    final instance =
        (await (w.db.select(
              w.db.occurrences,
            )..where((o) => o.userId.equals(_b))).get())
            .map(occurrenceFromRow)
            .where((o) => o.source == OccurrenceSource.calendar);
    expect(
      (instance.first.title, instance.first.colorKey),
      ('Standup', 'mint'),
      reason: 'the new instance takes the restored settings',
    );

    final left = {for (final t in await w.pending(_b)) t.seriesKey: t};
    expect(left.keys, {'g-weekly', '57'});
    final before = {for (final t in file().calendarSeries) t.seriesKey: t};
    for (final key in left.keys) {
      expect(
        contents(left[key]!.settings),
        contents(before[key]!.settings),
        reason: '$key kept whole',
      );
    }
    await w.app.idle();
  });

  test('restored on another install: even Apple stays pending', () async {
    expect(await w.actions.exportFirst(_a), OwnerExportOutcome.done);
    final exported = w.exported();
    final other = await DeletionWorld.boot(_b);
    addTearDown(other.dispose);
    expect(await other.importFile(_b, exported), isA<Ok<void, AppFailure>>());
    expect(await _importCalendar(other, _b), isA<Ok<void, AppFailure>>());
    expect(await other.attached(_b), isEmpty);
    expect(await other.pending(_b), hasLength(3));
    await other.app.idle();
  });
}
