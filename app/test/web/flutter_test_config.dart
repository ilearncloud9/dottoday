import 'dart:async';

/// Browser tests (`--platform chrome`): no golden comparator here — the
/// root config's file comparator needs dart:io, and goldens are baselined
/// on macOS anyway (docs/09 M0.8). The nearest config wins.
Future<void> testExecutable(FutureOr<void> Function() testMain) async =>
    testMain();
