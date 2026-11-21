import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/inbox_sort.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The filters, then "Sort: added" at the row's end (E-R2-13). The
/// filters scroll sideways when they need the room, so Sort stays on
/// their line; with large text Sort goes under them.
class InboxFilterRow extends StatelessWidget {
  const InboxFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    const chips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: InboxFilters(),
    );
    if (MediaQuery.textScalerOf(context).scale(1) > DotSize.stackAbove) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          chips,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: InboxSortButton(),
          ),
        ],
      );
    }
    return const Row(
      spacing: DotSpace.s,
      children: [
        Expanded(child: chips),
        InboxSortButton(),
      ],
    );
  }
}

/// All / Under 30 min / Fits today (`A-android-inbox`; E-R2-13 draws All
/// and Fits today, and the owner kept Under 30 min, M20.2 part 1).
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
