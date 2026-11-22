import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:timezone/timezone.dart' as tz;

/// A command the palette can run: a menu item's [label], its key cap
/// ([keys], "⇧⌘N"), and what it does.
@immutable
final class PaletteCommand {
  const PaletteCommand(this.label, this.run, {this.keys, this.search = false});

  final String label;
  final VoidCallback run;
  final String? keys;

  /// "Search for …", drawn with the magnifier.
  final bool search;
}

/// A row of the palette: a task, or a command.
sealed class PaletteItem {
  const PaletteItem();
}

final class PaletteTask extends PaletteItem {
  const PaletteTask(this.task);

  final Occurrence task;
}

final class PaletteRun extends PaletteItem {
  const PaletteRun(this.command);

  final PaletteCommand command;
}

/// "Tasks" and "Commands", each row highlighted at [at] (the keys) or
/// under the pointer; a tap or ↵ runs it.
class PaletteList extends StatelessWidget {
  const PaletteList({
    required this.items,
    required this.at,
    required this.query,
    required this.onHover,
    required this.onRun,
    super.key,
  });

  final List<PaletteItem> items;
  final int at;
  final String query;
  final ValueChanged<int> onHover;
  final ValueChanged<PaletteItem> onRun;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Text(
          l10n.paletteNothing,
          style: t.styles.body.copyWith(color: t.colors.muted),
          textAlign: TextAlign.center,
        ),
      );
    }
    final firstCommand = items.indexWhere((i) => i is PaletteRun);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: DotSpace.xs),
      children: [
        for (final (i, item) in items.indexed) ...[
          if (i == 0 && item is PaletteTask) _Heading(l10n.paletteTasks),
          if (i == firstCommand) _Heading(l10n.paletteCommands),
          _Row(
            selected: i == at,
            onHover: () => onHover(i),
            onTap: () => onRun(item),
            child: switch (item) {
              PaletteTask(:final task) => _TaskLine(task: task),
              PaletteRun(:final command) => _CommandLine(command: command),
            },
          ),
        ],
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      DotSpace.m,
      DotSpace.s,
      DotSpace.m,
      DotSpace.xs,
    ),
    child: Semantics(
      header: true,
      child: Text(text, style: DotTheme.of(context).styles.caption),
    ),
  );
}

/// A highlightable row that brings itself into view when the keys reach
/// it.
class _Row extends StatefulWidget {
  const _Row({
    required this.selected,
    required this.onHover,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onHover;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  @override
  void didUpdateWidget(_Row old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Scrollable.ensureVisible(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.xs),
      child: Semantics(
        button: true,
        selected: widget.selected,
        child: MouseRegion(
          onEnter: (_) => widget.onHover(),
          child: Material(
            color: widget.selected ? t.colors.accentTint : Colors.transparent,
            borderRadius: BorderRadius.circular(DotRadii.menuMac),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(DotRadii.menuMac),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: DotTouch.pointer + DotSpace.s + DotSpace.xs,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A task: its dot, title, and "Tue, Nov 3 · 9:00 – 11:00 AM" or
/// "Inbox · 20 min" at the end.
class _TaskLine extends ConsumerWidget {
  const _TaskLine({required this.task});

  final Occurrence task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    final start = task.startUtc;
    final end = task.endUtc;
    final String meta;
    if (start == null || end == null) {
      meta = l10n.searchMetaInbox(formatDurationShort(l10n, task.durationMin));
    } else {
      final zone = tz.getLocation(task.tzId);
      final locale = Localizations.localeOf(context).toLanguageTag();
      String time(DateTime utc) =>
          timeOfUtc(context, zone, utc, use24h: use24h);
      meta = l10n.searchMetaDay(
        DateFormat.MMMEd(locale).format(tz.TZDateTime.from(start, zone)),
        l10n.threadTimeRange(time(start), time(end)),
      );
    }
    return Row(
      spacing: DotSpace.s,
      children: [
        ExcludeSemantics(
          child: TaskDot(
            color: TaskColor.fromKey(task.colorKey),
            icon: TaskIcon.fromKey(task.iconKey),
            state: DotState.upcoming,
            label: task.title,
            size: DotSize.pickerDot,
          ),
        ),
        Expanded(
          child: Text(
            task.title,
            style: t.styles.rowMeta.copyWith(
              color: t.colors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Shares the width with the title, so a long date never squeezes
        // the title into a column.
        Flexible(
          child: Text(meta, style: t.styles.rowMeta, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

/// A command: its name and key cap; "Search for …" with the magnifier.
class _CommandLine extends StatelessWidget {
  const _CommandLine({required this.command});

  final PaletteCommand command;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      spacing: DotSpace.s,
      children: [
        if (command.search)
          DotIcon(
            DotGlyphs.search,
            color: t.colors.muted,
            size: DotSize.rowIcon - DotSpace.xs,
          ),
        Expanded(
          child: Text(
            command.label,
            style: t.styles.rowMeta.copyWith(color: t.colors.text),
          ),
        ),
        if (command.keys case final k?)
          ExcludeSemantics(child: Text(k, style: t.styles.sidebarHint)),
      ],
    );
  }
}

/// "↑↓ to move · ↵ to open · esc to close".
class PaletteFooter extends StatelessWidget {
  const PaletteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.colors.threadAhead)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.m,
            vertical: DotSpace.xs + DotSpace.xxs,
          ),
          child: Text(context.l10n.paletteFooter, style: t.styles.sidebarHint),
        ),
      ),
    );
  }
}
