import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:drift/drift.dart';

// Stubs for platforms with neither FFI nor JS.

AppDatabase openAppDatabase(DatabaseKeyStore keys) =>
    throw UnsupportedError('No database backend for this platform.');

QueryExecutor openEncryptedExecutor(
  DatabaseKeyStore keys,
  String name, {
  int? schemaVersion,
}) => throw UnsupportedError('No database backend for this platform.');

Future<String?> moveDatabaseAside() async => null;

void onHandOffRequest(Future<void> Function() close) {}

Future<bool> askOtherTabToLetGo() async => false;
