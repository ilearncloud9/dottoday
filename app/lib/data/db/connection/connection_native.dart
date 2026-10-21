import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

/// File name inside the app-support directory (not Documents: never
/// user-visible or iCloud-synced as a document).
const databaseFileName = 'dottoday.db';

/// Opens the encrypted app database on iOS, Android and macOS (06 §4).
AppDatabase openAppDatabase(DatabaseKeyStore keys) => AppDatabase(
  LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$databaseFileName');
    final key = await keys.obtainHexKey();
    return NativeDatabase.createInBackground(
      file,
      setup: (raw) => configureCipherConnection(raw, key),
    );
  }),
);
