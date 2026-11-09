import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';

import '../domain/fixtures.dart';

/// Owners A and B on one device (CR-160).
const ownerA = 'owner-a';
const ownerB = 'owner-b';

/// Adds a profile [id] to [db], as a sign-in on this device would.
Future<void> addProfile(AppDatabase db, String id) =>
    DriftSettingsRepository(db).upsert(profileFixture().copyWith(id: id));

/// Makes [id] the owner the app shows (the step before
/// `OwnerSwitch.signedIn` bumps the epoch).
Future<void> showOwner(AppDatabase db, String id) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(
      LocalMetaCompanion.insert(key: activeOwnerKey, value: id),
    );
