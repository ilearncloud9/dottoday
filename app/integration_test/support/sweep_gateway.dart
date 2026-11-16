import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/domain/export/export_files.dart';

// CR-160 B7 gate: the set screens on a device without the native share
// sheet, folder picker or file picker, which a test can't drive. Every
// handoff "delivers" and keeps a copy of the files' bytes; every pick
// returns what the sweep queued, read from those copies. The real sheets
// are captured separately (docs/cr-160-multipart-export.md, B7 gate).

/// A [FileGateway] that keeps what it was handed and picks what it is told.
final class SweepGateway implements FileGateway {
  /// Every file handed over or downloaded, in order. Kept by position,
  /// not name: two exports a minute apart can share their file names
  /// (the stem takes the export id's first 8 characters, a UUID v7's
  /// time; found in this gate).
  final handed = <({String name, Uint8List bytes})>[];
  final _picks = <List<int>>[];

  /// The next file picker opening returns the files handed over at [at].
  void queuePick(List<int> at) => _picks.add(at);

  @override
  Future<DeliveryOutcome> deliver(
    List<ExportFile> files, {
    Rect? origin,
  }) async => DeliveryOutcome.delivered;

  @override
  Future<DeliveryOutcome> shareImage(
    Uint8List png, {
    required String name,
    Rect? origin,
  }) async => DeliveryOutcome.delivered;

  @override
  Future<DeliveryOutcome> deliverPrepared(
    List<PreparedFile> files, {
    Rect? origin,
  }) async {
    for (final f in files) {
      await _keep(f);
    }
    return DeliveryOutcome.delivered;
  }

  @override
  Future<void> downloadPrepared(PreparedFile file) => _keep(file);

  @override
  Future<List<PickedFile>> pickJsonFiles() async {
    if (_picks.isEmpty) return const [];
    return [
      for (final i in _picks.removeAt(0))
        PickedFile(
          handed[i].name,
          handed[i].bytes.length,
          () async => handed[i].bytes,
        ),
    ];
  }

  Future<void> _keep(PreparedFile f) async {
    final bytes = f.bytes ?? await File(f.path!).readAsBytes();
    handed.add((name: f.name, bytes: bytes));
  }
}
