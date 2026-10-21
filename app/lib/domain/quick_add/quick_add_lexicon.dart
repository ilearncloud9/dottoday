/// Languages Quick Add understands (docs/02 F2: en, de, fr, es).
enum QuickAddLanguage { en, de, fr, es }

/// Words Quick Add recognises in one language. All lowercase; matching is
/// case-insensitive. `HH:MM` and `@inbox` work in every language.
final class QuickAddLexicon {
  const QuickAddLexicon({
    required this.today,
    required this.tomorrow,
    required this.dayAfterTomorrow,
    required this.weekdays,
    required this.nextBefore,
    required this.nextAfter,
    required this.dateConnectors,
    required this.timeConnectors,
    required this.noon,
    required this.midnight,
    required this.amPm,
    required this.hourSuffix,
    required this.hourLetterIsTime,
    required this.minuteUnits,
    required this.hourUnits,
    required this.durationConnectors,
    required this.every,
    required this.other,
    required this.listJoiners,
    required this.dayUnits,
    required this.weekUnits,
    required this.monthUnits,
    required this.yearUnits,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
    required this.workdays,
  });

  final List<String> today;
  final List<String> tomorrow;
  final List<String> dayAfterTomorrow;

  /// Aliases per weekday, Monday first.
  final List<List<String>> weekdays;

  /// "next" before a weekday ("next mon") / after it ("lundi prochain").
  final List<String> nextBefore;
  final List<String> nextAfter;

  /// Words swallowed before a date ("on Friday") or a time ("at 7").
  final List<String> dateConnectors;
  final List<String> timeConnectors;

  final List<String> noon;
  final List<String> midnight;

  /// Whether `7pm`-style 12-hour times are common enough to parse.
  final bool amPm;

  /// Word after a 24-hour time (`15 Uhr`).
  final List<String> hourSuffix;

  /// Whether `15h`/`15h30` is a clock time (French) rather than a duration.
  final bool hourLetterIsTime;

  final List<String> minuteUnits;
  final List<String> hourUnits;
  final List<String> durationConnectors;

  /// "every"/"each" and the "every other" word.
  final List<String> every;
  final List<String> other;

  /// Separators inside a weekday list ("mon, wed and fri").
  final List<String> listJoiners;

  final List<String> dayUnits;
  final List<String> weekUnits;
  final List<String> monthUnits;
  final List<String> yearUnits;

  final List<String> daily;
  final List<String> weekly;
  final List<String> monthly;
  final List<String> yearly;

  /// Monday to Friday ("every weekday", "werktags").
  final List<String> workdays;

  static QuickAddLexicon of(QuickAddLanguage language) => switch (language) {
        QuickAddLanguage.en => _en,
        QuickAddLanguage.de => _de,
        QuickAddLanguage.fr => _fr,
        QuickAddLanguage.es => _es,
      };
}

const _en = QuickAddLexicon(
  today: ['today', 'tonight'],
  tomorrow: ['tomorrow', 'tmrw', 'tmr'],
  dayAfterTomorrow: ['day after tomorrow'],
  weekdays: [
    ['monday', 'mon'],
    ['tuesday', 'tues', 'tue'],
    ['wednesday', 'wed'],
    ['thursday', 'thurs', 'thu'],
    ['friday', 'fri'],
    ['saturday', 'sat'],
    ['sunday', 'sun'],
  ],
  nextBefore: ['next'],
  nextAfter: [],
  dateConnectors: ['on'],
  timeConnectors: ['at'],
  noon: ['noon', 'midday'],
  midnight: ['midnight'],
  amPm: true,
  hourSuffix: [],
  hourLetterIsTime: false,
  minuteUnits: ['minutes', 'minute', 'mins', 'min', 'm'],
  hourUnits: ['hours', 'hour', 'hrs', 'hr', 'h'],
  durationConnectors: ['for'],
  every: ['every', 'each'],
  other: ['other'],
  listJoiners: [',', 'and', '&'],
  dayUnits: ['days', 'day'],
  weekUnits: ['weeks', 'week'],
  monthUnits: ['months', 'month'],
  yearUnits: ['years', 'year'],
  daily: ['daily'],
  weekly: ['weekly'],
  monthly: ['monthly'],
  yearly: ['yearly', 'annually'],
  workdays: ['weekdays', 'weekday', 'workdays', 'workday'],
);

