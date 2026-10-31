import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_brain_dump.g.dart';

/// Lines typed into minimal Add (docs/14 §3 B4 "The Add field accepts
/// several lines and opens the proposal"), waiting for the host in the
/// app shell to open Brain dump with them and clear it (as
/// `PendingRoutineDrop`).
@Riverpod(keepAlive: true)
class PendingBrainDump extends _$PendingBrainDump {
  @override
  String? build() => null;

  void request(String text) => state = text;

  void clear() => state = null;
}
