import 'dart:convert';
import 'dart:ui' show Rect;

import 'package:dottoday/data/export/folder_writer.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// How handing files to the person ended.
enum DeliveryOutcome {
  /// Shared, saved or downloaded.
  delivered,

  /// The person closed the sheet or dialog.
  cancelled,
}

/// What picking a backup file gave.
sealed class PickedBackup {
  const PickedBackup();
}

/// The person closed the picker.
final class PickCancelled extends PickedBackup {
  const PickCancelled();
}

/// The file is bigger than the import limit; it was never read.
final class PickTooLarge extends PickedBackup {
  const PickTooLarge();
}

/// The file's bytes.
final class PickedBytes extends PickedBackup {
  const PickedBytes(this.bytes);

  final Uint8List bytes;
}

/// The only way files leave or enter the app (docs/09 M8.1, R-11), and only
/// on the person's tap: nothing is uploaded or saved on its own. A port so
/// tests never open a sheet.
abstract interface class FileGateway {
  /// Hands [files] over: the share sheet on iPhone and Android (which also
  /// offers Save to Files / Drive), a save dialog on the Mac (a folder for
  /// several files), downloads on the web. [origin] anchors the iPad and
  /// Mac popovers. Throws only on a platform error.
  Future<DeliveryOutcome> deliver(List<ExportFile> files, {Rect? origin});

  /// Opens the file picker for a `.json` backup and reads it, refusing
  /// anything over [maxBytes] before reading it.
  Future<PickedBackup> pickBackup({required int maxBytes});
}

/// [FileGateway] over `share_plus` and `file_picker`.
final class PlatformFileGateway implements FileGateway {
  const PlatformFileGateway();

  static bool get _sharesFiles =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  Future<DeliveryOutcome> deliver(
    List<ExportFile> files, {
    Rect? origin,
  }) async {
    if (_sharesFiles) return _share(files, origin);
    if (kIsWeb || files.length == 1) return _save(files);
    final folder = await FilePicker.getDirectoryPath();
    if (folder == null) return DeliveryOutcome.cancelled;
    await writeToFolder(folder, files);
    return DeliveryOutcome.delivered;
  }

  Future<DeliveryOutcome> _share(List<ExportFile> files, Rect? origin) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          for (final f in files)
            XFile.fromData(_bytes(f), name: f.name, mimeType: f.mimeType),
        ],
        fileNameOverrides: [for (final f in files) f.name],
        sharePositionOrigin: origin,
      ),
    );
    return result.status == ShareResultStatus.dismissed
        ? DeliveryOutcome.cancelled
        : DeliveryOutcome.delivered;
  }

  /// One save dialog (Mac) or one download per file (web).
  Future<DeliveryOutcome> _save(List<ExportFile> files) async {
    for (final f in files) {
      final saved = await FilePicker.saveFile(
        fileName: f.name,
        bytes: _bytes(f),
        mimeType: f.mimeType,
      );
      // The web reports no location for a download; only a Mac dialog
      // that was closed comes back empty.
      if (saved == null && !kIsWeb) return DeliveryOutcome.cancelled;
    }
    return DeliveryOutcome.delivered;
  }

  @override
  Future<PickedBackup> pickBackup({required int maxBytes}) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return const PickCancelled();
    final size = await file.length();
    if (size != null && size > maxBytes) return const PickTooLarge();
    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) return const PickTooLarge();
    return PickedBytes(bytes);
  }

  static Uint8List _bytes(ExportFile f) => utf8.encode(f.content);
}
