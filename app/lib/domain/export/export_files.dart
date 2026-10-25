import 'package:dottoday/domain/export/csv_export.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/ics_export.dart';

/// The three file exports on Settings › Export (docs/02 F7, R-11).
enum ExportFormat {
  /// The full backup (JSON v1), the only one import reads back.
  json,

  /// One CSV per table, a report for spreadsheets.
  csv,

  /// The scheduled timeline for other calendar apps.
  ics,
}

/// One file ready to hand to the share sheet or a save dialog.
final class ExportFile {
  const ExportFile({
    required this.name,
    required this.mimeType,
    required this.content,
  });

  /// `dottoday-backup-2026-10-24.json`: never a title or other content.
  final String name;
  final String mimeType;
  final String content;
}

/// The files for [format] from [bundle], named with [date] (the user's
/// local `yyyy-MM-dd`, so two exports on one day sort together).
///
/// CSV leaves out empty tables (a person without repeats gets no
/// `repeats` file); if every table is empty, the tasks file still comes
/// out with no rows, so an export always yields something to save.
///
/// ```dart
/// exportFiles(ExportFormat.ics, bundle, date: '2026-10-24').single.name;
/// // 'dottoday-2026-10-24.ics'
/// ```
List<ExportFile> exportFiles(
  ExportFormat format,
  ExportBundle bundle, {
  required String date,
}) => switch (format) {
  ExportFormat.json => [
    ExportFile(
      name: 'dottoday-backup-$date.json',
      mimeType: 'application/json',
      content: encodeExportJson(bundle),
    ),
  ],
  ExportFormat.ics => [
    ExportFile(
      name: 'dottoday-$date.ics',
      mimeType: 'text/calendar',
      content: toIcs(
        stampUtc: bundle.exportedAt,
        series: bundle.series,
        occurrences: bundle.occurrences,
      ),
    ),
  ],
  ExportFormat.csv => _csvFiles(bundle, date),
};

List<ExportFile> _csvFiles(ExportBundle bundle, String date) {
  ExportFile csv(String table, String content) => ExportFile(
    name: 'dottoday-$table-$date.csv',
    mimeType: 'text/csv',
    content: content,
  );
  final files = [
    csv('tasks', occurrencesCsv(bundle.occurrences)),
    csv('repeats', seriesCsv(bundle.series)),
    csv('subtasks', subtasksCsv(bundle.subtasks)),
    csv('routines', routinesCsv(bundle.routines)),
  ].where((f) => f.content.isNotEmpty).toList();
  return files.isEmpty ? [csv('tasks', '')] : files;
}
