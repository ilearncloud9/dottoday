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

/// Wire names of the connected-account providers (M7.4).
const _cloudProviders = {'google', 'microsoft'};

/// The longest `label` the table accepts (docs/05 "Validation").
const _maxLabel = 80;

/// [CalendarSourceRepository] over `calendar_accounts`. Rows are local only
/// (never pushed, docs/05), so they are written here rather than through
/// the sync write path. A connected Google/Microsoft calendar gets the
/// same kind of row, keyed by its account-qualified id (M7.4): its switch
/// is this device's, like a device calendar's.
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

  /// This device's calendar store: Apple's or Android's (a calendar with
  /// its own [DeviceCalendar.provider] keeps that one).
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
  Stream<List<CalendarAccount>> watchCloud(String userId) => _dao
      .watchByProviders(userId, _cloudProviders)
      .map((rows) => [for (final r in rows) _fromRow(r)]);

  @override
  Future<void> setEnabled(
    String userId,
    DeviceCalendar calendar, {
    required bool enabled,
  }) => _db.transaction(() async {
    final existing = await _find(userId, calendar);
    final account = (existing ?? _create(userId, calendar)).copyWith(
      label: _label(calendar.name),
      enabled: enabled,
      updatedAt: _clock.nowUtc(),
    );
    await _dao.upsert(_codec.encode<CalendarAccountRow>(account.toJson()));
  });

  @override
  Future<void> setWriteBack(
    String userId,
    DeviceCalendar calendar, {
    required bool writeBack,
  }) => _db.transaction(() async {
    final existing = await _find(userId, calendar);
    final account = (existing ?? _create(userId, calendar)).copyWith(
      writeBack: writeBack,
      updatedAt: _clock.nowUtc(),
    );
    await _dao.upsert(_codec.encode<CalendarAccountRow>(account.toJson()));
  });

  @override
  Future<CalendarAccount> ensure(String userId, DeviceCalendar calendar) =>
      _db.transaction(() async {
        final existing = await _find(userId, calendar);
        if (existing != null) return existing;
        final account = _create(userId, calendar);
        await _dao.upsert(_codec.encode<CalendarAccountRow>(account.toJson()));
        return account;
      });

  Future<CalendarAccount?> _find(String userId, DeviceCalendar calendar) async {
    final row = await _dao.findExternal(
      userId,
      _providerOf(calendar).wire,
      calendar.id,
    );
    return row == null ? null : _fromRow(row);
  }

  /// A new row for [calendar]: on, as a never-switched calendar is.
  CalendarAccount _create(String userId, DeviceCalendar calendar) {
    final now = _clock.nowUtc();
    return CalendarAccount(
      id: _ids.newId(),
      userId: userId,
      provider: _providerOf(calendar),
      label: _label(calendar.name),
      externalAccountId: calendar.id,
      createdAt: now,
      updatedAt: now,
    );
  }

  static CalendarAccount _fromRow(CalendarAccountRow row) =>
      CalendarAccount.fromJson(_codec.decode(row));

  CalendarProvider _providerOf(DeviceCalendar calendar) =>
      calendar.provider ?? provider;

  static String _label(String name) =>
      name.length <= _maxLabel ? name : name.substring(0, _maxLabel);
}
