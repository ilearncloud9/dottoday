import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_actions.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_parts.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/widgets/day_numbers.dart';
import 'package:dottoday/features/timeline/widgets/day_titles.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/widgets/today_top_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Today's header (E-Phones, ED-040): the date as the title, "Wed, Oct 21
/// ⌄" (tap: month), with "‹ Today" before it away from today and ⋯, Sync
/// and the profile after it; the day's numbers under it.
/// Minimal (docs/14 §4): the date, ⋯ and the profile, no numbers.
class TodayHeader extends ConsumerWidget {
  const TodayHeader({
    required this.date,
    required this.today,
    required this.monthOpen,
    required this.month,
    required this.onToday,
    this.menu = true,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final bool monthOpen;

  /// The month shown when [monthOpen].
  final DateTime month;

  /// Back to today (the pill shown away from it, `A-ios-future-month`).
  final VoidCallback onToday;

  /// The header's ⋯ Day menu; off where [DayMenuChip] floats instead.
  final bool menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final low = date == today && watchLowEnergy(ref);
    final extras = watchOnScreen(ref, FeatureId.headerExtras);
    final short = AppLayout.isShort(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.s,
        DotSpace.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, box) {
              final title = _title(context, ref, locale);
              final back = !low && date != today;
              final heading = _TitleButton(title: title, monthOpen: monthOpen);
              final buttons = [
                // ⋯ where no Day ▾ chip floats over the day (landscape,
                // tablets, Minimal's Today; M20.3).
                if (menu) TodayMenu(date: date, today: today),
                // Sync and the profile (ED-034); Settings sits behind the
                // profile on phones only (ED-238).
                TodayTopActions(sync: extras),
              ];
              // Away from today, "‹ Today" leads the row (ED-034, ED-040).
              final lead = [if (back) TodayBack(onTap: onToday)];
              if (short) {
                return Row(
                  spacing: DotSpace.xs,
                  children: [
                    ...lead,
                    heading,
                    // Phone landscape: the numbers beside the title
                    // (ED-347).
                    Expanded(
                      child: !low && !monthOpen && extras
                          ? DayNumbers(date: date)
                          : const SizedBox.shrink(),
                    ),
                    ...buttons,
                  ],
                );
              }
              final room =
                  box.maxWidth - _reserved(context, back: back, sync: extras);
              if (_TitleButton.fits(context, title, room)) {
                return Row(
                  spacing: DotSpace.xs,
                  children: [
                    ...lead,
                    Expanded(child: heading),
                    ...buttons,
                  ],
                );
              }
              // Too long beside the buttons (another day's date, larger
              // text): the buttons keep the top row and the title takes
              // its own line, never broken mid-word (rules §12.1).
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: DotSpace.xs,
                    children: [...lead, const Spacer(), ...buttons],
                  ),
                  heading,
                ],
              );
            },
          ),
          // Low energy's switch sits by its caption: the top row has the
          // title, ⋯ and Settings (ED-238) and no room for it on a phone.
          if (low)
            Row(
              children: [
                Expanded(
                  child: _Caption(
                    l10n.lowEnergyCaption(
                      DateFormat.MMMEd(locale).format(date),
                    ),
                  ),
                ),
                LowEnergySwitch(
                  onChanged: (on) => toggleLowEnergy(context, on: on),
                ),
              ],
            )
          else if (!monthOpen && extras && !short)
            DayNumbers(date: date),
        ],
      ),
    );
  }

  String _title(BuildContext context, WidgetRef ref, String locale) {
    if (date == today && watchLowEnergy(ref)) {
      return lowEnergyTitle(context, ref);
    }
    final otherMonth = month.year != today.year || month.month != today.month;
    if (monthOpen && otherMonth) {
      // Phones share the row with ‹ Today, ⋯ and the capsule: "Dec 2026",
      // so the month never breaks mid-word.
      return AppLayout.classOf(context) == WidthClass.compact
          ? DateFormat.yMMM(locale).format(month)
          : DateFormat.yMMMM(locale).format(month);
    }
    // The date, as Structured's header (ADR-0015); the spread keeps the
    // greeting (dayTitle). Phones share the row with ⋯ and Settings
    // (ED-238), so the short date, as E-Phones draws it (ED-040).
    return AppLayout.classOf(context) == WidthClass.compact
        ? DateFormat.MMMEd(locale).format(date)
        : DateFormat.yMMMMd(locale).format(date);
  }
}

