/// Each language in its own name (endonym), as language pickers show them:
/// the same in every UI language, so not translated.
const _endonyms = {
  'en': 'English',
  'de': 'Deutsch',
  'fr': 'Français',
  'es': 'Español',
};

/// "English" for `en`; the code itself when unknown.
String languageName(String code) => _endonyms[code] ?? code;
