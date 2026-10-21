import 'dart:convert';

import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/subtask.dart';

// CSV per entity (docs/05 "Export format", R-11). CSV is a human/spreadsheet
// report, never an import source: instants are ISO-8601 UTC for
// readability, nested values (alerts, templates) are JSON.

/// Columns whose epoch-ms values are rendered as ISO-8601 UTC.
bool _isInstant(String column) =>
    column.endsWith('_utc') || column.endsWith('_at');

/// RFC 4180 CSV (CRLF, quoted where needed) with spreadsheet formula
/// injection neutralised: a cell starting with `=`, `+`, `-`, `@`, tab or
/// CR gets a leading `'` (OWASP CSV injection).
String toCsv(List<String> header, Iterable<List<Object?>> rows) {
  final buffer = StringBuffer()..write(_row(header));
  for (final row in rows) {
    buffer.write(_row(row));
  }
  return buffer.toString();
}

String _row(List<Object?> cells) => '${cells.map(_cell).join(',')}\r\n';

final _formulaStart = RegExp('^[=+\\-@\t\r]');
final _needsQuotes = RegExp('[",\r\n]');

String _cell(Object? value) {
  var text = switch (value) {
    null => '',
    String() => value,
    num() || bool() => '$value',
    _ => jsonEncode(value),
  };
  // Numbers are written by us, never user formulas; leave "-5" intact.
  if (value is String && _formulaStart.hasMatch(text)) text = "'$text";
  if (_needsQuotes.hasMatch(text) ||
      text.startsWith(' ') ||
      text.endsWith(' ')) {
    return '"${text.replaceAll('"', '""')}"';
  }
  return text;
}

/// One CSV per table from [rows] (each a row's `toJson()`), header from the
/// first row's keys. Live rows only: trash stays out of reports.
String _tableCsv(List<Map<String, Object?>> rows) {
  if (rows.isEmpty) return '';
  final header = rows.first.keys.toList();
  return toCsv(header, [
    for (final row in rows)
      [
        for (final column in header)
          if (_isInstant(column) && row[column] is int)
            DateTime.fromMillisecondsSinceEpoch(
              row[column]! as int,
              isUtc: true,
            ).toIso8601String()
          else
            row[column],
      ],
  ]);
}

String seriesCsv(Iterable<Series> series) => _tableCsv([
      for (final s in series)
        if (s.deletedAt == null) s.toJson(),
    ]);

String occurrencesCsv(Iterable<Occurrence> occurrences) => _tableCsv([
      for (final o in occurrences)
        if (o.deletedAt == null) o.toJson(),
    ]);

String subtasksCsv(Iterable<Subtask> subtasks) => _tableCsv([
      for (final s in subtasks)
        if (s.deletedAt == null) s.toJson(),
    ]);
