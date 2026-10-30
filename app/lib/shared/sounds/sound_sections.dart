import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/notifications/sound_names.gen.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/shared/sounds/sound_options.dart';

// The pickers' sections (docs/12 §6), in the owner's order.

/// Dottoday, Quiet, Clear, Playful: the normal-tier sounds.
List<SoundSection> normalSoundSections(AppLocalizations l10n) => [
  for (final (category, caption) in [
    (SoundCategory.dottoday, l10n.appTitle),
    (SoundCategory.quiet, l10n.soundSectionQuiet),
    (SoundCategory.clear, l10n.soundSectionClear),
    (SoundCategory.play, l10n.soundSectionPlayful),
  ])
    SoundSection(caption, _options(l10n, category)),
];

/// Settings › Sounds: System sound, None, then [normalSoundSections].
List<SoundSection> settingsSoundSections(AppLocalizations l10n) => [
  SoundSection(l10n.soundsTaskCaption, [
    SoundOption(key: soundSystemKey, label: l10n.settingsSoundSystem),
    SoundOption(
      key: soundNoneKey,
      label: l10n.soundNone,
      detail: l10n.soundNoneDetail,
    ),
  ]),
  ...normalSoundSections(l10n),
];

/// A task's picker: Default (naming [defaultName]), None, then
/// [normalSoundSections]. No System, Start or Done here (D2, D4).
List<SoundSection> taskSoundSections(
  AppLocalizations l10n, {
  required String defaultName,
}) => [
  SoundSection(l10n.sheetSound, [
    SoundOption(key: null, label: l10n.soundDefaultOption, detail: defaultName),
    SoundOption(
      key: soundNoneKey,
      label: l10n.soundNone,
      detail: l10n.soundNoneDetail,
    ),
  ]),
  ...normalSoundSections(l10n),
];

/// The Start sound list: the Dottoday alarm first, then the rest.
List<SoundSection> startSoundSections(AppLocalizations l10n) => [
  SoundSection(l10n.soundsStart, _options(l10n, SoundCategory.start)),
];

/// The Done sound list.
List<SoundSection> doneSoundSections(AppLocalizations l10n) => [
  SoundSection(l10n.soundsDone, _options(l10n, SoundCategory.done)),
];

/// How a stored default reads: "System sound", "None", or its name.
String reminderSoundName(AppLocalizations l10n, String? stored) =>
    switch (stored) {
      soundSystemKey => l10n.settingsSoundSystem,
      soundNoneKey => l10n.soundNone,
      _ => soundDisplayName(
        l10n,
        resolveSound(stored ?? defaultReminderSoundId),
      ),
    };

/// A task's Sound row: its own sound, "None", or "Default · Dot".
/// [own] is the occurrence's sound, else its series'.
String taskSoundText(
  AppLocalizations l10n, {
  required String? own,
  required String? defaultSound,
}) => switch (own) {
  null => l10n.soundDefault(reminderSoundName(l10n, defaultSound)),
  soundNoneKey => l10n.soundNone,
  final id => soundDisplayName(l10n, resolveSound(id)),
};

List<SoundOption> _options(AppLocalizations l10n, SoundCategory category) => [
  for (final sound in soundCatalogue)
    if (sound.category == category)
      SoundOption(
        key: sound.id,
        label: soundDisplayName(l10n, sound),
        detail: sound.id == insistentStartSoundId
            ? l10n.soundInsistentNote
            : null,
      ),
];
