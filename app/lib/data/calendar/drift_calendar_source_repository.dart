import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/daos/calendar_accounts_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/domain/calendar/calendar_source_repository.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';

const _codec = RowCodec();

/// Wire names of the device providers (docs/05 `calendar_accounts`).
const _deviceProviders = {'apple_device', 'android_device'};

/// The longest `label` the table accepts (docs/05 "Validation").
const _maxLabel = 80;

/// [CalendarSourceRepository] over `calendar_accounts`. Rows are local only
/// (never pushed, docs/05), so they are written here rather than through
/// the sync write path.
final class DriftCalendarSourceRepository implements CalendarSourceRepository {
  DriftCalendarSourceRepository(
    AppDatabase db, {
    required this.provider,
    required Clock clock,
    required IdGenerator ids,
  }) : _db = db,
       _dao = CalendarAccountsDao(db),
       _clock = clock,
       _ids = ids;

  /// This device's calendar store: Apple's or Android's.
  final CalendarProvider provider;
  final AppDatabase _db;
  final CalendarAccountsDao _dao;
  final Clock _clock;
  final IdGenerator _ids;

  @override
  Stream<List<CalendarAccount>> watchDevice(String userId) => _dao
      .watchByProviders(userId, _deviceProviders)
      .map((rows) => [for (final r in rows) _fromRow(r)]);

  @override
  Future<void> setEnabled(
    String userId,
    DeviceCalendar calendar, {
    required bool enabled,
  }) => _db.transaction(() async {
    final now = _clock.nowUtc();
    final wire = _wire(provider);
    final existing = await _dao.findExternal(userId, wire, calendar.id);
    final account = existing == null
        ? CalendarAccount(
            id: _ids.newId(),
            userId: userId,
            provider: provider,
            label: _label(calendar.name),
            externalAccountId: calendar.id,
            enabled: enabled,
            createdAt: now,
            updatedAt: now,
          )
        : _fromRow(existing).copyWith(
            label: _label(calendar.name),
            enabled: enabled,
            updatedAt: now,
          );
    await _dao.upsert(_codec.encode<CalendarAccountRow>(account.toJson()));
  });

  static CalendarAccount _fromRow(CalendarAccountRow row) =>
      CalendarAccount.fromJson(_codec.decode(row));

  static String _wire(CalendarProvider p) => switch (p) {
    CalendarProvider.appleDevice => 'apple_device',
    CalendarProvider.androidDevice => 'android_device',
    CalendarProvider.google => 'google',
    CalendarProvider.microsoft => 'microsoft',
    CalendarProvider.caldav => 'caldav',
  };

  static String _label(String name) =>
      name.length <= _maxLabel ? name : name.substring(0, _maxLabel);
}
