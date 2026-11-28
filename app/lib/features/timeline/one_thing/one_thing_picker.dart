import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_state.dart';
import 'package:dottoday/shared/dot/mini_ring.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';

/// The pick screen of today's one thing (docs/15 §8, E-R2-34): "Every
/// answer is right.", then today's dots and the Inbox, each one tap. There
/// is no confirm and no wrong pick; the current one wears the ring and a
/// tint. The question above it is the caller's: the sheet's heading
/// (`showOneThingSheet`) or the mission's own line.
class OneThingPicker extends StatelessWidget {
  const OneThingPicker({required this.offer, required this.onPick, super.key});

  final OneThingOffer offer;
  final ValueChanged<Occurrence> onPick;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.oneThingEveryAnswer,
          style: t.styles.body.copyWith(color: t.colors.secondary),
        ),
        if (offer.dots.isNotEmpty) ...[
          _Caption(l10n.oneThingToday),
          for (final o in offer.dots) _row(context, o),
        ],
        if (offer.inbox.isNotEmpty) ...[
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

/// "TODAY" or "INBOX" over its choices.
class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(
      DotSpace.xs,
      DotSpace.m + DotSpace.xxs,
      DotSpace.xs,
      DotSpace.xs,
    ),
    child: Semantics(
      header: true,
      child: Text(text, style: DotTheme.of(context).styles.caption),
    ),
  );
}

/// One choice: its ring, title and time (or length, from the Inbox); the
/// pick tinted, its ring haloed and "· Your one thing" in accent ink.
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
    const shape = BorderRadius.all(Radius.circular(DotRadii.choice));
    return Semantics(
      button: true,
      selected: picked,
      label: picked ? l10n.rowOneThing(label) : label,
      excludeSemantics: true,
      child: Material(
        color: picked ? t.colors.selectedRow : Colors.transparent,
        borderRadius: shape,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotSize.pickRow),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.m,
                vertical: DotSpace.xs + DotSpace.xxs,
              ),
              child: Row(
                spacing: DotSpace.m + DotSpace.xxs,
                children: [
                  MiniRing(
                    color: TaskColor.fromKey(o.colorKey),
                    size: DotSize.pickRing,
                    stroke: DotSize.pickRingStroke,
                    halo: picked,
                  ),
                  Expanded(child: _texts(t, l10n, o)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _texts(DotTheme t, AppLocalizations l10n, Occurrence o) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(o.title, style: t.styles.rowTitle),
      Text(
        picked ? l10n.oneThingMetaJoin(meta) : meta,
        style: picked
            ? t.styles.rowMeta.copyWith(color: t.colors.accentText)
            : t.styles.rowMeta,
      ),
    ],
  );
}
