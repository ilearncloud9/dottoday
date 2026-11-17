/// "Check my files" (CR-160 B7, docs/cr-160-multipart-export.md §10
/// state 3): the files the person picked back, read one at a time, against
/// the set prepared on this device.
library;

import 'dart:convert';

import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/domain/export/export_handoff.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/import_file_kind.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';

/// How the picked files compare with the prepared set.
sealed class PickedSetCheck {
  const PickedSetCheck();
}

/// Every file is here and matches: possession confirmed.
final class PickedSetComplete extends PickedSetCheck {
  const PickedSetComplete();
}

/// [missing] of the set's files weren't picked; the rest match.
final class PickedSetMissing extends PickedSetCheck {
  const PickedSetMissing(this.missing);
  final int missing;
}

/// A file is another export's, changed, unreadable or picked twice.
final class PickedSetWrong extends PickedSetCheck {
  const PickedSetWrong();
}

/// Checks [picked] against [prepared]. Each file is read to find the
/// manifest, then each part read again and matched, so at most one file is
/// in memory at a time.
Future<PickedSetCheck> checkPickedSet(
  ExportManifest prepared,
  List<PickedFile> picked,
) async {
  String? manifest;
  final parts = <PickedFile>[];
  for (final f in picked) {
    final text = await _text(f);
    if (text == null) return const PickedSetWrong();
    if (importFileKind(text) == ImportFileKind.manifest) {
      if (manifest != null) return const PickedSetWrong();
      manifest = text;
    } else {
      parts.add(f);
    }
  }
  if (manifest != null) {
    // Only the manifest: a different one is another export's.
    final m = checkPossession(prepared, manifest, const []);
    if (m case PossessionNotConfirmed(
      problem: PossessionProblem.notThisExport,
    )) {
      return const PickedSetWrong();
    }
  }
  // Matched as checkPossession does, one part read at a time.
  final set = PartSet(prepared);
  for (final f in parts) {
    final text = await _text(f);
    if (text == null) return const PickedSetWrong();
    switch (set.add(text)) {
      case PartRefused() || PartAccepted(duplicate: true):
        return const PickedSetWrong();
      case PartAccepted():
    }
  }
  final missing = set.missing.length + (manifest == null ? 1 : 0);
  return missing == 0 ? const PickedSetComplete() : PickedSetMissing(missing);
}

Future<String?> _text(PickedFile f) async {
  if ((f.size ?? 0) > maxImportBytes) return null;
  final bytes = await f.read();
  if (bytes.length > maxImportBytes) return null;
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return null;
  }
}
