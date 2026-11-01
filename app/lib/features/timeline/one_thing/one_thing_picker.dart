import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_state.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';

/// The pick screen of today's one thing (docs/15 §8): today's dots, then
/// the Inbox, each one tap. Every answer is right, so there is no confirm
/// and no wrong pick; the current one wears the ring. The mission and
/// Today's ⋯ share it.
class OneThingPicker extends StatelessWidget {
  const OneThingPicker({
    required this.offer,
    required this.onPick,
    this.header = true,
    super.key,
  });

  final OneThingOffer offer;
  final ValueChanged<Occurrence> onPick;

  /// "What matters most today?" and "Every answer is right." on top; off
  /// where the mission's own line says it.
  final bool header;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header) ...[
          Text(l10n.oneThingAsk, style: t.styles.cardTitle),
          const SizedBox(height: DotSpace.xs),
        ],
        Text(
          l10n.oneThingEveryAnswer,
          style: t.styles.body.copyWith(color: t.colors.muted),
        ),
        const SizedBox(height: DotSpace.l),
        if (offer.dots.isNotEmpty) ...[
          _Caption(l10n.oneThingToday),
          for (final o in offer.dots) _row(context, o),
        ],
        if (offer.inbox.isNotEmpty) ...[
          const SizedBox(height: DotSpace.m),
          _Caption(l10n.oneThingInbox),
          for (final o in offer.inbox) _row(context, o),
        ],
      ],
    );
  }

  Widget _row(BuildContext context, Occurrence o) {
    final l10n = context.l10n;
    final start = o.startUtc;
    final meta = start == null
        ? formatDurationShort(l10n, o.durationMin)
        : l10n.threadTimeRange(
            _time(context, start),
            _time(context, o.endUtc!),
          );
    return _PickRow(
      occurrence: o,
      meta: meta,
      picked: o.id == offer.pickedId,
      onTap: () => onPick(o),
    );
  }

  String _time(BuildContext context, DateTime utc) => timeOfUtc(
    context,
    offer.location,
    utc,
    use24h: use24hFor(context, offer.use24h),
  );
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: DotSpace.xs),
    child: Semantics(
      header: true,
      child: Text(text, style: DotTheme.of(context).styles.caption),
    ),
  );
}

/// One choice: its dot, title and time (or length, from the Inbox).
class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.occurrence,
    required this.meta,
    required this.picked,
    required this.onTap,
  });

  final Occurrence occurrence;
  final String meta;
  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final o = occurrence;
    final label = l10n.rowLabel(o.title, meta);
    return Semantics(
      button: true,
      selected: picked,
      label: picked ? l10n.rowOneThing(label) : label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
            child: Row(
              spacing: DotSpace.m,
              children: [
                TaskDot(
                  color: TaskColor.fromKey(o.colorKey),
                  icon: TaskIcon.fromKey(o.iconKey),
                  state: DotState.upcoming,
                  label: o.title,
                  oneThing: picked,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.title, style: t.styles.rowTitle),
                      Text(
                        picked ? l10n.oneThingMetaJoin(meta) : meta,
                        style: t.styles.rowMeta,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
