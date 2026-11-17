import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';

/// The settings a guest had when it was adopted into an account that
/// already had its own (CR-160 criterion 7): kept until the person chooses,
/// never applied by themselves. Null when there is nothing to choose.
Future<Profile?> pendingGuestSettings(AppDatabase db, String accountId) async {
  final row = await (db.select(
    db.localMeta,
  )..where((m) => m.key.equals(guestSettingsKey(accountId)))).getSingleOrNull();
  if (row == null) return null;
  return Profile.fromJson(jsonDecode(row.value) as Map<String, Object?>);
}

/// "Use this device's settings": the guest's time zone, language and
/// preferences become the account's, as one ordinary edit (it syncs like
/// any other, with the normal conflict rules). The account's name stays.
/// The kept copy goes only once the edit is written.
Future<Result<void, AppFailure>> useGuestSettings(
  AppDatabase db,
  WriteUseCase writes,
  Profile account,
) async {
  final guest = await pendingGuestSettings(db, account.id);
  if (guest == null) return const Ok(null);
  final written = await writes.apply(
    WriteBatch(
      userId: account.id,
      profile: account.copyWith(
        tzId: guest.tzId,
        locale: guest.locale,
        settings: guest.settings,
      ),
    ),
  );
  if (written is Ok) await _forget(db, account.id);
  return written;
}

/// "Keep account settings": the account's stay; the kept copy goes.
Future<void> keepAccountSettings(AppDatabase db, String accountId) =>
    _forget(db, accountId);

Future<void> _forget(AppDatabase db, String accountId) => (db.delete(
  db.localMeta,
)..where((m) => m.key.equals(guestSettingsKey(accountId)))).go();
