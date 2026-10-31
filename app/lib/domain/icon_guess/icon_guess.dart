import 'package:dottoday/domain/icon_guess/icon_guess_index.gen.dart';
import 'package:dottoday/domain/icon_guess/icon_guess_text.dart';

/// The icon a title names, and the colour of that icon's category when it
/// has one.
typedef IconGuess = ({String iconKey, String? colorKey});

/// Plural and inflection endings tried when a word has no entry of its own.
const _endings = {
  'en': ['s', 'es'],
  'de': ['n', 'en', 'e', 's', 'er'],
  'es': ['s', 'es'],
  'fr': ['s', 'x'],
};

/// Picks the icon (and colour) a task [title] suggests, on device: the
/// title never leaves it (CLAUDE.md §11). [language] is the UI language
/// ("de", "de_AT"); English terms are tried after it. Null when nothing matches, so
/// the caller keeps its default.
///
/// The longest phrase wins, then the earliest; generic verbs ("buy",
/// "clean", "appointment") only when nothing else matches. German
/// compounds match a known part ("Zahnarzttermin" → dentist).
///
/// ```dart
/// guessIcon('Buy groceries 5pm', language: 'en'); // (iconKey: cart, …)
/// guessIcon('Jugar al tenis', language: 'es');    // (iconKey: tennis, …)
/// ```
IconGuess? guessIcon(String title, {required String language}) {
  final words = guessWords(title);
  if (words.isEmpty) return null;
  final code = language.split(RegExp('[_-]')).first.toLowerCase();
  final lang = iconGuessStrong.containsKey(code) ? code : 'en';
  final key =
      _phrase(words, iconGuessStrong[lang]!, lang) ??
      (lang == 'de' ? _compound(words, iconGuessStrong[lang]!) : null) ??
      (lang == 'en' ? null : _phrase(words, iconGuessStrong['en']!, 'en')) ??
      _phrase(words, iconGuessWeak[lang]!, lang) ??
      (lang == 'en' ? null : _phrase(words, iconGuessWeak['en']!, 'en'));
  if (key == null) return null;
  return (iconKey: key, colorKey: iconGuessColors[key]);
}

String? _phrase(List<String> words, Map<String, String> terms, String lang) {
  final longest = words.length < iconGuessMaxWords
      ? words.length
      : iconGuessMaxWords;
  for (var n = longest; n >= 1; n--) {
    for (var i = 0; i + n <= words.length; i++) {
      final head = words.sublist(i, i + n - 1);
      for (final last in _forms(words[i + n - 1], lang)) {
        if (terms[[...head, last].join(' ')] case final key?) return key;
      }
    }
  }
  return null;
}

/// [word] itself, then with each plural ending taken off.
Iterable<String> _forms(String word, String lang) sync* {
  yield word;
  for (final e in _endings[lang]!) {
    if (word.length - e.length >= 3 && word.endsWith(e)) {
      yield word.substring(0, word.length - e.length);
    }
  }
}

/// A long word's longest known start, else its longest known end: in a
/// compound the first part is the telling one ("Zahnarzttermin" is a
/// dentist's appointment).
String? _compound(List<String> words, Map<String, String> terms) {
  final long = words.where((w) => w.length >= 6).toList();
  return _affix(long, terms, (w, t) => w.startsWith(t)) ??
      _affix(long, terms, (w, t) => w.endsWith(t));
}

String? _affix(
  List<String> words,
  Map<String, String> terms,
  bool Function(String word, String term) has,
) {
  String? best;
  var bestLength = 0;
  for (final w in words) {
    for (final MapEntry(key: t, value: key) in terms.entries) {
      if (t.length < 4 || t.length <= bestLength || t.length >= w.length) {
        continue;
      }
      if (!t.contains(' ') && has(w, t)) {
        best = key;
        bestLength = t.length;
      }
    }
  }
  return best;
}
