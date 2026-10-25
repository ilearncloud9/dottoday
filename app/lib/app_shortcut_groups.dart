import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/shared/sheets/shortcut_sheet.dart';
import 'package:flutter/foundation.dart';

/// Every binding for the ⌘/ sheet, by where it works (M3e.6). Keys read
/// "⌘N" on Apple platforms and "Ctrl+N" elsewhere. Kept beside the
/// bindings' owners: the app table, Today, Week / Month, the Inbox page
/// and the editor panel.
List<ShortcutGroup> appShortcutGroups(AppLocalizations l10n) {
  final p = defaultTargetPlatform;
  String k(String key, {bool shift = false}) =>
      AppShortcuts.label(p, key, shift: shift);
  return [
    (
      caption: l10n.shortcutsEverywhere,
      rows: [
        (keys: k('N'), action: l10n.shortcutAdd),
        (keys: k('1'), action: l10n.shortcutGoToday),
        (keys: k('2'), action: l10n.shortcutGoInbox),
        (keys: k('3'), action: l10n.shortcutGoWeek),
        (keys: k('4'), action: l10n.shortcutGoMonth),
        (keys: k('Z'), action: l10n.shortcutUndo),
        (keys: k('Z', shift: true), action: l10n.shortcutRedo),
        (keys: k('/'), action: l10n.shortcutShowKeys),
      ],
    ),
    (
      caption: l10n.shortcutsTodaySection,
      rows: [
        (keys: k('←'), action: l10n.shortcutPrevDay),
        (keys: k('→'), action: l10n.shortcutNextDay),
        (keys: k('T'), action: l10n.shortcutBackToday),
        (keys: k('D'), action: l10n.shortcutDoneLive),
        (keys: '↑ ↓', action: l10n.shortcutPickTask),
        (keys: '${k('↑')} ${k('↓')}', action: l10n.shortcutNudgeTask),
        (
          keys: '${k('↑', shift: true)} ${k('↓', shift: true)}',
          action: l10n.shortcutNudgeTaskMore,
        ),
        (keys: l10n.shortcutKeyDelete, action: l10n.shortcutTrashTask),
        (keys: '↩', action: l10n.shortcutOpenTask),
        (keys: l10n.shortcutKeySpace, action: l10n.shortcutDoneTask),
      ],
    ),
    (
      caption: l10n.shortcutsWeekMonth,
      rows: [
        (keys: k('←'), action: l10n.shortcutPrevPeriod),
        (keys: k('→'), action: l10n.shortcutNextPeriod),
        (keys: k('T'), action: l10n.shortcutThisPeriod),
      ],
    ),
    (
      caption: l10n.shortcutsInbox,
      rows: [
        (keys: k('↩'), action: l10n.shortcutPlaceFirst),
        (keys: k('P', shift: true), action: l10n.shortcutAutoPlan),
      ],
    ),
    (
      caption: l10n.shortcutsEditor,
      rows: [
        (keys: k('S'), action: l10n.shortcutSave),
        (keys: k('D'), action: l10n.shortcutDone),
        (keys: l10n.editorEscKey, action: l10n.shortcutClose),
      ],
    ),
  ];
}
