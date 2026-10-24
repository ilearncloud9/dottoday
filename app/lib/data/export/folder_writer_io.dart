import 'dart:io';

import 'package:dottoday/domain/export/export_files.dart';

/// Writes [files] into [folder] (a folder the person picked, Mac). Each is
/// written beside it as `.part` and renamed into place once flushed, so a
/// failure never leaves a half-written file that looks like an export
/// (data-export skill rule 7); the `.part` is removed on failure.
Future<void> writeToFolder(String folder, List<ExportFile> files) async {
  for (final f in files) {
    final target = File('$folder${Platform.pathSeparator}${f.name}');
    final part = File('${target.path}.part');
    try {
      await part.writeAsString(f.content, flush: true);
      await part.rename(target.path);
    } on FileSystemException {
      if (part.existsSync()) await part.delete();
      rethrow;
    }
  }
}