const _de = QuickAddLexicon(
  today: ['heute'],
  tomorrow: ['morgen'],
  dayAfterTomorrow: ['übermorgen'],
  weekdays: [
    // No two-letter forms: "so", "do", "mi" are everyday words.
    ['montag'],
    ['dienstag'],
    ['mittwoch'],
    ['donnerstag'],
    ['freitag'],
    ['samstag', 'sonnabend'],
    ['sonntag'],
  ],
  nextBefore: ['nächsten', 'nächste', 'kommenden', 'kommende'],
  nextAfter: [],
  dateConnectors: ['am'],
  timeConnectors: ['um', 'gegen'],
  noon: ['mittag', 'mittags'],
  midnight: ['mitternacht'],
  amPm: false,
  hourSuffix: ['uhr'],
  hourLetterIsTime: false,
  minuteUnits: ['minuten', 'minute', 'min'],
  hourUnits: ['stunden', 'stunde', 'std', 'h'],
  durationConnectors: ['für'],
  every: ['jeden', 'jede', 'jedes', 'alle'],
  other: ['zweiten'],
  listJoiners: [',', 'und', '&'],
  dayUnits: ['tage', 'tag'],
  weekUnits: ['wochen', 'woche'],
  monthUnits: ['monate', 'monat'],
  yearUnits: ['jahre', 'jahr'],
  daily: ['täglich'],
  weekly: ['wöchentlich'],
  monthly: ['monatlich'],
  yearly: ['jährlich'],
  workdays: ['werktags', 'wochentags'],
);

const _fr = QuickAddLexicon(
  today: ["aujourd'hui", 'auj', 'ce soir'],
  tomorrow: ['demain'],
  dayAfterTomorrow: ['après-demain', 'après demain'],
  weekdays: [
    ['lundi', 'lun'],
    ['mardi', 'mar'],
    ['mercredi', 'mer'],
    ['jeudi', 'jeu'],
    ['vendredi', 'ven'],
    ['samedi', 'sam'],
    ['dimanche', 'dim'],
  ],
  nextBefore: [],
  nextAfter: ['prochain'],
  dateConnectors: ['le'],
  timeConnectors: ['à', 'a', 'vers'],
  noon: ['midi'],
  midnight: ['minuit'],
  amPm: false,
  hourSuffix: [],
  hourLetterIsTime: true,
  minuteUnits: ['minutes', 'minute', 'min'],
  hourUnits: ['heures', 'heure'],
  durationConnectors: ['pendant'],
  every: ['chaque', 'tous les', 'toutes les'],
  other: [],
  listJoiners: [',', 'et', '&'],
  dayUnits: ['jours', 'jour'],
  weekUnits: ['semaines', 'semaine'],
  monthUnits: ['mois'],
  yearUnits: ['ans', 'an', 'années', 'année'],
  daily: ['quotidiennement'],
  weekly: ['hebdomadaire'],
  monthly: ['mensuel', 'mensuellement'],
  yearly: ['annuel', 'annuellement'],
  workdays: ['jours ouvrés', 'en semaine'],
);

const _es = QuickAddLexicon(
  today: ['hoy', 'esta noche'],
  tomorrow: ['mañana'],
  dayAfterTomorrow: ['pasado mañana'],
  weekdays: [
    ['lunes', 'lun'],
    ['martes'], // not "mar": it means "sea"
    ['miércoles', 'miercoles', 'mié', 'mie'],
    ['jueves', 'jue'],
    ['viernes', 'vie'],
    ['sábado', 'sabado', 'sáb', 'sab'],
    ['domingo', 'dom'],
  ],
  nextBefore: ['el próximo', 'el proximo', 'próximo', 'proximo'],
  nextAfter: ['que viene'],
  dateConnectors: ['el'],
  timeConnectors: ['a las', 'a la'],
  noon: ['mediodía', 'mediodia'],
  midnight: ['medianoche'],
  amPm: true,
  hourSuffix: [],
  hourLetterIsTime: false,
  minuteUnits: ['minutos', 'minuto', 'min'],
  hourUnits: ['horas', 'hora', 'h'],
  durationConnectors: ['durante'],
  every: ['cada', 'todos los', 'todas las'],
  other: [],
  listJoiners: [',', 'y', '&'],
  dayUnits: ['días', 'dias', 'día', 'dia'],
  weekUnits: ['semanas', 'semana'],
  monthUnits: ['meses', 'mes'],
  yearUnits: ['años', 'anos', 'año', 'ano'],
  daily: ['diariamente', 'a diario'],
  weekly: ['semanalmente'],
  monthly: ['mensualmente'],
  yearly: ['anualmente'],
  workdays: ['días laborables', 'entre semana'],
);
