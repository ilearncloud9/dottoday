import 'dart:io';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/wake_up/tier_gained.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tier_seen_store.g.dart';

const _seenKey = 'alarm_tier_seen';
const _gainedKey = 'alarm_tier_gained_at';

/// The OS's version string; tests override it.
@riverpod
String osVersion(Ref ref) => kIsWeb ? '' : Platform.operatingSystemVersion;

/// When an OS update last brought this phone the alarm tier (docs/15 §11),
/// or null. Each look stores what the device can do now (`local_meta`,
/// this device only), so the next OS update is compared with it. Off a
/// phone, null.
@riverpod
Future<DateTime?> alarmTierGainedAt(Ref ref) async {
  final caps = await ref.watch(alarmCapabilitiesNowProvider.future);
  if (caps.blockers.contains(AlarmBlocker.notAPhone)) return null;
  final db = ref.read(appDatabaseProvider);
  final now = TierSeen(caps.tier, ref.watch(osVersionProvider));
  final before = TierSeen.parse(await _read(db, _seenKey));
  if (tierGainedByUpdate(before, now)) {
    final at = ref.read(clockProvider).nowUtc();
    await _write(db, _gainedKey, '${at.millisecondsSinceEpoch}');
  }
  await _write(db, _seenKey, now.stored);
  final gained = int.tryParse(await _read(db, _gainedKey) ?? '');
  return gained == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(gained, isUtc: true);
}

Future<String?> _read(AppDatabase db, String key) async => (await (db.select(
  db.localMeta,
)..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

Future<void> _write(AppDatabase db, String key, String value) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(LocalMetaCompanion.insert(key: key, value: value));
