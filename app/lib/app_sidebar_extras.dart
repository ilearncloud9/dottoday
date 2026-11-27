import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/shortcuts/single_keys.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/workspace/workspace_sidebar.dart';
import 'package:dottoday/shared/chips/key_cap.dart';
import 'package:dottoday/shared/navigation/dot_sidebar.dart';
import 'package:flutter/material.dart';

/// The web's minimal sidebar additions (E-R2-30, ED-500): "Search or run"
/// after the places, the keyboard hint above Settings while the single
/// keys are on, and the sync line under it.
SidebarExtras minimalWebSidebarExtras(BuildContext context) => (
  afterPlaces: const _SearchOrRunRow(),
  aboveFoot: SingleKeysOn.of(context) ? const _KeysHint() : null,
  belowFoot: const SidebarSyncFoot(),
);

/// "⋯ Search or run k": opens the palette, as the k key does.
class _SearchOrRunRow extends StatelessWidget {
  const _SearchOrRunRow();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Material(
      color: c.raised,
      borderRadius: BorderRadius.circular(DotRadii.railItem),
      child: InkWell(
        borderRadius: BorderRadius.circular(DotRadii.railItem),
        onTap: () => Actions.maybeInvoke(
          context,
          const AppCommandIntent(AppCommand.searchOrRun),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.min),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
            child: Row(
              spacing: DotSpace.m,
              children: [
                DotIcon(DotGlyphs.more, color: c.ink2),
                Expanded(
                  child: Text(
                    context.l10n.workspaceSearchOrRun,
                    style: t.styles.body,
                  ),
                ),
                if (SingleKeysOn.of(context))
                  const KeyCap('k'), // l10n-ignore: the web's single key
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Keyboard: n add · / search · t today · [ ] days · k everything else ·
/// ? help", the keys in bold (E-R2-30).
class _KeysHint extends StatelessWidget {
  const _KeysHint();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final base = t.styles.rowMeta.copyWith(color: t.colors.ink2);
    final bold = DotType.emphasis(base, bold: true, italic: false);
    final keys = [
      ('n', l10n.webKeyAdd), // l10n-ignore: a key
      ('/', l10n.webKeySearch), // l10n-ignore: a key
      ('t', l10n.webKeyToday), // l10n-ignore: a key
      ('[ ]', l10n.webKeyDays), // l10n-ignore: keys
      ('k', l10n.webKeyEverything), // l10n-ignore: a key
      ('?', l10n.webKeyHelp), // l10n-ignore: a key
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.s),
        child: Text.rich(
          TextSpan(
            style: base,
            children: [
              TextSpan(text: l10n.webKeysTitle),
              for (final (i, (key, what)) in keys.indexed) ...[
                TextSpan(text: i == 0 ? ' ' : ' · '), // l10n-ignore: spacing
                TextSpan(text: key, style: bold),
                TextSpan(text: ' $what'), // l10n-ignore: spacing
              ],
            ],
          ),
        ),
      ),
    );
  }
}
