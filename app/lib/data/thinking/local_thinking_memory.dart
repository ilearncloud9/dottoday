import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:dottoday/domain/thinking/model_output.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// [ThinkingMemory] and [ThinkingJournal] in `local_meta`: on this device
/// only, never synced or exported (ADR-0009 §4, as recent searches, 06
/// §5), encrypted with the rest of the database (ADR-0006).
///
/// Everything here is one owner's (CR-160 I4): raw brain-dump text, prompts
/// and task titles, kept under `<kind>:<ownerId>`. An instance belongs to
/// [ownerId], else to the owner shown at its first use (resolved then, not
/// when made, so building the thinking service opens no database), and a
/// flow still running across a change of owner writes into that owner,
/// never into the next one's history. One [retire]d at a change of owner
/// before its first use belongs to nobody.
final class LocalThinkingMemory
    implements ThinkingMemory, ThinkingJournal, BrainDumpHistory {
  LocalThinkingMemory(this._db, {String? ownerId}) : _fixedOwner = ownerId;

  final AppDatabase _db;
  final String? _fixedOwner;
  String? _owner;
  var _bound = false;
  var _retired = false;

  /// Whose memory this is; null before any profile exists. The value is
  /// kept, not the query's future: a future started in one zone (a widget
  /// test's fake time) must not hold up a caller in another.
  Future<String?> _ownerId() async {
    if (_bound) return _owner;
    final owner = _retired ? null : _fixedOwner ?? await shownOwnerId(_db);
    if (!_bound) {
      _bound = true;
      _owner = owner;
    }
    return _owner;
  }

  /// The owner changed (the provider made a new instance): a flow that
  /// still holds this one and hasn't used it can't know whose it was, so it
  /// stores nothing under anyone.
  void retire() => _retired = true;

  /// Without an owner nothing may be stored under one, so values live in
  /// this instance only and go with it.
  final _unowned = <String, String>{};

  /// The kinds kept per owner (`<kind>:<ownerId>`, [ownedKey]); before
  /// CR-160 each was a global key of the same name.
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

  /// Forgets this owner's saved breakdowns, log and brain dumps (Settings ›
  /// Privacy); other owners' stay.
  Future<void> clear() async {
    _unowned.clear();
    final owner = await _ownerId();
    if (owner == null) return;
    await forgetOwned(_db, const [savedKey, logKey, dumpsKey], owner);
  }

  Future<Map<String, Object?>> _readMap(String key) async {
    final decoded = await _read(key);
    return decoded is Map<String, Object?> ? {...decoded} : {};
  }

  Future<List<Object?>> _readList(String key) async {
    final decoded = await _read(key);
    return decoded is List<Object?> ? [...decoded] : [];
  }

  Future<Object?> _read(String kind) async {
    final owner = await _ownerId();
    final raw = owner == null
        ? _unowned[kind]
        : await readOwned(_db, kind, owner);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  Future<void> _write(String kind, String value) async {
    final owner = await _ownerId();
    if (owner == null) {
      _unowned[kind] = value;
      return;
    }
    await writeOwned(_db, kind, owner, value);
  }
}
