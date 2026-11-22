import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/dot/mini_ring.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';

/// "LATER · 5 ○○○○○  Show what's later" (E-R2-22): the rest of today as
/// rings on one line; open, as rows with their times.
class LaterPile extends StatefulWidget {
  const LaterPile({required this.tasks, required this.time, super.key});

  final List<Occurrence> tasks;

  /// "2:00 PM" for a task's start.
  final String Function(Occurrence o) time;

  @override
  State<LaterPile> createState() => _LaterPileState();
}

class _LaterPileState extends State<LaterPile> {
  // Leaf view state (CLAUDE.md §4): whether the pile is open.
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final tasks = widget.tasks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _head(context, tasks),
        if (_open)
          for (final o in tasks)
            MergeSemantics(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: DotTouch.min),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
                  child: Row(
                    spacing: DotSpace.m,
                    children: [
                      MiniRing(
                        color: TaskColor.fromKey(o.colorKey),
                        size: DotSize.miniRing + DotSpace.xxs,
                      ),
                      Expanded(child: Text(o.title, style: t.styles.body)),
                      Text(widget.time(o), style: t.styles.rowMeta),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  /// "LATER · 5", the rings on one line (those past its end clipped, all
  /// still read out) and Show what's later at the end; where they don't
  /// fit (large text, a narrow window), a Wrap, so the button moves under
  /// the rings rather than overflowing.
  Widget _head(BuildContext context, List<Occurrence> tasks) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final labelText = l10n.lowEnergyLater(tasks.length).toUpperCase();
    final buttonText = _open
        ? l10n.lowEnergyHideLater
        : l10n.lowEnergyShowLater;
    final label = Text(labelText, style: t.styles.caption);
    final rings = [
      if (!_open)
        for (final o in tasks)
          Semantics(
            label: taskDotLabel(l10n, title: o.title, state: DotState.upcoming),
            child: MiniRing(color: TaskColor.fromKey(o.colorKey)),
          ),
    ];
    final button = TextButton(
      onPressed: () => setState(() => _open = !_open),
      child: Text(buttonText),
    );
    final base = DefaultTextStyle.of(context).style;
    final need =
        textWidth(context, labelText, base.merge(t.styles.caption)) +
        textWidth(context, buttonText, base.merge(t.styles.button)) +
        _chrome;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
      child: LayoutBuilder(
        builder: (context, box) => need <= box.maxWidth
            ? Row(
                spacing: DotSpace.s,
                children: [
                  label,
                  Expanded(
                    child: SizedBox(
                      height: DotSize.miniRing,
                      child: Wrap(
                        spacing: _gap,
                        clipBehavior: Clip.hardEdge,
                        children: rings,
                      ),
                    ),
                  ),
                  button,
                ],
              )
            : Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    spacing: _gap,
                    runSpacing: DotSpace.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [label, ...rings],
                  ),
                  button,
                ],
              ),
      ),
    );
  }

  static const _gap = DotSpace.xs + DotSpace.xxs;

  /// The button's padding, the row's gaps and room for three rings.
  static const _chrome =
      2 * DotSpace.l + 2 * DotSpace.s + 3 * (DotSize.miniRing + _gap);
}

/// "Move everything optional to tomorrow?  Propose" on the accent's tint,
/// offered once a day (E-R2-22).
class ProposeTomorrowCard extends StatelessWidget {
  const ProposeTomorrowCard({required this.onPropose, super.key});

  final VoidCallback onPropose;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.accentTint,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.m,
          DotSpace.s,
          DotSpace.s,
          DotSpace.s,
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: DotSpace.m,
          runSpacing: DotSpace.s,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _textMax),
              child: Text(
                l10n.lowEnergyPropose,
                style: t.styles.body.copyWith(
                  color: c.accentInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: onPropose,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(c.raised),
                foregroundColor: WidgetStatePropertyAll(c.accentInk),
                textStyle: WidgetStatePropertyAll(t.styles.button),
                minimumSize: const WidgetStatePropertyAll(
                  Size(0, DotTouch.min),
                ),
              ),
              child: Text(l10n.lowEnergyProposeAction),
            ),
          ],
        ),
      ),
    );
  }

  /// The question keeps two lines on a phone, as drawn.
  static const _textMax = DotSize.lowEnergyRing * 2.2;
}

/// "🔕 Nudges are off until tomorrow's Wake Up".
class NudgesOffLine extends StatelessWidget {
  const NudgesOffLine({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: DotSpace.s,
      children: [
        DotIcon(
          DotGlyphs.bellOff,
          color: t.colors.muted,
          size: DotSize.miniRing + DotSpace.xxs,
        ),
        Flexible(
          child: Text(
            context.l10n.lowEnergyNudgesOff,
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
        ),
      ],
    );
  }
}
