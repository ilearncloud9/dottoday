import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dottoday/data/export/prepared_file.dart';

/// Native: each file in a fresh temporary folder, so a set holds one part
/// in memory at a time and is shared by path.
PreparedFileStore platformPreparedFileStore() => TempPreparedFileStore();

/// Writes each file beside itself as `.part`, flushes and renames it into
/// place (never a half-written file that looks like an export), then reads
/// it back and checks its hash.
final class TempPreparedFileStore implements PreparedFileStore {
  Directory? _dir;

  @override
  Future<PreparedFile> put(String name, List<int> bytes, String hash) async {
    final dir = _dir ??= await Directory.systemTemp.createTemp(
      'dottoday-export',
    );
    final target = File('${dir.path}${Platform.pathSeparator}$name');
    final part = File('${target.path}.part');
    try {
      await part.writeAsBytes(bytes, flush: true);
      await part.rename(target.path);
    } on FileSystemException {
      if (part.existsSync()) await part.delete();
      rethrow;
    }
    final back = await target.readAsBytes();
    if (sha256.convert(back).toString() != hash) {
      await target.delete();
      throw PreparedMismatch(name);
    }
    return PreparedFile(
      name: name,
      mimeType: jsonMime,
      sha256: hash,
      size: back.length,
      path: target.path,
    );
  }

  @override
  Future<void> discard() async {
    final dir = _dir;
    _dir = null;
    if (dir != null && dir.existsSync()) await dir.delete(recursive: true);
  }
}
