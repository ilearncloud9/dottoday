// Pure Dart (no Flutter): also compiled into the web drift worker (M2.9).

final _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// Whether [key] is exactly 32 bytes of lowercase hex. Only such keys are
/// ever interpolated into `PRAGMA key`, which cannot take bound parameters.
bool isValidHexKey(String key) => _hexKey.hasMatch(key);
