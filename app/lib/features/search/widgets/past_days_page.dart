import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/review/journal.dart';
import 'package:dottoday/features/search/state/journal_state.dart';
import 'package:dottoday/features/search/widgets/journal_day_row.dart';
import 'package:dottoday/features/search/widgets/year_strip.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Search › Past days (11 D3, docs/09 M12.3): every past day of the last
/// twelve months as its thread, newest first; a search answers "when did
/// I last…?"; Year strip shares the twelve months as an image. Read-only:
/// a tap opens the day.
class PastDaysPage extends ConsumerStatefulWidget {
  const PastDaysPage({super.key});

  static const _key = ValueKey('route:search:past');

  @override
  ConsumerState<PastDaysPage> createState() => _PastDaysPageState();
}

class _PastDaysPageState extends ConsumerState<PastDaysPage> {
  // Leaf view state (CLAUDE.md §4): the journal's own search text.
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(pastDaysProvider);
    final waiting = screenState([
      async,
    ], onRetry: () => ref.invalidate(pastDaysProvider));
    return Scaffold(
      key: PastDaysPage._key,
      appBar: AppBar(
        title: Text(l10n.journalTitle),
        actions: [
          if (async.value case final data? when data.days.isNotEmpty)
            TextButton(
              onPressed: () => unawaited(
                showYearStrip(context, yearStrip(data.days, data.today)),
              ),
              child: Text(l10n.journalStripTitle),
            ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: waiting ?? _list(context, async.requireValue),
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, JournalData data) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final query = _query.text.trim();
    final days = query.isEmpty ? data.days : searchJournal(data.days, query);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.page,
        DotSpace.fabClearance,
      ),
      itemCount: days.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: DotSpace.s),
      itemBuilder: (context, i) {
        if (i > 0) {
          final day = days[i - 1];
          return JournalDayRow(
            day: day,
            data: data,
            query: query,
            onOpen: () => context.go(AppRoutes.day(day.date)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.s,
          children: [
            TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.journalSearchHint,
                prefixIcon: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: DotIcon(
                    DotGlyphs.search,
                    color: t.colors.muted,
                    size: DotSize.rowIcon,
                  ),
                ),
              ),
            ),
            Text(_summary(context, data, days, query), style: t.styles.rowMeta),
          ],
        );
      },
    );
  }

  /// "Last: Tue, Oct 20 · 5 days ago · 12 days" or "143 days".
  static String _summary(
    BuildContext context,
    JournalData data,
    List<JournalDay> days,
    String query,
  ) {
    final l10n = context.l10n;
    if (data.days.isEmpty) return l10n.journalEmpty;
    if (query.isEmpty) return l10n.journalDays(days.length);
    if (days.isEmpty) return l10n.journalNoMatch(query);
    final last = days.first.date;
    final ago = DateTime.utc(
      data.today.year,
      data.today.month,
      data.today.day,
    ).difference(DateTime.utc(last.year, last.month, last.day)).inDays;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return l10n.journalLast(
      DateFormat.MMMEd(locale).format(last),
      ago,
      days.length,
    );
  }
}

/// "Past days" under Search's chips: opens [PastDaysPage].
class PastDaysEntry extends StatelessWidget {
  const PastDaysEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Material(
      color: t.colors.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.card),
        side: BorderSide(color: t.colors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: SettingsRow(
        glyph: DotGlyphs.rollForward,
        tint: t.tasks[TaskColor.violet].ink,
        title: l10n.journalTitle,
        subtitle: l10n.journalEntryDetail,
        onTap: () => unawaited(
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const PastDaysPage())),
        ),
      ),
    );
  }
}
