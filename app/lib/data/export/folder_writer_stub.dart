import 'package:dottoday/domain/export/export_files.dart';

/// Not available on this platform (the web downloads each file instead).
Future<void> writeToFolder(String folder, List<ExportFile> files) =>
    throw UnsupportedError('No folders on this platform');
