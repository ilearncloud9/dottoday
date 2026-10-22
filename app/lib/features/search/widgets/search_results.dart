import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/search/search_results.dart';
import 'package:dottoday/features/search/state/search_state.dart';
import 'package:dottoday/features/search/widgets/search_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The results under their headings: "WEDNESDAY · TODAY", "MONDAY 19",
/// "INBOX" (`A-ios-search`).
List<Widget> searchResultSlivers(
  BuildContext context, {
  required SearchView view,
  required String query,
  required ValueChanged<Occurrence> onOpen,
  required ValueChanged<Occurrence> onSchedule,
}) => [
  for (final MapEntry(key: group, value: rows) in view.groups.entries) ...[
    SliverToBoxAdapter(
      child: _Heading(group: group, today: view.today),
    ),
    SliverList.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: DotSpace.s),
      itemBuilder: (context, i) => SearchRow(
        task: rows[i],
        query: query,
        view: view,
        onOpen: () => onOpen(rows[i]),
        onSchedule: () => onSchedule(rows[i]),
      ),
    ),
  ],
];

class _Heading extends StatelessWidget {
  const _Heading({required this.group, required this.today});

  final ResultGroup group;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final style = t.styles.caption;
    final Widget text = switch (group) {
      DayGroup(:final date) when date == today => _today(
        t,
        l10n.searchGroupToday(DateFormat.EEEE(locale).format(date)),
        l10n.searchFilterToday,
      ),
      DayGroup(:final date) => Text(
        l10n
            .searchDayLabel(
              DateFormat.EEEE(locale).format(date),
              DateFormat.d(locale).format(date),
            )
            .toUpperCase(),
        style: style,
      ),
      InboxGroup() => Text(l10n.searchGroupInbox.toUpperCase(), style: style),
    };
    return Padding(
      padding: const EdgeInsets.only(top: DotSpace.l, bottom: DotSpace.s),
      child: Semantics(header: true, child: text),
    );
  }

  /// "WEDNESDAY · TODAY" with "TODAY" in the accent (`A-ios-search`).
  Widget _today(DotTheme t, String full, String today) {
    final upper = full.toUpperCase();
    final at = upper.lastIndexOf(today.toUpperCase());
    if (at < 0) return Text(upper, style: t.styles.caption);
    return Text.rich(
      TextSpan(
        style: t.styles.caption,
        children: [
          TextSpan(text: upper.substring(0, at)),
          TextSpan(
            text: upper.substring(at, at + today.length),
            style: TextStyle(color: t.colors.accentInk),
          ),
          TextSpan(text: upper.substring(at + today.length)),
        ],
      ),
    );
  }
}
