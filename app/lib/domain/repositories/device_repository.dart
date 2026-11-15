import 'package:dottoday/domain/devices/device.dart';

/// The account's device list as this install last saw it (ED-084): a local
/// cache of the server's `devices`, so "Alarm sounds on" reads offline.
abstract interface class DeviceRepository {
  /// [userId]'s devices, not forgotten, most recently seen first.
  Stream<List<Device>> watchAll(String userId);

  /// One device, or null.
  Future<Device?> findById(String userId, String id);

  /// Stores [devices] as given (inserts or replaces by id).
  Future<void> upsertAll(List<Device> devices);
}
