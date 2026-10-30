/// A pause this long in Brain dump dictation starts a new line (D6, owner
/// 2026-10-28: "~1.5 s, one tunable constant").
const kDictationPause = Duration(milliseconds: 1500);

/// How long the command word must stay the last thing heard before it
/// counts: long enough that "next week" never splits, short enough to
/// beat [kDictationPause].
const kCommandSettle = Duration(milliseconds: 700);

/// How dictated words land in a field (D6).
enum DictationMode {
  /// Brain dump: one task per line. A pause of [kDictationPause] or the
  /// language's command word starts a new line; each line starts with a
  /// capital.
  brainDump,

  /// Notes: words go in at the cursor as the recognizer writes them, like
  /// the keyboard's own mic. No commands, no pause lines.
  plain,
}

final _space = RegExp(r'\s+');
final _edgePunctuation = RegExp(
  r'^[\p{P}\p{S}]+|[\p{P}\p{S}]+$',
  unicode: true,
);

/// One dictation into a text field (docs/09 M14.4, ADR-0014), immutable:
/// each recognizer event returns the next value, and [text] / [cursor]
/// are what the field shows. The words go in at the cursor the field had
/// when listening started; the text around it is kept.
///
/// Recognizers resend the whole utterance so far with every guess, so
/// the words already turned into lines are remembered and never written
/// twice. Some start the transcript over after a pause instead (iOS): a
/// guess that no longer begins with the remembered words is a new
/// utterance, and all of it lands (found on devices, 2026-10-30):
///
/// ```dart
/// var d = Dictation.start(text: '', cursor: 0,
///     mode: DictationMode.brainDump, command: 'next', now: t0);
/// d = d.partial('call the dentist', t0);
/// d = d.tick(t0.add(kDictationPause));    // "Call the dentist\n"
/// d = d.partial('call the dentist buy milk', t1);
/// d.text; // "Call the dentist\nBuy milk"
/// d = d.tick(t2);                          // "…\nBuy milk\n"
/// d = d.partial('eggs', t3);               // started over: a new utterance
/// d.text; // "Call the dentist\nBuy milk\nEggs"
/// ```
///
/// The command word (Brain dump only; "next", "weiter", "suivant",
/// "siguiente") ends a line when it is the **last word heard** and nothing
/// follows it for [kCommandSettle], or when the utterance ends on it.
/// It is removed. It matches as a whole word, any case, with punctuation
/// around it ignored:
/// - "call the dentist next" + 0.7 s quiet → "Call the dentist", new line.
/// - "see you next week" → no split: "week" follows within the settle time.
/// - "next" alone after a line break → nothing (no empty line).
/// - "Next." as a final result → a new line, the word dropped.
final class Dictation {
  const Dictation._({
    required this.mode,
    required this.command,
    required String before,
    required String after,
    required String lead,
    required String committed,
    required List<String> live,
    required List<String> said,
    required DateTime heardAt,
  }) : _before = before,
       _after = after,
       _lead = lead,
       _committed = committed,
       _live = live,
       _said = said,
       _heardAt = heardAt;

  /// Listening starts in [text] at [cursor] (clamped to the text). In
  /// Brain dump, words after a typed line start a line of their own; in
  /// plain mode a space separates them from the word before.
  factory Dictation.start({
    required String text,
    required int cursor,
    required DictationMode mode,
    required DateTime now,
    String? command,
  }) {
    final at = cursor.clamp(0, text.length);
    final before = text.substring(0, at);
    final lead = switch (mode) {
      DictationMode.brainDump
          when before.isNotEmpty && !before.endsWith('\n') =>
        '\n',
      DictationMode.plain when before.isNotEmpty && !_endsBlank(before) => ' ',
      _ => '',
    };
    return Dictation._(
      mode: mode,
      command: command == null ? null : _word(command),
      before: before,
      after: text.substring(at),
      lead: lead,
      committed: '',
      live: const [],
      said: const [],
      heardAt: now,
    );
  }

  final DictationMode mode;

  /// The normalised command word, or null (plain mode never uses one).
  final String? command;
  final String _before;
  final String _after;

  /// '\n' or ' ' before the first dictated word, if one is needed.
  final String _lead;

  /// Words already settled in this dictation, lines joined by '\n'.
  final String _committed;

  /// The utterance's words not yet settled.
  final List<String> _live;

  /// The current utterance's words already in [_committed], normalised
  /// ([_word]): what a guess must begin with to be the same utterance.
  final List<String> _said;

  /// When the live words last changed.
  final DateTime _heardAt;

  /// What the field shows now.
  String get text => '$_before$_inserted$_after';

  /// Where the caret goes: after the dictated words.
  int get cursor => _before.length + _inserted.length;

  /// Whether anything was dictated yet.
  bool get isEmpty => _committed.isEmpty && _live.isEmpty;

  String get _inserted {
    final live = _line(_live, atLineStart: _atLineStart);
    final body = live.isEmpty
        ? _committed
        : '$_committed${_joiner(_committed)}$live';
    return body.isEmpty ? '' : '$_lead$body';
  }

