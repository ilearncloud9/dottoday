import 'dart:math';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/sync/hlc.dart';

/// Persists this device's HLC node id and last issued HLC in `local_meta`
/// so clock order survives restarts (ADR-0002).
final class HlcStore {
  HlcStore(this._db, {Random? random}) : _random = random ?? Random.secure();

  static const _nodeKey = 'hlc_node';
  static const _lastKey = 'hlc_last';

  final AppDatabase _db;
  final Random _random;

  /// The device clock, creating a node id on first use.
  Future<HybridLogicalClock> load(Clock clock) async {
    var node = await _read(_nodeKey);
    if (node == null) {
      node = _newNode();
      await _write(_nodeKey, node);
    }
    final last = await _read(_lastKey);
    return HybridLogicalClock(
      clock: clock,
      nodeId: node,
      last: last == null ? null : Hlc.tryParse(last),
    );
  }

  /// Records [last]; call inside the write transaction that used it.
  Future<void> save(Hlc last) => _write(_lastKey, last.toString());

  String _newNode() => List.generate(
    8,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  Future<String?> _read(String key) async => (await (_db.select(
    _db.localMeta,
  )..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _write(String key, String value) => _db
      .into(_db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(key: key, value: value),
      );
}