/// [style] as a Text would draw it: over the inherited style, which holds
/// the face a platform style leaves to the system.
TextStyle _inherited(BuildContext context, TextStyle style) =>
    DefaultTextStyle.of(context).style.merge(style);

/// The top row's width besides the title: "‹ Today" when shown, ⋯, and
/// Sync and the profile, from their own sizes (44 pt / 48 dp targets).
double _reserved(
  BuildContext context, {
  required bool back,
  required bool sync,
}) {
  final t = DotTheme.of(context);
  final glass = DotIdiom.of(context) == DotIdiom.cupertino;
  final target = glass ? DotTouch.min : DotTouch.android;
  final phone = AppLayout.classOf(context) == WidthClass.compact;
  final pill = back
      ? textWidth(
              context,
              context.l10n.todayPill,
              _inherited(context, t.styles.button),
            ) +
            DotSize.rowIcon +
            DotSpace.xxs +
            DotSpace.s +
            DotSpace.m
      : 0.0;
  final actions = sync
      ? DotTouch.android + (phone ? target : 0) + (glass ? 2 * DotSpace.xxs : 0)
      : (phone ? target : 0.0);
  final gaps = DotSpace.xs * (back ? 3 : 2);
  return pill + DotTouch.android + actions + gaps;
}

/// The title, which opens the month (the chevron says which way).
class _TitleButton extends ConsumerWidget {
  const _TitleButton({required this.title, required this.monthOpen});

  final String title;
  final bool monthOpen;

  /// Whether [title] and its chevron fit [width] on one line.
  static bool fits(BuildContext context, String title, double width) {
    final t = DotTheme.of(context);
    final android = DotIdiom.of(context) != DotIdiom.cupertino;
    final style = android ? t.styles.topBarTitle : t.styles.dayTitle;
    final chevron =
        (android ? DotSize.headerGlyphAndroid : DotSize.rowIcon) + DotSpace.xs;
    return textWidth(context, title, _inherited(context, style)) + chevron <=
        width;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    // E-Phones: iPhone's 28 bold title with a teal chevron (ED-040);
    // Android's top app bar title, 24 regular, with an ink arrow.
    final android = DotIdiom.of(context) != DotIdiom.cupertino;
    final style = android ? t.styles.topBarTitle : t.styles.dayTitle;
    return Semantics(
      button: true,
      header: true,
      expanded: monthOpen,
      label: title,
      hint: monthOpen ? l10n.weekStripHideMonth : l10n.weekStripShowMonth,
      excludeSemantics: true,
      // The InkWell's own action is excluded above; a screen reader needs
      // this one to open the month (R-12, found by the M16 tappable sweep).
      onTap: ref.read(todaySelectionProvider.notifier).toggleMonth,
      child: InkWell(
        onTap: ref.read(todaySelectionProvider.notifier).toggleMonth,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Text.rich(
            TextSpan(
              text: title,
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: DotSpace.xs,
                    ),
                    child: DotIcon(
                      monthOpen ? DotGlyphs.chevronUp : DotGlyphs.chevronDown,
                      color: android ? t.colors.ink : t.colors.accent,
                      size: android
                          ? DotSize.headerGlyphAndroid
                          : DotSize.rowIcon,
                      bold: !android,
                    ),
                  ),
                ),
              ],
            ),
            style: style,
          ),
        ),
      ),
    );
  }
}

/// A muted line under the title (low-energy mode's "Thursday · low energy").
class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Text(text, style: t.styles.dayCaption.copyWith(letterSpacing: 0));
  }
}
