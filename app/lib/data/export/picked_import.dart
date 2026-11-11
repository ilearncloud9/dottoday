/// What the files picked for an import are (CR-160 B7b,
/// docs/cr-160-multipart-export.md §2, §5): one JSON v1 backup, or the
/// files of a multipart set gathered over one or more picks. Files are
/// read one at a time; a file over the import limit is refused by its size
/// before it is read. A set is checked whole (every hash, index and count)
/// only once every file is in; the import itself then stages it again.
library;

import 'dart:convert';

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/import_file_kind.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';

/// Why picked files can't be imported.
enum PickRefusal {
  /// A file over the import limit (never read).
  tooLarge,

  /// Not a Dottoday backup, from a newer version, or a set's file changed.
  notBackup,

  /// A file of another backup than the one being gathered.
  foreign,
}

/// The result of reading picked files.
sealed class PickedImport {
  const PickedImport();
}

/// One JSON v1 backup and what it holds (today's import).
final class PickedSingle extends PickedImport {
  const PickedSingle(this.text, this.bundle);
  final String text;
  final ExportBundle bundle;
}

/// A set, complete or still being gathered.
final class PickedSet extends PickedImport {
  const PickedSet(this.draft);
  final SetDraft draft;
}

final class PickRefused extends PickedImport {
  const PickRefused(this.reason);
  final PickRefusal reason;
}

/// A multipart set gathered so far: its manifest when picked, and each
/// part's file by index.
final class SetDraft {
  String? exportId;
  String? manifestText;
  ExportManifest? manifest;
  int? partCount;
  final parts = <int, PickedFile>{};

  /// Tasks not in Trash, counted when the set was checked complete.
  int? liveTasks;

  /// Files in so far, the manifest counted.
  int get added => parts.length + (manifestText == null ? 0 : 1);

  /// Files in the set, once a manifest or part says; the manifest counted.
  int? get total => partCount == null ? null : partCount! + 1;

  /// Every file is in and the set checked whole.
  bool get complete => liveTasks != null;

  /// Each part's text, read when the import needs it, in order.
  List<Future<String> Function()> get readers => [
    for (var i = 1; i <= partCount!; i++)
      () async => utf8.decode(await parts[i]!.read()),
  ];
}

/// Adds [files] to [draft] (null: a fresh pick). One v1 file alone is a
/// [PickedSingle]; anything else must be files of one set.
Future<PickedImport> addPicked(SetDraft? draft, List<PickedFile> files) async {
  final set = draft ?? SetDraft();
  for (final f in files) {
    final text = await _text(f);
    if (text case PickRefused()) return text;
    final json = text as String;
    switch (importFileKind(json)) {
      case ImportFileKind.legacy when draft == null && files.length == 1:
        return switch (decodeExportJson(json)) {
          Ok(:final value) => PickedSingle(json, value),
          Err() => const PickRefused(PickRefusal.notBackup),
        };
      case ImportFileKind.manifest:
        final m = ExportManifest.decode(json);
        if (m == null) return const PickRefused(PickRefusal.notBackup);
        if (!_same(set, m.exportId, m.parts.length)) {
          return const PickRefused(PickRefusal.foreign);
        }
        set
          ..manifestText = json
          ..manifest = m;
      case ImportFileKind.part:
        final head = _head(json);
        if (head == null) return const PickRefused(PickRefusal.notBackup);
        if (!_same(set, head.exportId, head.total)) {
          return const PickRefused(PickRefusal.foreign);
        }
        set.parts.putIfAbsent(head.index, () => f);
      case ImportFileKind.legacy:
        return const PickRefused(PickRefusal.foreign);
      case ImportFileKind.tooLarge:
        return const PickRefused(PickRefusal.tooLarge);
      case ImportFileKind.unknown:
        return const PickRefused(PickRefusal.notBackup);
    }
  }
  if (set.manifest != null && set.parts.length == set.partCount) {
    final live = await _checkWhole(set);
    if (live == null) return const PickRefused(PickRefusal.notBackup);
    set.liveTasks = live;
  }
  return PickedSet(set);
}

/// Whether a file of export [id] with [parts] parts belongs to [set] (the
/// first file says which set it is).
bool _same(SetDraft set, String id, int parts) {
  set.exportId ??= id;
  set.partCount ??= parts;
  return set.exportId == id && set.partCount == parts;
}

({String exportId, int index, int total})? _head(String json) {
  try {
    final m = jsonDecode(json);
    if (m case {
      'exportId': final String id,
      'index': final int index,
      'total': final int total,
    } when index >= 1 && index <= total) {
      return (exportId: id, index: index, total: total);
    }
  } on FormatException {
    return null;
  }
  return null;
}

/// Every part against the manifest, one at a time; the tasks not in Trash,
/// or null when any part is changed or the set isn't whole. A changed part
/// leaves the draft, so the right file can be added in its place.
Future<int?> _checkWhole(SetDraft set) async {
  final parts = PartSet(set.manifest!);
  var live = 0;
  for (var i = 1; i <= set.partCount!; i++) {
    final text = await _text(set.parts[i]!);
    if (text is! String) {
      set.parts.remove(i);
      return null;
    }
    switch (parts.add(text)) {
      case PartRefused() || PartAccepted(duplicate: true):
        set.parts.remove(i);
        return null;
      case PartAccepted(:final part):
        live += part.rows['occurrences']!
            .where((o) => o['deleted_at'] == null)
            .length;
    }
  }
  return parts.complete ? live : null;
}

/// [f]'s text, or why not: over the limit by its size (never read), or
/// not UTF-8.
Future<Object> _text(PickedFile f) async {
  if ((f.size ?? 0) > maxImportBytes) {
    return const PickRefused(PickRefusal.tooLarge);
  }
  final bytes = await f.read();
  if (bytes.length > maxImportBytes) {
    return const PickRefused(PickRefusal.tooLarge);
  }
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return const PickRefused(PickRefusal.notBackup);
  }
}
