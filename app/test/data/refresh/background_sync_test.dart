import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/refresh/daily_refresh.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/sync/background_sync.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/data/widgets/widget_snapshot_writer.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_sync_server.dart';
import '../../support/sync_device.dart';

// The background job syncs before it re-plans (docs/09 M6.5.6, 11 A0): a
// task planned on the Mac is on the phone, with its reminder, before
// Wake Up — without the app being opened.

const _account = '01928c3e-0000-7000-8000-0000000000ff';
final _t = DateTime.utc(2026, 10, 23, 20);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer server;
  late SyncDevice mac;
  late SyncDevice phone;

  setUp(() async {
    server = FakeSyncServer(_account);
    mac = SyncDevice(server, _t, name: 'mac');
    phone = SyncDevice(server, _t, name: 'phone');
    await mac.start();
    await phone.start();
  });
  tearDown(() async {
    await mac.close();
    await phone.close();
  });

  DailyRefresh refreshOn(SyncDevice d, {String? account = _account}) {
    final h = d.h;
    return DailyRefresh(
      clock: h.clock,
      series: DriftSeriesRepository(h.db),
      writes: h.writes,
      notifications: NotificationSync(
        clock: h.clock,
        planner: NotificationPlanner(clock: h.clock),
        gateway: h.gateway,
        occurrences: DriftOccurrenceRepository(h.db),
        series: DriftSeriesRepository(h.db),
        settings: DriftSettingsRepository(h.db),
      ),
      widgets: WidgetSnapshotWriter(
        clock: h.clock,
        occurrences: DriftOccurrenceRepository(h.db),
        sink: h.sink,
      ),
      logger: h.logger,
      sync: BackgroundSync(
        engine: d.engine,
        accountId: () => account,
        logger: h.logger,
      ),
    );
  }

  final tomorrow = occurrenceFixture().copyWith(
    userId: _account,
    title: 'Run',
    startUtc: DateTime.utc(2026, 10, 24, 6),
    tzId: 'UTC',
    alerts: const [Alert(kind: AlertKind.atStart)],
  );

  test('a task made on the Mac lands on the phone and is scheduled', () async {
    await mac.write([tomorrow]);
    await mac.sync();
    await phone.h.effects.idle;
    phone.h.gateway.pendingSet.clear();

    expect(await refreshOn(phone).run(_account), isTrue);

    expect((await phone.occurrence(tomorrow.id))!.title, 'Run');
    final pending = phone.h.gateway.pendingSet.values;
    expect(pending.map((n) => n.occurrenceId), contains(tomorrow.id));
    // The first dot of Saturday rings loud (M6.5.3).
    final start = pending.firstWhere(
      (n) => n.occurrenceId == tomorrow.id && n.kind == AlertKind.atStart,
    );
    expect(start.loud, isTrue);
  });

  test('offline: the job still re-plans and keeps the outbox', () async {
    await phone.write([tomorrow.copyWith(title: 'Swim')]);
    final waiting = await phone.outboxSize();
    server.failNext = SyncTrouble.offline;
    phone.h.gateway.pendingSet.clear();

    expect(await refreshOn(phone).run(_account), isFalse);

    expect(await phone.outboxSize(), waiting);
    expect((await phone.occurrence(tomorrow.id))!.title, 'Swim');
    expect(phone.h.gateway.pendingSet, isNotEmpty);
  });

  test('signed out or not yet adopted: no round trip', () async {
    await mac.write([tomorrow]);
    await mac.sync();
    expect(await refreshOn(phone, account: null).run(_account), isTrue);
    expect(
      await refreshOn(phone, account: 'someone-else').run(_account),
      isTrue,
    );
    expect(await phone.occurrence(tomorrow.id), isNull);
  });
}
