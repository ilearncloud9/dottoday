import 'package:dottoday/domain/devices/device.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The server's device list (migration 0016, RLS: own rows only). Each
/// install upserts only its own row, straight to the table, never through
/// the field-versioned outbox: there is one writer per row.
abstract interface class DeviceRemote {
  /// Inserts or updates this install's [device].
  Future<void> put(Device device);

  /// The signed-in account's devices, forgotten ones left out.
  Future<List<Device>> list();
}

/// [DeviceRemote] on Supabase; every call runs as the user (anon key).
final class SupabaseDeviceRemote implements DeviceRemote {
  SupabaseDeviceRemote(this._client);

  final SupabaseClient _client;

  /// Null while signed out: the list is this install's own row only.
  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<void> put(Device device) async {
    if (_userId != device.userId) return;
    await _client.from('devices').upsert({
      'id': device.id,
      'platform': device.platform.name,
      'form': device.form.name,
      'can_ring': device.canRing,
      'alarm_on': device.alarmOn,
      'rings': device.rings,
      'armed_wake_utc': device.armedWakeUtc?.toIso8601String(),
      'last_seen_utc': device.lastSeenUtc.toIso8601String(),
    });
  }

  @override
  Future<List<Device>> list() async {
    if (_userId == null) return const [];
    final rows = await _client
        .from('devices')
        .select(
          'id, user_id, platform, form, can_ring, alarm_on, rings, '
          'armed_wake_utc, last_seen_utc, deleted_at',
        )
        .isFilter('deleted_at', null);
    return [for (final r in rows) deviceFromServer(r)];
  }
}

/// A server `devices` row as a [Device].
Device deviceFromServer(Map<String, dynamic> r) => Device(
  id: r['id'] as String,
  userId: r['user_id'] as String,
  platform: DevicePlatform.values.byName(r['platform'] as String),
  form: DeviceForm.values.byName(r['form'] as String),
  canRing: r['can_ring'] as bool? ?? false,
  alarmOn: r['alarm_on'] as bool? ?? false,
  rings: r['rings'] as bool? ?? false,
  armedWakeUtc: _instant(r['armed_wake_utc']),
  lastSeenUtc: _instant(r['last_seen_utc'])!,
  deletedAt: _instant(r['deleted_at']),
);

DateTime? _instant(Object? v) => v is String ? DateTime.parse(v).toUtc() : null;
