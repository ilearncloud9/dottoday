import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_key_store.dart';

/// Opens the app database (stub for platforms with neither FFI nor JS).
AppDatabase openAppDatabase(DatabaseKeyStore keys) =>
    throw UnsupportedError('No database backend for this platform.');
