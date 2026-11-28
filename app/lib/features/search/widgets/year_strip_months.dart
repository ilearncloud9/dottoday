import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/review/journal.dart';
import 'package:dottoday/features/search/widgets/year_strip_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;

/// The twelve month dots and the open month's days (E-R2-34 option B,
/// E-R2-42): four to a row on a phone, six from the dialog's width. A
/// tap or Return opens a month below; the arrows move between months
/// (ED-349). The dots are what Share image shares ([boundary]).
class YearStripMonths extends StatefulWidget {
  const YearStripMonths({
    required this.months,
    required this.boundary,
    required this.firstDayOfWeek,
    super.key,
  });

  /// Oldest first; the last is the month in progress.
  final List<StripMonth> months;
  final GlobalKey boundary;
  final int firstDayOfWeek;

  @override
  State<YearStripMonths> createState() => _YearStripMonthsState();
}

class _YearStripMonthsState extends State<YearStripMonths> {
  // Leaf view state (CLAUDE.md §4): the open month and the keys' focus.
  // The last whole month opens first, as E-R2-34 draws it.
  late int _open = (widget.months.length - 2).clamp(0, 11);
  late final _nodes = [
    for (var i = 0; i < widget.months.length; i++) FocusNode(),
  ];

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final perRow = box.maxWidth >= _sixFrom ? 6 : 4;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.l,
          children: [
            RepaintBoundary(
              key: widget.boundary,
              child: ColoredBox(
                color: DotTheme.of(context).colors.sheet,
                child: _grid(context, perRow),
              ),
            ),
            _MonthDays(
              month: widget.months[_open],
              firstDayOfWeek: widget.firstDayOfWeek,
            ),
          ],
        );
      },
    );
  }

  /// Width from which six months share a row (the 560 dialog).
  static const double _sixFrom = 440;

  Widget _grid(BuildContext context, int perRow) {
    final months = widget.months;
    return Column(
      spacing: DotSpace.m,
      children: [
        for (var r = 0; r * perRow < months.length; r++)
          Row(
            children: [
              for (var i = r * perRow; i < (r + 1) * perRow; i++)
                Expanded(
                  child: i < months.length
                      ? _month(context, i, perRow)
                      : const SizedBox.shrink(),
                ),
            ],
          ),
      ],
    );
  }

  Widget _month(BuildContext context, int i, int perRow) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final m = widget.months[i];
    final planned = m.shares.where((s) => s != null).length;
    final node = _nodes[i];
    return Semantics(
      button: true,
      selected: i == _open,
      // "Nov · 3 of 30 days planned" (R2-34's strings, ED-349).
      label: context.l10n.monthFooterPlanned(
        DateFormat.MMM(locale).format(m.month),
        planned,
        m.shares.length,
      ),
      excludeSemantics: true,
      onTap: () => setState(() => _open = i),
      child: Focus(
        focusNode: node,
        onFocusChange: (_) => setState(() {}),
        onKeyEvent: (_, e) => _key(e, i, perRow),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _open = i),
          child: Column(
            spacing: DotSpace.xxs,
            children: [
              YearMonthRing(
                planned: planned,
                days: m.shares.length,
                inProgress: i == widget.months.length - 1,
                open: i == _open,
                focused: node.hasFocus,
              ),
              Text(
                DateFormat.MMM(locale).format(m.month),
                style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ← → a month, ↑ ↓ a row, Return or Space opens it.
  KeyEventResult _key(KeyEvent e, int i, int perRow) {
    if (e is KeyUpEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final by = switch (e.logicalKey) {
      LogicalKeyboardKey.arrowLeft => rtl ? 1 : -1,
      LogicalKeyboardKey.arrowRight => rtl ? -1 : 1,
      LogicalKeyboardKey.arrowUp => -perRow,
      LogicalKeyboardKey.arrowDown => perRow,
      _ => 0,
    };
    if (by != 0) {
      final to = i + by;
      if (to >= 0 && to < _nodes.length) _nodes[to].requestFocus();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter ||
        e.logicalKey == LogicalKeyboardKey.space) {
      setState(() => _open = i);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

/// The open month: "October" and "October · 26 of 31 days planned" over
/// its days in weeks, one dot each.
class _MonthDays extends StatelessWidget {
  const _MonthDays({required this.month, required this.firstDayOfWeek});

  final StripMonth month;
  final int firstDayOfWeek;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final name = DateFormat.MMMM(locale).format(month.month);
    final shares = month.shares;
    final planned = shares.where((s) => s != null).length;
    final lead = (month.month.weekday - firstDayOfWeek) % 7;
    final cells = [for (var i = 0; i < lead; i++) null, ...shares.indexed];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.card,
        borderRadius: BorderRadius.circular(DotRadii.card),
        border: Border.all(color: t.colors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.s,
          children: [
            // Side by side, or one under the other when the words are
            // long (large text, longer languages).
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: DotSpace.s,
              children: [
                Text(name, style: t.styles.rowTitle),
                Text(
                  context.l10n.monthFooterPlanned(name, planned, shares.length),
                  style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
                ),
              ],
            ),
            ExcludeSemantics(
              child: Column(
                spacing: DotSpace.xs,
                children: [
                  for (var r = 0; r * 7 < cells.length; r++)
                    Row(
                      children: [
                        for (var c = r * 7; c < r * 7 + 7; c++)
                          Expanded(
                            child: Center(
                              child: c < cells.length && cells[c] != null
                                  ? YearDayDot(share: cells[c]!.$2)
                                  : const SizedBox.square(
                                      dimension: DotSize.yearDayDot,
                                    ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
