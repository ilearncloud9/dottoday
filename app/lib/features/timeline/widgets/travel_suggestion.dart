import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/travel_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/calendar/travel_time.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/travel_dismissed.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In an imported event's sheet: "At Main St 4. Keep 15 min before it for
/// getting there?" with Add / Not now (docs/02 F5, docs/09 M7.5, R-17).
/// The suggestion is rule-made ([travelSuggestion]), so nothing is written
/// until Add (CLAUDE.md §11 proposal rule; a one-change confirm until
/// `ProposalSheet` lands in M10.2). Add is undoable.
class TravelSuggestionCard extends ConsumerWidget {
  const TravelSuggestionCard({required this.task, super.key});

  final TaskView task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = task.occurrence;
    final linkId = o.calendarLinkId;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (linkId == null || settings == null) return const SizedBox.shrink();
    if (ref.watch(dismissedTravelProvider).contains(o.id)) {
      return const SizedBox.shrink();
    }
    final location = ref.watch(calendarEventLocationProvider(linkId)).value;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final minutes = travelSuggestion(
      o,
      location: location,
      settings: settings,
      nowUtc: now,
    );
    if (minutes == null || location == null) return const SizedBox.shrink();
    return _Card(
      detail: context.l10n.travelSuggestDetail(
        location,
        formatDurationShort(context.l10n, minutes),
      ),
      minutes: minutes,
      onAdd: () => _add(context, ref, minutes),
      onNotNow: () => ref.read(dismissedTravelProvider.notifier).dismiss(o.id),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, int minutes) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    final o = task.occurrence;
    reportUndoable(
      messenger,
      l10n,
      undo,
      await setTravelTime(ref, o, minutes),
      message: (_) => l10n.travelAdded(o.title),
      tokenOf: (token) => token,
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.detail,
    required this.minutes,
    required this.onAdd,
    required this.onNotNow,
  });

  final String detail;
  final int minutes;
  final VoidCallback onAdd;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: DotSpace.l),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.raised,
          borderRadius: BorderRadius.circular(DotRadii.card),
          border: Border.all(color: t.colors.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.l),
          child: Semantics(
            container: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DotSpace.s,
              children: [
                Row(
                  spacing: DotSpace.s,
                  children: [
                    DotIcon(
                      TaskIcon.car.glyph ?? DotGlyphs.clock,
                      color: t.colors.muted,
                      size: DotSize.rowIcon,
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.travelTitle.toUpperCase(),
                        style: t.styles.caption,
                      ),
                    ),
                  ],
                ),
                Text(detail, style: t.styles.body),
                Wrap(
                  spacing: DotSpace.s,
                  children: [
                    FilledButton(
                      onPressed: onAdd,
                      child: Text(
                        l10n.travelSuggestAdd(
                          formatDurationShort(l10n, minutes),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onNotNow,
                      child: Text(l10n.promptNotNow),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
