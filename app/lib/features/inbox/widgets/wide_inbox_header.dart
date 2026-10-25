import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/inbox_routines_button.dart';
import 'package:dottoday/shared/dot/count_ring.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/menus/dot_menu_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The key of Auto-plan's ⇧⌘P.
const _key = 'P'; // l10n-ignore: a key cap, not words

/// "Inbox", "5 unscheduled · 5 h 15 of work", Sort, Auto-plan the week
/// (⇧⌘P) and the count ring (`A-mac-inbox`).
class WideInboxHeader extends ConsumerWidget {
  const WideInboxHeader({required this.items, this.onAutoPlan, super.key});

  final List<Occurrence> items;

  /// Null while the week is loading.
  final VoidCallback? onAutoPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final work = inboxWork(items);
    // A Wrap: at large text the actions go under the title (M3f.9b).
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DotSpace.m,
      runSpacing: DotSpace.s,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.navInbox, style: t.styles.pageTitle),
            ),
            Text(
              l10n.inboxSummary(
                work.count,
                formatDurationShort(l10n, work.minutes),
              ),
              style: t.styles.body.copyWith(color: t.colors.muted),
            ),
          ],
        ),
        Wrap(
          spacing: DotSpace.m,
          runSpacing: DotSpace.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const InboxRoutinesButton(),
            const _SortButton(),
            FilledButton(
              onPressed: onAutoPlan,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DotSpace.s,
                children: [
                  Flexible(child: Text(l10n.inboxAutoPlan)),
                  _KeyHint(
                    AppShortcuts.label(
                      defaultTargetPlatform,
                      _key,
                      shift: true,
                    ),
                  ),
                ],
              ),
            ),
            CountRing(
              count: work.count,
              label: l10n.inboxRingLabel(work.count),
            ),
          ],
        ),
      ],
    );
  }
}

/// "Sort: duration" and its menu.
class _SortButton extends ConsumerWidget {
  const _SortButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final picked = ref.watch(inboxSortChoiceProvider);
    String name(InboxSort s) => switch (s) {
      InboxSort.added => l10n.inboxSortAdded,
      InboxSort.duration => l10n.inboxSortDuration,
      InboxSort.fit => l10n.inboxSortFit,
    };
    return MenuAnchor(
      style: dotMenuStyle(context),
      menuChildren: [
        for (final s in InboxSort.values)
          MenuItemButton(
            onPressed: () => ref.read(inboxSortChoiceProvider.notifier).pick(s),
            trailingIcon: s == picked
                ? DotIcon(DotGlyphs.check, color: t.colors.accentInk)
                : null,
            child: Text(name(s)),
          ),
      ],
      builder: (context, controller, _) => OutlinedButton.icon(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: DotIcon(
          DotGlyphs.sort,
          color: t.colors.text,
          size: DotSize.rowIcon,
        ),
        label: Text(l10n.inboxSortLabel(name(picked))),
      ),
    );
  }
}

/// "⇧⌘P" on a tinted chip inside a button.
class _KeyHint extends StatelessWidget {
  const _KeyHint(this.keys);

  final String keys;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final ink = DefaultTextStyle.of(context).style.color ?? t.colors.text;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ink.withValues(alpha: TaskAlpha.track),
          borderRadius: BorderRadius.circular(DotRadii.chipAndroid),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.s,
            vertical: DotSpace.xxs,
          ),
          child: Text(keys, style: t.styles.rowMeta.copyWith(color: ink)),
        ),
      ),
    );
  }
}
