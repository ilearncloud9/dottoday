import 'dart:convert';
import 'dart:ui' show Rect;

import 'package:dottoday/data/export/folder_writer.dart';
import 'package:dottoday/data/export/prepared_file.dart';
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

/// One picked file (CR-160 B7): its name and size, its bytes read only
/// when asked, so a set is read one file at a time.
final class PickedFile {
  const PickedFile(this.name, this.size, this.read);

  final String name;

  /// Null when the platform can't say before reading.
  final int? size;
  final Future<Uint8List> Function() read;
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

  /// Hands a PNG [png] named [name] over (11 D1 share image): the OS
  /// share sheet on iPhone, Android and the Mac; Web Share on the web where
  /// the browser offers it for files, else a download. Throws only on a
  /// platform error.
  Future<DeliveryOutcome> shareImage(
    Uint8List png, {
    required String name,
    Rect? origin,
  });

  /// Opens the file picker for a `.json` backup and reads it, refusing
  /// anything over [maxBytes] before reading it.
  Future<PickedBackup> pickBackup({required int maxBytes});

  /// Opens the file picker for one or more `.json` files (a multipart set,
  /// CR-160 B7); empty when it was closed. Nothing is read yet.
  Future<List<PickedFile>> pickJsonFiles();

  /// Hands a prepared set over (CR-160 B7): the share sheet with every
  /// file by path on iPhone and Android, a folder the person picks on the
  /// Mac. The web never calls this: it downloads each file with
  /// [downloadPrepared]. Throws only on a platform error.
  Future<DeliveryOutcome> deliverPrepared(
    List<PreparedFile> files, {
    Rect? origin,
  });

  /// Web: asks the browser to download [file] (one tap per file, so the
  /// browser doesn't block a burst of downloads).
  Future<void> downloadPrepared(PreparedFile file);
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

  @override
  Future<DeliveryOutcome> shareImage(
    Uint8List png, {
    required String name,
    Rect? origin,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(png, name: name, mimeType: _png)],
        fileNameOverrides: [name],
        sharePositionOrigin: origin,
      ),
    );
    if (result.status != ShareResultStatus.unavailable) {
      return result.status == ShareResultStatus.dismissed
          ? DeliveryOutcome.cancelled
          : DeliveryOutcome.delivered;
    }
    // A browser without Web Share for files: download it.
    final saved = await FilePicker.saveFile(
      fileName: name,
      bytes: png,
      mimeType: _png,
    );
    return saved == null && !kIsWeb
        ? DeliveryOutcome.cancelled
        : DeliveryOutcome.delivered;
  }

  static const _png = 'image/png';

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

  @override
  Future<List<PickedFile>> pickJsonFiles() async => [
    for (final f in await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    ))
      PickedFile(f.name, f.lengthSync(), f.readAsBytes),
  ];

  @override
  Future<DeliveryOutcome> deliverPrepared(
    List<PreparedFile> files, {
    Rect? origin,
  }) async {
    if (_sharesFiles) {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [
            for (final f in files)
              XFile(f.path!, name: f.name, mimeType: f.mimeType),
          ],
          fileNameOverrides: [for (final f in files) f.name],
          sharePositionOrigin: origin,
        ),
      );
      return result.status == ShareResultStatus.dismissed
          ? DeliveryOutcome.cancelled
          : DeliveryOutcome.delivered;
    }
    final folder = await FilePicker.getDirectoryPath();
    if (folder == null) return DeliveryOutcome.cancelled;
    await copyIntoFolder(folder, [for (final f in files) (f.name, f.path!)]);
    return DeliveryOutcome.delivered;
  }

  @override
  Future<void> downloadPrepared(PreparedFile file) async {
    await FilePicker.saveFile(
      fileName: file.name,
      bytes: file.bytes!,
      mimeType: file.mimeType,
    );
  }

  static Uint8List _bytes(ExportFile f) => utf8.encode(f.content);
}
