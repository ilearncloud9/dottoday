import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:dottoday/domain/thinking/model_output.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// [ThinkingMemory] and [ThinkingJournal] in `local_meta`: on this device
/// only, never synced or exported (ADR-0009 §4, as recent searches, 06
/// §5), encrypted with the rest of the database (ADR-0006).
final class LocalThinkingMemory
    implements ThinkingMemory, ThinkingJournal, BrainDumpHistory {
  LocalThinkingMemory(this._db);

  final AppDatabase _db;

  static const savedKey = 'thinking_saved_breakdowns';
  static const logKey = 'thinking_log';
  static const dumpsKey = 'brain_dumps';

  /// Brain dumps kept (M12.5); the oldest goes first.
  static const maxDumps = 50;

  /// Titles remembered; the oldest is dropped beyond this.
  static const maxSaved = 100;

  /// Exchanges kept; enough to look back on, small enough to stay cheap.
  static const maxLog = 50;

  @override
  Future<List<ProposedStep>?> savedBreakdown(String title) async {
    final entry = (await _readMap(savedKey))[normaliseTitle(title)];
    if (entry is! Map<String, Object?>) return null;
    return ModelOutput.breakdown(jsonEncode(entry), BreakdownRequest.maxSteps);
  }

  @override
  Future<void> saveBreakdown(String title, List<ProposedStep> steps) async {
    final key = normaliseTitle(title);
    final kept = [
      for (final s in steps)
        if (s.title.trim().isNotEmpty) s,
    ];
    if (key.isEmpty || kept.isEmpty) return;
    final saved = await _readMap(savedKey)
      ..remove(key);
    saved[key] = {
      'steps': [
        for (final s in kept) {'title': s.title, 'minutes': s.durationMin},
      ],
    };
    // Insertion order is recency: drop from the front.
    while (saved.length > maxSaved) {
      saved.remove(saved.keys.first);
    }
    await _write(savedKey, jsonEncode(saved));
  }

  @override
  Future<void> record(ThinkingExchange exchange) async {
    final log = await _readList(logKey)
      ..add({
        'kind': exchange.kind,
        'prompt': exchange.prompt,
        'output': exchange.output,
        'at': exchange.atUtc.millisecondsSinceEpoch,
      });
    final kept = log.length > maxLog ? log.sublist(log.length - maxLog) : log;
    await _write(logKey, jsonEncode(kept));
  }

  @override
  Future<void> rememberDump(BrainDump dump) async {
    final text = dump.text.trim();
    if (text.isEmpty) return;
    final kept = await _readList(dumpsKey)
      ..add({'text': text, 'at': dump.atUtc.millisecondsSinceEpoch});
    final bounded = kept.length > maxDumps
        ? kept.sublist(kept.length - maxDumps)
        : kept;
    await _write(dumpsKey, jsonEncode(bounded));
  }

  @override
  Future<List<BrainDump>> dumps() async => [
    for (final e in (await _readList(dumpsKey)).reversed)
      if (e case {'text': final String text, 'at': final int at})
        BrainDump(
          text: text,
          atUtc: DateTime.fromMillisecondsSinceEpoch(at, isUtc: true),
        ),
  ];

  /// How many exchanges are kept (Settings › Privacy).
  Future<int> logLength() async => (await _readList(logKey)).length;

  /// Forgets saved breakdowns, the log and the brain dumps (Settings ›
  /// Privacy).
  Future<void> clear() => (_db.delete(
    _db.localMeta,
  )..where((m) => m.key.isIn([savedKey, logKey, dumpsKey]))).go();

  Future<Map<String, Object?>> _readMap(String key) async {
    final decoded = await _read(key);
    return decoded is Map<String, Object?> ? {...decoded} : {};
  }

  Future<List<Object?>> _readList(String key) async {
    final decoded = await _read(key);
    return decoded is List<Object?> ? [...decoded] : [];
  }

  Future<Object?> _read(String key) async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    try {
      return jsonDecode(row.value);
    } on FormatException {
      return null;
    }
  }

  Future<void> _write(String key, String value) => _db
      .into(_db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(key: key, value: value),
      );
}
