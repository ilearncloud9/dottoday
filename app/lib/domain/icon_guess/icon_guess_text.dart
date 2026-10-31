// Text folding shared by the icon guesser and its generator
// (tool/gen_icon_guess.dart), so a term is stored exactly as a title is
// read: "Café", "cafe" and "CAFE" are one word.

const _folds = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', //
  'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ì': 'i', 'í': 'i',
  'î': 'i', 'ï': 'i', 'ñ': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o',
  'ö': 'o', 'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y', 'ÿ': 'y',
  'ß': 'ss', 'œ': 'oe', 'æ': 'ae',
};

final _nonWord = RegExp('[^a-z0-9]+');

/// The words of [text]: lowercased, accents folded, split on anything
/// that isn't a letter or digit.
///
/// ```dart
/// guessWords("Café with Zoë!"); // ['cafe', 'with', 'zoe']
/// ```
List<String> guessWords(String text) {
  final folded = StringBuffer();
  for (final ch in text.toLowerCase().split('')) {
    folded.write(_folds[ch] ?? ch);
  }
  return folded.toString().split(_nonWord).where((w) => w.isNotEmpty).toList();
}

/// [text] folded to the key form the guess index stores.
String guessKey(String text) => guessWords(text).join(' ');
