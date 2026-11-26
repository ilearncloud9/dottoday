import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/icon_guess/icon_guess.dart';
import 'package:dottoday/domain/onboarding/day_fills.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

/// A preset's title in the user's language.
String presetTitle(AppLocalizations l10n, FillPreset p) => switch (p) {
  FillPreset.morningRun => l10n.starterMorningRun,
  FillPreset.deepWork => l10n.starterDeepWork,
  FillPreset.gym => l10n.starterGym,
  FillPreset.read => l10n.starterRead,
};

/// The colours a typed thing with no icon of its own takes, the first one
/// not on a chip yet (`pal`: green, blue, amber, violet, brown).
final _plainColours = [
  for (final c in [
    TaskColor.mint,
    TaskColor.sky,
    TaskColor.amber,
    TaskColor.violet,
    TaskColor.brown,
  ])
    c.key,
];

/// The plain dot's colour in the add field before anything is typed.
final _fieldColour = TaskColor.mint.key;

QuickAddDraft? _parse(
  String text,
  Profile profile,
  DateTime nowUtc,
  String lang,
) {
  if (text.trim().isEmpty) return null;
  final parsed = const QuickAddParser().parse(
    text,
    QuickAddContext(
      nowUtc: nowUtc,
      tzId: profile.tzId,
      language:
          QuickAddLanguage.values.asNameMap()[lang] ?? QuickAddLanguage.en,
    ),
  );
  return switch (parsed) {
    Ok(:final value) => value,
    Err() => null,
  };
}

/// The icon and colour the add field's dot shows for [text]: what its
/// words name (the app's own icon guess, as Quick Add uses), else the
/// plain dot in green.
({String iconKey, String colorKey}) fieldLook(
  BuildContext context,
  String text,
  Profile profile,
  DateTime nowUtc,
) {
  final lang = Localizations.localeOf(context).languageCode;
  final draft = _parse(text, profile, nowUtc, lang);
  final guess = draft == null ? null : guessIcon(draft.title, language: lang);
  return (
    iconKey: guess?.iconKey ?? defaultIconKey,
    colorKey: guess?.colorKey ?? _fieldColour,
  );
}

/// What [text] becomes on Return (`mountRhythm` submit), or null when it
/// is blank: its words (Quick Add's parser takes out the time and a
/// length), the icon and colour they name (else the plain dot in the
/// first colour not on a chip, [used]), at the time typed, kept inside
/// the day, or in the biggest gap between [taken] times; its typed length,
/// else Settings' default length.
DayFill? typedFill(
  BuildContext context,
  String text, {
  required Profile profile,
  required DateTime nowUtc,
  required int wake,
  required int wind,
  required List<int> taken,
  required List<String> used,
}) {
  final l10n = context.l10n;
  final lang = Localizations.localeOf(context).languageCode;
  final draft = _parse(text, profile, nowUtc, lang);
  if (draft == null) return null;
  // Capitalised, as the prototype writes it ("Walk the dog").
  final title = draft.title.isEmpty
      ? l10n.inboxUntitled
      : draft.title[0].toUpperCase() + draft.title.substring(1);
  final guess = guessIcon(draft.title, language: lang);
  final plain = _plainColours.firstWhere(
    (c) => !used.contains(c),
    orElse: () => _plainColours[used.length % _plainColours.length],
  );
  final start = draft.startUtc;
  int minute;
  if (start == null) {
    minute = fillGapMinute(wake, wind, taken);
  } else {
    final local = tz.TZDateTime.from(start, tz.getLocation(profile.tzId));
    minute = local.hour * 60 + local.minute;
    // "1am" with Wind Down at 2:00 is the night after (docs/05 Q8).
    if (minute < wake && minute + 24 * 60 <= wind) minute += 24 * 60;
    minute = clampFillMinute(minute, wake, wind);
  }
  return DayFill.typed(
    id: const UuidV7Generator().newId(),
    title: title,
    colorKey: guess == null ? plain : (guess.colorKey ?? plain),
    iconKey: guess?.iconKey ?? defaultIconKey,
    minute: minute,
    durationMin: draft.durationMin ?? profile.settings.defaultDurationMin,
  );
}