  bool get _atLineStart =>
      mode == DictationMode.brainDump &&
      (_committed.isEmpty || _committed.endsWith('\n'));

  /// The recognizer's current guess for the utterance in progress.
  Dictation partial(String hypothesis, DateTime now) {
    final words = _split(hypothesis);
    // Started over after a pause with words still unsettled (Notes never
    // split lines): keep them rather than let the new guess replace them.
    if (_live.isNotEmpty &&
        now.difference(_heardAt) >= kDictationPause &&
        !_continues(words, _heard)) {
      final kept = switch (mode) {
        DictationMode.plain => _settle(newLine: false),
        DictationMode.brainDump => _endLine(),
      };
      return kept._copy(said: const []).partial(hypothesis, now);
    }
    final said = _continues(words, _said) ? _said : const <String>[];
    final live = _wordsAfter(words, said);
    if (identical(said, _said) && _same(live, _live)) return this;
    return _copy(said: said, live: live, heardAt: now);
  }

  /// The utterance is final: its unsettled words are settled. In Brain
  /// dump the end of an utterance is a pause, so a new line starts.
  Dictation finalResult(String text, DateTime now) {
    final words = _split(text);
    final said = _continues(words, _said) ? _said : const <String>[];
    final next = _copy(
      said: said,
      live: _wordsAfter(words, said),
      heardAt: now,
    );
    return switch (mode) {
      DictationMode.plain => next._settle(newLine: false)._copy(said: const []),
      DictationMode.brainDump => next._endLine()._copy(said: const []),
    };
  }

  /// Time passed with nothing new heard: in Brain dump, the command word
  /// settles after [kCommandSettle] and a pause after [kDictationPause].
  Dictation tick(DateTime now) {
    if (mode == DictationMode.plain || _live.isEmpty) return this;
    final quiet = now.difference(_heardAt);
    final saidCommand = command != null && _word(_live.last) == command;
    if (saidCommand && quiet >= kCommandSettle) return _endLine();
    if (quiet >= kDictationPause) return _endLine();
    return this;
  }

  /// Ends the current line in Brain dump: drops a trailing command word,
  /// settles the rest, and starts a new line unless the line is empty.
  Dictation _endLine() {
    final words = [..._live];
    if (command != null && words.isNotEmpty && _word(words.last) == command) {
      words.removeLast();
    }
    final said = _heard;
    if (words.isEmpty) return _copy(live: const [], said: said);
    return _copy(live: words)._settle(newLine: true)._copy(said: said);
  }

  /// Moves the live words into [_committed].
  Dictation _settle({required bool newLine}) {
    final line = _line(_live, atLineStart: _atLineStart);
    if (line.isEmpty) return this;
    return _copy(
      committed: '$_committed${_joiner(_committed)}$line${newLine ? '\n' : ''}',
      live: const [],
      said: _heard,
    );
  }

  /// [_said] and the live words: the whole utterance heard so far.
  List<String> get _heard => [..._said, ..._live.map(_word)];

  Dictation _copy({
    String? committed,
    List<String>? live,
    List<String>? said,
    DateTime? heardAt,
  }) => Dictation._(
    mode: mode,
    command: command,
    before: _before,
    after: _after,
    lead: _lead,
    committed: committed ?? _committed,
    live: live ?? _live,
    said: said ?? _said,
    heardAt: heardAt ?? _heardAt,
  );

  /// The words of [words] after the [said] ones.
  static List<String> _wordsAfter(List<String> words, List<String> said) =>
      words.length > said.length ? words.sublist(said.length) : const [];

  /// Whether [words] goes on from the [said] ones (the same utterance):
  /// it begins with them, normalised, allowing one revised word once
  /// three are said ("dentist" heard again as "dentists"). Anything else
  /// — shorter, or other words — is the recognizer starting over.
  static bool _continues(List<String> words, List<String> said) {
    if (said.isEmpty) return true;
    if (words.length < said.length) return false;
    var changed = 0;
    for (var i = 0; i < said.length; i++) {
      if (_word(words[i]) != said[i]) changed++;
    }
    return changed <= (said.length >= 3 ? 1 : 0);
  }

  /// A space between settled words and the next ones on the same line.
  static String _joiner(String committed) =>
      committed.isEmpty || _endsBlank(committed) ? '' : ' ';

  /// [words] as a line; a Brain dump line starts with a capital.
  static String _line(List<String> words, {required bool atLineStart}) {
    final line = words.join(' ');
    if (!atLineStart || line.isEmpty) return line;
    // UTF-16 safe: a lone surrogate upper-cases to itself.
    return line[0].toUpperCase() + line.substring(1);
  }

  static List<String> _split(String text) =>
      text.trim().isEmpty ? const [] : text.trim().split(_space);

  /// A word as compared with the command: lower case, no punctuation
  /// around it ("Next." → "next").
  static String _word(String w) =>
      w.replaceAll(_edgePunctuation, '').toLowerCase();

  static bool _endsBlank(String s) => s.endsWith(' ') || s.endsWith('\n');

  static bool _same(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
