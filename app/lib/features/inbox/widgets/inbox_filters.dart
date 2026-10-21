import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All / Under 30 min / Fits today (`A-android-inbox`; all platforms,
/// the doc wins over `A-ios-inbox`, which has none).
class InboxFilters extends ConsumerWidget {
  const InboxFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final picked = ref.watch(inboxFilterChoiceProvider);
    final labels = {
      InboxFilter.all: l10n.inboxFilterAll,
      InboxFilter.under30: l10n.inboxFilterUnder30,
      InboxFilter.fitsToday: l10n.inboxFilterFits,
    };
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        for (final MapEntry(key: f, value: label) in labels.entries)
          FilterChip(
            label: Text(label),
            selected: f == picked,
            shape: dotChipShape(context),
            onSelected: (_) =>
                ref.read(inboxFilterChoiceProvider.notifier).pick(f),
          ),
      ],
    );
  }
}

/// The open [items] [filter] keeps; "Fits today" needs [room] (none yet
/// = nothing fits).
List<Occurrence> filtered(
  Iterable<Occurrence> items,
  InboxFilter filter,
  DayRoom? room,
) => [
  for (final o in openItems(items))
    if (switch (filter) {
      InboxFilter.all => true,
      InboxFilter.under30 => o.durationMin < 30,
      InboxFilter.fitsToday =>
        room?.slotsFor(o.durationMin).isNotEmpty ?? false,
    })
      o,
];
