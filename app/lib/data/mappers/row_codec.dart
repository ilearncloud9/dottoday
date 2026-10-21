import 'dart:convert';

import 'package:drift/drift.dart';

/// Converts between entity JSON (docs/05: snake_case keys, epoch-ms
/// instants, enum wire names) and table column values. The entities'
/// `toJson`/`fromJson` already speak the column vocabulary, so only the
/// `jsonb` columns, stored as JSON text locally, need translating.
final class RowCodec {
  const RowCodec({this.jsonColumns = const {}});

  /// Columns holding JSON text locally (e.g. `alerts`).
  final Set<String> jsonColumns;

  /// Entity JSON for a generated Drift [row]. Local-only sync columns are
  /// included and ignored by `fromJson`.
  Map<String, Object?> decode(Insertable<Object?> row) => {
    for (final MapEntry(:key, :value) in row.toColumns(false).entries)
      key: _decodeValue(key, (value as Variable<Object>).value),
  };

  /// Column values for an upsert of entity [json]. Omits sync columns, so
  /// an upsert never resets `dirty`/`version` (owned by the write path).
  RawValuesInsertable<D> encode<D>(Map<String, Object?> json) =>
      RawValuesInsertable<D>({
        for (final MapEntry(:key, :value) in json.entries)
          key: Variable<Object>(_encodeValue(key, value)),
      });

  Object? _decodeValue(String column, Object? value) =>
      jsonColumns.contains(column) && value is String
      ? jsonDecode(value)
      : value;

  Object? _encodeValue(String column, Object? value) =>
      jsonColumns.contains(column) && value != null ? jsonEncode(value) : value;
}
