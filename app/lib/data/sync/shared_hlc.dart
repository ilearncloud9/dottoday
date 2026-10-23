import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/hlc_store.dart';
import 'package:dottoday/domain/sync/hlc.dart';

/// This device's one hybrid logical clock (ADR-0002), shared by the write
/// path and the sync engine: every pulled HLC moves it forward, so an edit
/// made after a pull always outranks what was pulled (docs/09 M6.2).
final class SharedHlc {
  SharedHlc(AppDatabase db, this._clock) : _store = HlcStore(db);

  final HlcStore _store;
  final Clock _clock;
  HybridLogicalClock? _hlc;

  /// The clock, loaded once from `local_meta`.
  Future<HybridLogicalClock> clock() async =>
      _hlc ??= await _store.load(_clock);

  /// Records the last issued HLC (inside the caller's transaction).
  Future<void> save() async {
    final hlc = _hlc;
    if (hlc != null) await _store.save(hlc.last);
  }

  /// Merges remote HLCs ([Hlc] strings); malformed ones are ignored.
  Future<void> receive(Iterable<String> remote) async {
    final hlc = await clock();
    for (final r in remote) {
      if (Hlc.tryParse(r) case final h?) hlc.receive(h);
    }
    await save();
  }
}
