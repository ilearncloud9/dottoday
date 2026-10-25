/// Pseudo-translation for truncation tests (docs/09 M8.3, docs/08 §2).
///
/// Accents every letter that has a common accented form and doubles each
/// vowel, so text is about a third longer with no new spaces — like a
/// German compound — and is wrapped in ⟦ ⟧ so a clipped end is visible in a
/// screenshot. Digits, punctuation and whitespace-only separators are kept.
///
/// ```dart
/// pseudo('Add task'); // '⟦ÅÅďď ťååšk⟧'
/// ```
String pseudo(String text) {
  if (!RegExp('[A-Za-z]').hasMatch(text)) return text;
  final out = StringBuffer('⟦');
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    final accented = _accents[char] ?? char;
    out.write(accented);
    if (_vowels.contains(char)) out.write(accented);
  }
  out.write('⟧');
  return out.toString();
}

const _vowels = 'aeiouAEIOU';

const _accents = {
  'a': 'å',
  'e': 'é',
  'i': 'í',
  'o': 'ö',
  'u': 'ü',
  'c': 'ç',
  'n': 'ñ',
  'y': 'ý',
  's': 'š',
  'z': 'ž',
  't': 'ť',
  'l': 'ł',
  'd': 'ď',
  'g': 'ğ',
  'A': 'Å',
  'E': 'É',
  'I': 'Í',
  'O': 'Ö',
  'U': 'Ü',
  'C': 'Ç',
  'N': 'Ñ',
  'Y': 'Ý',
  'S': 'Š',
  'Z': 'Ž',
  'T': 'Ť',
  'L': 'Ł',
  'D': 'Ď',
  'G': 'Ğ',
};
