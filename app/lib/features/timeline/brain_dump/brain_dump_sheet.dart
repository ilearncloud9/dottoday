import 'dart:async';
import 'dart:convert';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/speech/dictation_controller.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_field.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_flow.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/thinking/thinking_copy.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// "Brain dump" (11 B4, docs/09 M12.5), from Today's ⋯: write or dictate
/// (the mic, M14.5) everything on your mind, one thing per line, pick Today or Tomorrow,
/// Plan it — a proposal places it on the day. Earlier dumps stay on this
/// device and can be searched and used again.
Future<void> showBrainDump(
  BuildContext context,
  DateTime today, {
  String text = '',
}) => showAppSheet<void>(
  context: context,
  title: context.l10n.dumpTitle,
  builder: (sheet) => BrainDumpBody(
    today: today,
    text: text,
    onPlanned: () => Navigator.of(sheet).pop(),
  ),
);

class BrainDumpBody extends ConsumerStatefulWidget {
  const BrainDumpBody({
    required this.today,
    this.onPlanned,
    this.text = '',
    super.key,
  });

  final DateTime today;

  /// Lines to start from (minimal Add's several lines, docs/14 §3 B4).
  final String text;

  /// The proposal is open: the sheet steps aside.
  final VoidCallback? onPlanned;

  @override
  ConsumerState<BrainDumpBody> createState() => _BrainDumpBodyState();
}

class _BrainDumpBodyState extends ConsumerState<BrainDumpBody> {
  // Leaf view state (CLAUDE.md §4): the text, the day and the search.
  late final _text = TextEditingController(text: widget.text);
  final _search = TextEditingController();
  bool _tomorrow = false;
  bool _busy = false;
  bool _nothing = false;
  List<BrainDump> _history = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    // Typed or dictated (M14.5): Plan it follows the text either way.
    _text.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() => _nothing = false);
  }

  Future<void> _load() async {
    final dumps = await ref.read(thinkingMemoryProvider).dumps();
    if (mounted) setState(() => _history = dumps);
  }

  @override
  void dispose() {
    _text.removeListener(_changed);
    _text.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final empty = _text.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        BrainDumpField(controller: _text),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(l10n.sheetToday)),
            ButtonSegment(value: true, label: Text(l10n.sheetTomorrow)),
          ],
          selected: {_tomorrow},
          onSelectionChanged: (s) => setState(() => _tomorrow = s.first),
        ),
        if (_nothing) Text(l10n.dumpNothing, style: t.styles.rowMeta),
        FilledButton(
          onPressed: empty || _busy ? null : () => unawaited(_plan(context)),
          child: Text(l10n.dumpPlan),
        ),
        // Which path will answer, before the tap (M14.2).
        if (ref.watch(thinkingStatusProvider).value case final s?)
          Text(
            l10n.plansWith(s),
            textAlign: TextAlign.center,
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
        // Minimal (docs/14 §3): no dump history.
        if (_history.isNotEmpty && watchOnScreen(ref, FeatureId.brainDumpEntry))
          ..._earlier(context),
      ],
    );
  }

  List<Widget> _earlier(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final shown = searchDumps(_history, _search.text).take(5);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return [
      const SizedBox(height: DotSpace.s),
      Semantics(
        header: true,
        child: Text(l10n.dumpEarlier.toUpperCase(), style: t.styles.caption),
      ),
      TextField(
        controller: _search,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(hintText: l10n.dumpSearch),
      ),
      for (final d in shown)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            LineSplitter.split(d.text).first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.styles.rowTitle,
          ),
          subtitle: Text(
            DateFormat.MMMEd(locale).format(d.atUtc.toLocal()),
            style: t.styles.rowMeta,
          ),
          trailing: TextButton(
            onPressed: () => setState(() => _text.text = d.text),
            child: Text(l10n.dumpUseAgain),
          ),
        ),
    ];
  }

  Future<void> _plan(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final l10n = context.l10n;
    final today = widget.today;
    final date = _tomorrow
        ? DateTime(today.year, today.month, today.day + 1)
        : today;
    final dayName = relativeDayName(context, date, today);
    // Plan it while listening: stop first, keep what was said (M14.5).
    await container.read(dictationControllerProvider.notifier).stopFor(_text);
    if (!context.mounted) return;
    setState(() => _busy = true);
    final planned = await planBrainDump(
      container,
      l10n,
      text: _text.text,
      date: date,
      dayName: dayName,
      beforeOpen: widget.onPlanned,
    );
    if (!mounted || planned) return;
    setState(() {
      _busy = false;
      _nothing = true;
    });
  }
}
