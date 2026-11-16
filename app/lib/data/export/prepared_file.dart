/// Prepared export files (CR-160 Stage B6, docs/cr-160-multipart-export.md
/// §10 state 1): each file written and read back with a matching hash on
/// this device before anything is handed over. Native keeps them as
/// temporary files, one part in memory at a time; the web keeps the bytes
/// (it downloads them).
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

export 'prepared_file_store_stub.dart'
    if (dart.library.io) 'prepared_file_store_io.dart';

/// One prepared file: its name, type, SHA-256 and size, and where it is.
final class PreparedFile {
  const PreparedFile({
    required this.name,
    required this.mimeType,
    required this.sha256,
    required this.size,
    this.path,
    this.bytes,
  });

  final String name;
  final String mimeType;
  final String sha256;
  final int size;

  /// The temporary file (native).
  final String? path;

  /// The bytes (web).
  final Uint8List? bytes;
}

/// Thrown when a file read back doesn't match what was written.
final class PreparedMismatch implements Exception {
  const PreparedMismatch(this.name);
  final String name;
}

/// Where a set's files are prepared.
abstract interface class PreparedFileStore {
  /// Writes [bytes] (the UTF-8 of a JSON file whose SHA-256 is [hash]) as
  /// [name], reads it back and checks the hash; throws [PreparedMismatch]
  /// (the file removed) when it differs.
  Future<PreparedFile> put(String name, List<int> bytes, String hash);

  /// Removes every file this store prepared.
  Future<void> discard();
}

/// Keeps each file's bytes in memory: the web, and tests.
final class MemoryPreparedFileStore implements PreparedFileStore {
  final _files = <PreparedFile>[];

  @override
  Future<PreparedFile> put(String name, List<int> bytes, String hash) async {
    final copy = Uint8List.fromList(bytes);
    if (sha256.convert(copy).toString() != hash) {
      throw PreparedMismatch(name);
    }
    final f = PreparedFile(
      name: name,
      mimeType: jsonMime,
      sha256: hash,
      size: copy.length,
      bytes: copy,
    );
    _files.add(f);
    return f;
  }

  @override
  Future<void> discard() async => _files.clear();
}

const jsonMime = 'application/json';

/// The UTF-8 text of a prepared file (tests, and the web's possession
/// check).
String preparedText(PreparedFile f) => utf8.decode(f.bytes!);
