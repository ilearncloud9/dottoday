import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Sort: added" at the end of the filter row, and its menu (E-R2-13).
class InboxSortButton extends ConsumerWidget {
  const InboxSortButton({super.key});

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
      builder: (context, controller, _) => TextButton(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        style: TextButton.styleFrom(foregroundColor: t.colors.muted),
        child: Text(l10n.inboxSortLabel(name(picked))),
      ),
    );
  }
}
