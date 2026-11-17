import 'dart:convert';

import 'package:dottoday/data/intents/action_queue_json.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_action.dart';

/// The shared action queue as the native side keeps it (CR-160 I7): JSON
/// text plus the marker the app published. [append] refuses and stamps like
/// `DotQueue.append` (Swift), `DotQueue.stamp` (Kotlin) and
/// `web/action_queue.js`: the published owner, or nobody while a change of
/// owner is under way or before anything was published. The store outlives
/// an app run, as App Group defaults and Cache Storage do.
final class SharedActionQueue implements ActionQueueStore {
  String raw = '[]';

  /// The published owner's wire form, as the native side stores it.
  String? marker;

  /// Every marker published, in order.
  final published = <QueueMarker>[];

  /// Runs once at the next [read]: "another process" appending meanwhile.
  void Function()? onRead;

  /// Runs at every [publish], after it is stored.
  void Function(QueueMarker marker)? onPublish;

  /// What a surface queues now, stamped from [marker]; false (nothing
  /// queued) when the marker refuses or the queue is full. [at] defaults to
  /// a fixed time; the id is the queue key.
  bool append(String id, DotAction action, {DateTime? at}) {
    if (_refusing || entries.length >= queueCapacity) return false;
    final entry = encodeQueuedAction(
      QueuedAction(
        id: id,
        createdAtUtc: at ?? DateTime.utc(2026, 10, 23, 9),
        action: action,
      ),
    );
    final owner = _stamp();
    raw = jsonEncode([
      ...decodeQueueArray(raw),
      {...entry, ...owner},
    ]);
    return true;
  }

  bool get _refusing {
    final m = marker == null ? null : jsonDecode(marker!);
    return m is Map && m['refuse'] == true;
  }

  /// An entry as an older version wrote it, with no owner.
  void appendRaw(Object? entry) =>
      raw = jsonEncode([...decodeQueueArray(raw), entry]);

  List<Object?> get entries => decodeQueueArray(raw);

  Set<String> get ids => {
    for (final e in entries)
      if (e is Map && e['id'] is String) e['id'] as String,
  };

  Map<String, Object?> _stamp() {
    final m = marker == null ? null : jsonDecode(marker!);
    if (m is! Map || m['switching'] == true || m['owner'] is! String) {
      return const {};
    }
    return {
      'owner': m['owner'],
      if (m['guest_session'] is String) 'guest_session': m['guest_session'],
    };
  }

  @override
  Future<List<Object?>> read() async {
    final list = decodeQueueArray(raw);
    final hook = onRead;
    onRead = null;
    hook?.call();
    return list;
  }

  @override
  Future<void> remove(Set<String> ids) async => raw = withoutEntries(raw, ids);

  @override
  Future<void> publish(QueueMarker marker) async {
    this.marker = encodeQueueMarker(marker);
    published.add(marker);
    onPublish?.call(marker);
  }
}
