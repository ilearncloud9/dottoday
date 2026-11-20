import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/day_column_prefs.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/features/timeline/now/now_body.dart';
import 'package:dottoday/features/timeline/now/now_inputs.dart';
import 'package:dottoday/features/timeline/now/wide/now_dot_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The Now pane (E-Minimal frames 1 and 2; ED-232; E-R2-1 2a, 2b, 4a):
/// "Now · 10:42" in the apps (the Mac, iPad, Android tablets: [app]), or on
/// the web the date, the time and Wind Down with Add; the horizon, whose
/// dots take a right-click; then [NowBody] with the apps' 280 or the web's
/// 240 orb (ED-106) and the Add and Day column rows beside Also now and
/// Next. [stacked]: medium windows, the Day under it (6e-2), so no Day row
/// and no scroll of its own.
class NowPane extends ConsumerWidget {
  const NowPane({
    required this.inputs,
    required this.app,
    required this.dayHidden,
    this.onDayRow,
    this.stacked = false,
    super.key,
  });

  final NowInputs inputs;
  final bool app;
  final bool dayHidden;
  final bool stacked;

  /// The folded window's Day row: it opens or closes the column's panel
  /// (ED-170) rather than hiding the column.
  final VoidCallback? onDayRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final n = inputs;
    void showDay() => unawaited(
      ref.read(dayColumnHiddenProvider.notifier).set(hidden: false),
    );
    final body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DotSize.nowPaneContent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (app) _NowAt(time: n.time(n.nowUtc)) else _WebHeader(inputs: n),
            const SizedBox(height: DotSpace.m),
            n.horizon(
              context,
              // With the Day column put away, the horizon brings it back
              // (`/today` reveals it too, ED-097).
              onTap: dayHidden && !stacked ? (onDayRow ?? showDay) : null,
              hint: dayHidden && !stacked ? l10n.dayColumnShow : null,
              onDotMenu: (o, at) =>
                  unawaited(showNowDotMenu(context, ref, o, at)),
            ),
            const SizedBox(height: DotSpace.xxl),
            NowBody(
              view: n.view,
              nowUtc: n.nowUtc,
              windDownUtc: n.shape.bedUtc,
              time: n.time,
              orbSize: _orb(context),
              asideBelow: stacked,
              aside: _Aside(
                dayRow: !stacked,
                dayHidden: dayHidden,
                onDayRow: onDayRow,
              ),
            ),
          ],
        ),
      ),
    );
    if (stacked) return body;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.xxl,
        vertical: DotSpace.l,
      ),
      children: [body],
    );
  }
}

/// The apps' 280 or the web's 240 orb (ED-106); under 720 tall it draws
/// at 72 %, unless text is above 130 % (ED-170). The pane scrolls.
extension on NowPane {
  double _orb(BuildContext context) {
    final base = app ? DotSize.orbMac : DotSize.orbWeb;
    final short = MediaQuery.sizeOf(context).height < DotSize.shortWindow;
    final large =
        MediaQuery.textScalerOf(context).scale(1) > DotSize.shortOrbTextLimit;
    return short && !large ? base * DotSize.shortOrb : base;
  }
}

/// "Now · 10:42" over the apps' horizon (E-Minimal 1, E-R2-1 2a).
class _NowAt extends StatelessWidget {
  const _NowAt({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Text(
      context.l10n.nowAt(time),
      style: t.styles.rowTitle.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// The web's header (frame 2): "Tue 3 Nov · 10:42", "Wind Down at 11:00
/// PM", and + Add; the Mac has these in its toolbar.
class _WebHeader extends StatelessWidget {
  const _WebHeader({required this.inputs});

  final NowInputs inputs;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final n = inputs;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.nowDateAt(
                    DateFormat.MMMEd(locale).format(n.today),
                    n.time(n.nowUtc),
                  ),
                  style: t.styles.cardTitle,
                ),
              ),
              Text(
                l10n.nowWindDown(n.time(n.shape.bedUtc)),
                style: t.styles.rowMeta.copyWith(color: t.colors.muted),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () => Actions.maybeInvoke(
            context,
            const AppCommandIntent(AppCommand.quickAdd),
          ),
          icon: DotIcon(DotGlyphs.add, color: t.colors.onAccent),
          label: Text(l10n.addAdd),
        ),
      ],
    );
  }
}

/// Beside Also now and Next (E-Minimal frame 1): the Add row (Quick Add,
/// several lines for many) and Hide the Day column, or Show it.
class _Aside extends ConsumerWidget {
  const _Aside({required this.dayRow, required this.dayHidden, this.onDayRow});

  /// Off where the Day sits under Now (medium, E-R2-1 2b).
  final bool dayRow;
  final bool dayHidden;
  final VoidCallback? onDayRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    // Key hints on the Mac only; touch has none, and 48 rows (E-R2-1).
    final mac = macApp(context);
    final touch = watchTouchContent(context, ref);
    Widget row({
      required String label,
      required VoidCallback onTap,
      String? keys,
      DotGlyph? glyph,
      bool outlined = false,
    }) => Material(
      color: outlined ? t.colors.raised : t.colors.sunk,
      shape: StadiumBorder(
        side: outlined ? BorderSide(color: t.colors.outline) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: touch ? DotTouch.android : DotTouch.min,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
            child: Row(
              spacing: DotSpace.s,
              children: [
                if (glyph != null)
                  DotIcon(glyph, color: t.colors.muted, size: DotSize.rowIcon),
                Expanded(
                  child: Text(
                    label,
                    style: t.styles.rowMeta.copyWith(
                      color: outlined ? t.colors.muted : t.colors.text,
                    ),
                  ),
                ),
                if (mac && keys != null)
                  Text(
                    keys,
                    style: t.styles.caption.copyWith(color: t.colors.muted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return Column(
      spacing: DotSpace.s,
      children: [
        row(
          label: l10n.nowAddField,
          glyph: DotGlyphs.add,
          keys: '⌘N', // l10n-ignore: a key cap
          outlined: true,
          onTap: () => Actions.maybeInvoke(
            context,
            const AppCommandIntent(AppCommand.quickAdd),
          ),
        ),
        if (dayRow)
          row(
            label: dayHidden ? l10n.dayColumnShow : l10n.dayColumnHide,
            keys: '⌥⌘I', // l10n-ignore: a key cap
            onTap:
                onDayRow ??
                () => unawaited(
                  ref.read(dayColumnHiddenProvider.notifier).toggle(),
                ),
          ),
      ],
    );
  }
}
