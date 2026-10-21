import 'package:dottoday/core/clock/clock.dart';

/// A hybrid logical clock timestamp (ADR-0002 "HLC format").
///
/// Serialises to the fixed-width `<13-digit ms>-<4-digit counter>-<16 hex
/// node>`, so string order equals `(ms, counter, node)` order; the server
/// compares the strings directly. The node id breaks ties deterministically.
final class Hlc implements Comparable<Hlc> {
  Hlc(this.ms, this.counter, this.node) {
    if (ms < 0 || ms > maxMs) throw RangeError.range(ms, 0, maxMs, 'ms');
    if (counter < 0 || counter > maxCounter) {
      throw RangeError.range(counter, 0, maxCounter, 'counter');
    }
    if (!_node.hasMatch(node)) {
      throw ArgumentError.value(node, 'node', 'must be 16 lowercase hex');
    }
  }

  static const maxMs = 9999999999999;
  static const maxCounter = 9999;

  static final _node = RegExp(r'^[0-9a-f]{16}$');
  static final _format = RegExp(r'^([0-9]{13})-([0-9]{4})-([0-9a-f]{16})$');

  final int ms;
  final int counter;
  final String node;

  /// Parses the wire form; null if malformed (as `hlc_is_valid` would say).
  static Hlc? tryParse(String value) {
    final m = _format.firstMatch(value);
    if (m == null) return null;
    return Hlc(int.parse(m[1]!), int.parse(m[2]!), m[3]!);
  }

  /// Whether [node] is a valid device id for an HLC.
  static bool isValidNode(String node) => _node.hasMatch(node);

  @override
  int compareTo(Hlc other) {
    if (ms != other.ms) return ms.compareTo(other.ms);
    if (counter != other.counter) return counter.compareTo(other.counter);
    return node.compareTo(other.node);
  }

  bool operator >(Hlc other) => compareTo(other) > 0;
  bool operator <(Hlc other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.ms == ms &&
      other.counter == counter &&
      other.node == node;

  @override
  int get hashCode => Object.hash(ms, counter, node);

  @override
  String toString() => '${ms.toString().padLeft(13, '0')}-'
      '${counter.toString().padLeft(4, '0')}-$node';
}

/// Issues monotonic [Hlc]s for one device (ADR-0002).
///
/// Call [now] for every local write and [receive] for every remote HLC seen
/// during pull, so local writes always sort after what this device knows.
/// Persist [last] and pass it back on start so order survives restarts.
final class HybridLogicalClock {
  HybridLogicalClock({
    required Clock clock,
    required String nodeId,
    Hlc? last,
  })  : _clock = clock,
        _node = nodeId,
        _last = last ?? Hlc(0, 0, nodeId) {
    if (!Hlc.isValidNode(nodeId)) {
      throw ArgumentError.value(nodeId, 'nodeId', 'must be 16 lowercase hex');
    }
  }

  /// Remote clocks further ahead than this do not drag ours forward; the
  /// server rejects them too (ADR-0002, 06 §1 "Sync tampering").
  static const maxDrift = Duration(minutes: 5);

  final Clock _clock;
  final String _node;
  Hlc _last;

  /// The latest HLC issued or observed; persist it.
  Hlc get last => _last;

  /// A new HLC for a local event, strictly after [last].
  Hlc now() {
    final wall = _wallMs();
    _last = wall > _last.ms
        ? Hlc(wall, 0, _node)
        : _bump(_last.ms, _last.counter + 1);
    return _last;
  }

  /// Merges a [remote] HLC seen in pulled data and returns the new [last].
  Hlc receive(Hlc remote) {
    final wall = _wallMs();
    final trusted = remote.ms - wall <= maxDrift.inMilliseconds;
    final remoteMs = trusted ? remote.ms : 0;
    final ms = [wall, _last.ms, remoteMs].reduce((a, b) => a > b ? a : b);
    final int counter;
    if (ms == _last.ms && ms == remoteMs) {
      final top =
          _last.counter > remote.counter ? _last.counter : remote.counter;
      counter = top + 1;
    } else if (ms == _last.ms) {
      counter = _last.counter + 1;
    } else if (ms == remoteMs) {
      counter = remote.counter + 1;
    } else {
      counter = 0;
    }
    _last = _bump(ms, counter);
    return _last;
  }

  int _wallMs() => _clock.nowUtc().millisecondsSinceEpoch;

  /// The 4-digit counter overflows after 10 000 events in one millisecond;
  /// borrow the next millisecond instead of breaking the fixed width.
  Hlc _bump(int ms, int counter) => counter > Hlc.maxCounter
      ? Hlc(ms + 1, 0, _node)
      : Hlc(ms, counter, _node);
}
