import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// "✓ Completed · 12", folded until tapped (`A-ios-inbox`); open, each
/// done item with its done dot and day, a button to put it back, and
/// "Clear completed" to Trash them all (10 §5.3 "Completed group
/// expanded", docs/09 M3f.6). Both confirm with Undo.
class CompletedGroup extends StatelessWidget {
  const CompletedGroup({
    required this.items,
    required this.onNotDone,
    required this.onClear,
    super.key,
  });

  final List<Occurrence> items;
  final ValueChanged<Occurrence> onNotDone;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Theme(
      // No dividers: the group sits on the page like the rows above it.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        // Stays open while rows above it come and go (a task put back).
        key: const PageStorageKey('inbox-completed'), // l10n-ignore: a key
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        leading: const _DoneDot(),
        title: Text(
          context.l10n.inboxCompleted(items.length),
          style: t.styles.cardTitle.copyWith(color: c.muted),
        ),
        children: [
          for (final o in items)
            _DoneRow(item: o, onNotDone: () => onNotDone(o)),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onClear,
              child: Text(context.l10n.inboxClearCompleted),
            ),
          ),
        ],
      ),
    );
  }
}

/// A filled check: the done state, as on the thread.
class _DoneDot extends StatelessWidget {
  const _DoneDot();

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, color: c.hairline),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.xxs),
        child: DotIcon(
          DotGlyphs.check,
          color: c.raised,
          size: DotSize.rowIcon - DotSpace.xs,
          active: true,
        ),
      ),
    );
  }
}

/// "~~Book flights~~ · Done Tue, Oct 20" and ↺ (not done).
class _DoneRow extends StatelessWidget {
  const _DoneRow({required this.item, required this.onNotDone});

  final Occurrence item;
  final VoidCallback onNotDone;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final at = item.completedAtUtc;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: DotTouch.android,
      title: Text(
        item.title,
        style: t.styles.body.copyWith(
          color: t.colors.muted,
          decoration: TextDecoration.lineThrough,
        ),
      ),
      subtitle: at == null
          ? null
          : Text(
              l10n.inboxDoneOn(
                DateFormat.MMMEd(
                  locale,
                ).format(tz.TZDateTime.from(at, tz.getLocation(item.tzId))),
              ),
              style: t.styles.rowMeta,
            ),
      trailing: IconButton(
        tooltip: l10n.inboxNotDone(item.title),
        onPressed: onNotDone,
        icon: DotIcon(DotGlyphs.undo, color: t.colors.muted),
      ),
    );
  }
}
