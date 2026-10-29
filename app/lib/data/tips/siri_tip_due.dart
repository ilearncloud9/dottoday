import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/intents/siri_providers.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/domain/tips/siri_tip.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'siri_tip_due.g.dart';

/// Whether Today's one-time Siri card is due (docs/09 M14.3,
/// [showsSiriTip]). Counting starts the first time Today asks after
/// onboarding finished (`tip_siri_armed_at` in `local_meta`, this device
/// only), so onboarding's starter tasks don't count; any way of adding
/// (Add, Quick Add, a share, Siri) does — it reads the rows, not a flow.
@riverpod
Stream<bool> siriTipDue(Ref ref) async* {
  if (!ref.watch(siriAvailableProvider)) {
    yield false;
    return;
  }
  final onboarding = await ref.watch(onboardingProvider.future);
  final seen = await ref.watch(seenTipsProvider.future);
  if (!onboarding.finished || seen.contains(Tip.siriToday)) {
    yield false;
    return;
  }
  final db = ref.read(appDatabaseProvider);
  final armed = await _armedAt(db, ref.read(clockProvider).nowUtc());
  final count = db.occurrences.id.count();
  final query = db.selectOnly(db.occurrences)
    ..addColumns([count])
    ..where(
      db.occurrences.source.equals('user') &
          db.occurrences.createdAt.isBiggerThanValue(armed),
    );
  yield* query.watchSingle().map(
    (row) => showsSiriTip(
      siri: true,
      onboarded: true,
      putAway: false,
      added: row.read(count) ?? 0,
    ),
  );
}

const _armedKey = 'tip_siri_armed_at';

/// When counting started (ms epoch); set now on the first call.
Future<int> _armedAt(AppDatabase db, DateTime nowUtc) async {
  final row = await (db.select(
    db.localMeta,
  )..where((m) => m.key.equals(_armedKey))).getSingleOrNull();
  final stored = int.tryParse(row?.value ?? '');
  if (stored != null) return stored;
  final now = nowUtc.millisecondsSinceEpoch;
  await db
      .into(db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(key: _armedKey, value: '$now'),
      );
  return now;
}
