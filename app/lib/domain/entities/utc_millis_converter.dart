import 'package:json_annotation/json_annotation.dart';

/// Serialises instants as UTC epoch milliseconds, the storage format for every
/// `*_utc`/`*_at` field (docs/05 intro). Decoded values are always UTC.
final class UtcMillisConverter implements JsonConverter<DateTime, int> {
  const UtcMillisConverter();

  @override
  DateTime fromJson(int json) =>
      DateTime.fromMillisecondsSinceEpoch(json, isUtc: true);

  @override
  int toJson(DateTime object) => object.toUtc().millisecondsSinceEpoch;
}
