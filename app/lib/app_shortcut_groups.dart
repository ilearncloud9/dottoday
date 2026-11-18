import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/shared/sheets/shortcut_sheet.dart';
import 'package:flutter/foundation.dart';

/// Every binding for the ⌘/ sheet, by where it works (M3e.6, ED-095).
/// Keys read "⌘N" on Apple platforms and "Ctrl+N" elsewhere; the [web]
/// lists its single keys instead and leaves out what the browser keeps
/// (Back, ⌘D, ⇧⌘C). [minimal] names Minimal's ⌘3 and ⌘4. Kept beside
/// the bindings' owners: the app table, Today, Week / Month, the Inbox
/// page and the editor panel.
List<ShortcutGroup> appShortcutGroups(
  AppLocalizations l10n, {
  bool minimal = false,
  bool web = kIsWeb,
}) {
  final p = defaultTargetPlatform;
  String k(String key, {bool shift = false}) =>
      AppShortcuts.label(p, key, shift: shift);
  // The web's single key, or the app's ⌘ key.
  String w(String single, String key, {bool shift = false}) =>
      web ? single : k(key, shift: shift);
  return [
    (
      caption: l10n.shortcutsEverywhere,
      rows: [
        (keys: w('n', 'N'), action: l10n.shortcutAdd),
        (keys: w('⇧N', 'N', shift: true), action: l10n.shortcutBrainDump),
        if (!web) (keys: k('V', shift: true), action: l10n.shortcutPasteTasks),
        (keys: w('1', '1'), action: l10n.shortcutGoToday),
        (keys: w('2', '2'), action: l10n.shortcutGoInbox),
        (
          keys: w('3', '3'),
          action: minimal ? l10n.shortcutGoCalendar : l10n.shortcutGoWeek,
        ),
        (
          keys: w('4', '4'),
          action: minimal ? l10n.shortcutGoSearch : l10n.shortcutGoMonth,
        ),
        (keys: w('/', 'F'), action: l10n.shortcutSearch),
        if (!web) (keys: k('['), action: l10n.shortcutBack),
        (keys: w('⇧L', 'L', shift: true), action: l10n.shortcutToggleLayout),
        (keys: k('Z'), action: l10n.shortcutUndo),
        (keys: k('Z', shift: true), action: l10n.shortcutRedo),
        (keys: web ? '? ${k('/')}' : k('/'), action: l10n.shortcutShowKeys),
      ],
    ),
    (
      caption: l10n.shortcutsTodaySection,
      rows: [
        (keys: w('[', '←'), action: l10n.shortcutPrevDay),
        (keys: w(']', '→'), action: l10n.shortcutNextDay),
        (keys: w('t', 'T'), action: l10n.shortcutBackToday),
        if (!web) (keys: k('D'), action: l10n.shortcutDoneLive),
        if (!web) (keys: k('C', shift: true), action: l10n.shortcutCopyDay),
        (keys: '↑ ↓', action: l10n.shortcutPickTask),
        (keys: '${k('↑')} ${k('↓')}', action: l10n.shortcutNudgeTask),
        (
          keys: '${k('↑', shift: true)} ${k('↓', shift: true)}',
          action: l10n.shortcutNudgeTaskMore,
        ),
        (keys: l10n.shortcutKeyDelete, action: l10n.shortcutTrashTask),
        (keys: '↩', action: l10n.shortcutOpenTask),
        (
          keys: web
              ? l10n.shortcutKeySpace
              : '${l10n.shortcutKeySpace} ${k('D')}',
          action: l10n.shortcutDoneTask,
        ),
        if (!web) (keys: k('M', shift: true), action: l10n.shortcutMoveTask),
        (keys: w('f', 'F', shift: true), action: l10n.shortcutFocusTask),
      ],
    ),
    (
      caption: l10n.shortcutsWeekMonth,
      rows: [
        (keys: w('[', '←'), action: l10n.shortcutPrevPeriod),
        (keys: w(']', '→'), action: l10n.shortcutNextPeriod),
        (keys: w('t', 'T'), action: l10n.shortcutThisPeriod),
      ],
    ),
    (
      caption: l10n.shortcutsInbox,
      rows: [
        (keys: k('↩'), action: l10n.shortcutPlaceFirst),
        (keys: w('p', 'P', shift: true), action: l10n.shortcutAutoPlan),
      ],
    ),
    (
      caption: l10n.shortcutsEditor,
      rows: [
        (keys: k('S'), action: l10n.shortcutSave),
        if (!web) (keys: k('D'), action: l10n.shortcutDone),
        (keys: l10n.editorEscKey, action: l10n.shortcutClose),
      ],
    ),
  ];
}
