/// Opaque identifier (UUID) that is safe to log.
///
/// The only way to put an ID-like string into a log field; any other string
/// must go through `Logger.redact`.
final class LogId {
  const LogId(this.value);

  final String value;

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  /// Whether [value] is actually a UUID (anything else may be content).
  bool get isValid => _uuid.hasMatch(value);

  @override
  String toString() => value;
}

/// A string reduced to its length, e.g. `<redacted len=12>`.
final class Redacted {
  const Redacted(this.length);

  final int length;

  @override
  String toString() => '<redacted len=$length>';
}
