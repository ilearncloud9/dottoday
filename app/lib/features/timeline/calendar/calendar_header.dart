import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/today_top_actions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The Calendar tab's top (E-Phones Calendar, ED-079): the month as the
/// title (tap: Go to date), Sync and the profile; under it the year and
/// how much the month holds, Today and ‹ ›. iPhone: "November ⌄" over
/// "2026 · 23 planned" with a Today pill; Android: the top app bar's
/// "November 2026 ▾" with a Today button, over "23 planned this month".
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    required this.month,
    required this.planned,
    required this.onGoTo,
    required this.onStep,
    required this.onToday,
    super.key,
  });

  /// Year/month on screen.
  final DateTime month;

  /// Tasks the month holds.
  final int planned;

  /// The title: Go to date (ED-342).
  final VoidCallback onGoTo;

  /// ‹ › and the swipe: -1 or 1 month.
  final ValueChanged<int> onStep;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final android = DotIdiom.of(context) == DotIdiom.material;
    final title = android
        ? DateFormat.yMMMM(locale).format(month)
        : DateFormat.MMMM(locale).format(month);
    final caption = android
        ? l10n.calendarMonthPlanned(planned)
        : l10n.calendarYearPlanned(DateFormat.y(locale).format(month), planned);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: DotSpace.xs,
          children: [
            Expanded(
              child: _Title(title: title, onTap: onGoTo),
            ),
            if (android)
              IconButton(
                onPressed: onToday,
                tooltip: l10n.todayPill,
                icon: DotIcon(
                  DotGlyphs.calendar,
                  color: t.colors.ink,
                  size: DotSize.headerGlyphAndroid,
                ),
              ),
            const TodayTopActions(sync: true),
          ],
        ),
        Row(
          spacing: DotSpace.xxs,
          children: [
            Expanded(
              child: Text(
                caption,
                style: t.styles.dayCaption.copyWith(letterSpacing: 0),
              ),
            ),
            CalendarNav(
              onToday: android ? null : onToday,
              onPrevious: () => onStep(-1),
              onNext: () => onStep(1),
              previous: l10n.monthPrevious,
              next: l10n.monthNext,
            ),
          ],
        ),
      ],
    );
  }
}

/// "November ⌄": a header that opens Go to date.
class _Title extends StatelessWidget {
  const _Title({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final android = DotIdiom.of(context) == DotIdiom.material;
    return Semantics(
      button: true,
      header: true,
      label: title,
      hint: context.l10n.weekStripShowMonth,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
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
                        DotGlyphs.chevronDown,
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
              style: android ? t.styles.topBarTitle : t.styles.dayTitle,
            ),
          ),
        ),
      ),
    );
  }
}

/// The Calendar's Today pill and ‹ › (E-Phones Calendar, E-R2-12):
/// touch sizes, no key hints. [onToday] null leaves the pill out
/// (Android's month has Today in its top app bar).
class CalendarNav extends StatelessWidget {
  const CalendarNav({
    required this.onToday,
    required this.onPrevious,
    required this.onNext,
    required this.previous,
    required this.next,
    super.key,
  });

  final VoidCallback? onToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Tooltips: "Previous month" / "Next week" …
  final String previous;
  final String next;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.xxs,
      children: [
        if (onToday case final today?)
          TextButton(
            onPressed: today,
            style: TextButton.styleFrom(
              backgroundColor: t.colors.card,
              foregroundColor: t.colors.accentText,
              shape: const StadiumBorder(),
              minimumSize: const Size(0, DotTouch.min),
            ),
            child: Text(context.l10n.todayPill),
          ),
        _Step(glyph: DotGlyphs.chevronLeft, label: previous, onTap: onPrevious),
        _Step(glyph: DotGlyphs.chevronRight, label: next, onTap: onNext),
      ],
    );
  }
}

/// ‹ or ›: 44 pt / 48 dp to touch.
class _Step extends StatelessWidget {
  const _Step({required this.glyph, required this.label, required this.onTap});

  final DotGlyph glyph;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final android = DotIdiom.of(context) == DotIdiom.material;
    return IconButton(
      onPressed: onTap,
      tooltip: label,
      style: IconButton.styleFrom(
        minimumSize: Size.square(android ? DotTouch.android : DotTouch.min),
      ),
      icon: DotIcon(
        glyph,
        color: android ? c.ink : c.accentText,
        size: DotSize.rowIcon,
        bold: !android,
      ),
    );
  }
}
