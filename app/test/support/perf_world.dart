import 'dart:io';

import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'owner_app.dart';
import 'perf_account.dart';
import 'rss_sampler.dart';

// CR-160 Stage B measurements (test/perf): accounts of a given size and
// SQLCipher files opened as the app opens them.

/// [n] tasks of about 10 KB of JSON each, owned by [owner].
ExportBundle perfAccount(int n, String owner) =>
    perfAccountAt(n, owner, ownerAppNow);

/// A fresh SQLCipher file, WAL, as the app opens its database.
Future<AppDatabase> cipherAppFile() async => AppDatabase(await _cipherFile());

/// The backups file the same way (CR-160 Stage B4).
Future<BackupDatabase> cipherBackupsFile() async =>
    BackupDatabase(await _cipherFile());

Future<NativeDatabase> _cipherFile() async {
  final dir = await Directory.systemTemp.createTemp('dottoday-b-perf');
  addTearDown(() => dir.delete(recursive: true));
  return NativeDatabase(
    File('${dir.path}/dottoday.db'),
    setup: (raw) => configureCipherConnection(raw, 'ef' * 32),
  );
}

/// Prints one measurement (the measurement is the output).
void reportPerf(String what, int bytes, RssMeasure m) {
  // ignore: avoid_print, the measurement is the output.
  print(
    'CR160_PERF $what (${mb(bytes)} MB): ${m.took.inMilliseconds} ms, '
    'peak ${mb(m.peak - m.idle)} MB above idle (idle ${mb(m.idle)} MB)',
  );
}
