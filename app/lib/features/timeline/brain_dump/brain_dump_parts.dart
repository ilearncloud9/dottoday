import 'dart:convert';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// "Put it on  ✓ Today  Tomorrow" (E-Phones-2): Brain dump's day, as
/// choice chips.
class BrainDumpDay extends StatelessWidget {
  const BrainDumpDay({
    required this.tomorrow,
    required this.onChanged,
    super.key,
  });

  final bool tomorrow;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    Widget chip(String label, bool value) {
      final on = tomorrow == value;
      return ChoiceChip(
        label: Text(label),
        selected: on,
        onSelected: (_) => onChanged(value),
        showCheckmark: true,
        checkmarkColor: t.colors.onAccent,
        selectedColor: t.colors.accent,
        backgroundColor: t.colors.tonal,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: t.styles.chip.copyWith(
          color: on ? t.colors.onAccent : t.colors.accentText,
        ),
      );
    }

    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l10n.dumpPutOn, style: t.styles.rowMeta),
        chip(l10n.sheetToday, false),
        chip(l10n.sheetTomorrow, true),
      ],
    );
  }
}

/// "EARLIER DUMPS" on a card (E-Phones-2): up to five, each with its
/// first line, "Mon, Nov 2 · 5 lines" and Use again. The search shows
/// once there are more than five to look through.
class BrainDumpEarlier extends StatelessWidget {
  const BrainDumpEarlier({
    required this.history,
    required this.search,
    required this.onSearch,
    required this.onUse,
    super.key,
  });

  final List<BrainDump> history;
  final TextEditingController search;
  final VoidCallback onSearch;
  final ValueChanged<String> onUse;

  static const _shown = 5;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final rows = searchDumps(history, search.text).take(_shown);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.sunk,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.m,
          DotSpace.m,
          DotSpace.xs,
          DotSpace.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.dumpEarlier.toUpperCase(),
                style: t.styles.caption,
              ),
            ),
            if (history.length > _shown)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: DotSpace.s),
                child: TextField(
                  contextMenuBuilder: systemTextMenu,
                  controller: search,
                  onChanged: (_) => onSearch(),
                  decoration: InputDecoration(hintText: l10n.dumpSearch),
                ),
              ),
            for (final d in rows)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LineSplitter.split(d.text).first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.styles.body,
                        ),
                        Text(
                          l10n.dumpEarlierMeta(
                            DateFormat.MMMEd(locale).format(d.atUtc.toLocal()),
                            LineSplitter.split(
                              d.text,
                            ).where((l) => l.trim().isNotEmpty).length,
                          ),
                          style: t.styles.rowMeta,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => onUse(d.text),
                    child: Text(l10n.dumpUseAgain),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
