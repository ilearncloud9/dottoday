import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/repositories/device_repository.dart';
import 'package:drift/drift.dart';

/// [DeviceRepository] over the local Drift cache (schema 18).
final class DriftDeviceRepository implements DeviceRepository {
  DriftDeviceRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Device>> watchAll(String userId) {
    final q = _db.select(_db.devicesTable)
      ..where((d) => d.userId.equals(userId) & d.deletedAt.isNull())
      ..orderBy([(d) => OrderingTerm.desc(d.lastSeenUtc)]);
    return q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  @override
  Future<Device?> findById(String userId, String id) async {
    final row =
        await (_db.select(_db.devicesTable)
              ..where((d) => d.userId.equals(userId) & d.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> upsertAll(List<Device> devices) => _db.batch(
    (b) => b.insertAllOnConflictUpdate(_db.devicesTable, [
      for (final d in devices) _toRow(d),
    ]),
  );

  static Device _fromRow(DeviceRow r) => Device(
    id: r.id,
    userId: r.userId,
    platform: DevicePlatform.values.byName(r.platform),
    form: DeviceForm.values.byName(r.form),
    canRing: r.canRing,
    alarmOn: r.alarmOn,
    rings: r.rings,
    armedWakeUtc: _utc(r.armedWakeUtc),
    lastSeenUtc: _utc(r.lastSeenUtc)!,
    deletedAt: _utc(r.deletedAt),
  );

  static DevicesTableCompanion _toRow(Device d) => DevicesTableCompanion.insert(
    id: d.id,
    userId: d.userId,
    platform: d.platform.name,
    form: d.form.name,
    canRing: Value(d.canRing),
    alarmOn: Value(d.alarmOn),
    rings: Value(d.rings),
    armedWakeUtc: Value(d.armedWakeUtc?.millisecondsSinceEpoch),
    lastSeenUtc: d.lastSeenUtc.millisecondsSinceEpoch,
    deletedAt: Value(d.deletedAt?.millisecondsSinceEpoch),
  );

  static DateTime? _utc(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}
