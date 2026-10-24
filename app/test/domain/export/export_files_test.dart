import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../fixtures.dart';
import 'export_fixtures.dart';

// Settings › Export's files (docs/09 M8.1, R-11).
void main() {
  setUpAll(tz_data.initializeTimeZones);
  const date = '2026-10-21';

  test('JSON is the backup format, named by date, never by content', () {
    final f = exportFiles(ExportFormat.json, hostileBundle(), date: date);
    expect(f.single.name, 'dottoday-backup-2026-10-21.json');
    expect(f.single.mimeType, 'application/json');
    expect(f.single.content, encodeExportJson(hostileBundle()));
  });

  test('ICS is one calendar file', () {
    final f = exportFiles(ExportFormat.ics, hostileBundle(), date: date);
    expect(f.single.name, 'dottoday-2026-10-21.ics');
    expect(f.single.mimeType, 'text/calendar');
    expect(f.single.content, startsWith('BEGIN:VCALENDAR'));
  });

  test('CSV is one file per table, empty tables left out', () {
    final all = exportFiles(ExportFormat.csv, hostileBundle(), date: date);
    expect(all.map((f) => f.name), [
      'dottoday-tasks-2026-10-21.csv',
      'dottoday-repeats-2026-10-21.csv',
      'dottoday-subtasks-2026-10-21.csv',
    ]);
    final noRepeats = exportFiles(
      ExportFormat.csv,
      ExportBundle(
        exportedAt: t0,
        profile: profileFixture(),
        occurrences: [occurrenceFixture()],
      ),
      date: date,
    );
    expect(noRepeats.map((f) => f.name), ['dottoday-tasks-2026-10-21.csv']);
  });

  test('an empty planner still yields a tasks CSV', () {
    final f = exportFiles(
      ExportFormat.csv,
      ExportBundle(exportedAt: t0, profile: profileFixture()),
      date: date,
    );
    expect(f.single.name, 'dottoday-tasks-2026-10-21.csv');
    expect(f.single.content, isEmpty);
  });
}
