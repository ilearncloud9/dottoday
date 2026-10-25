import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/dot/focus_ring.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';

/// A raised low-energy card (`B-ios-low-energy`).
class LowEnergyCard extends StatelessWidget {
  const LowEnergyCard({required this.child, this.dashed = false, super.key});

  final Widget child;

  /// The quiet "Move everything optional…" card: no fill, a dashed edge.
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dashed ? null : t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(
          color: dashed ? t.colors.outline : t.colors.hairline,
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(DotSpace.l), child: child),
    );
  }
}

/// The one dot to look at: its ring (filling while it runs), title, "until
/// 11:00 · 38 min left" or "at 2:00 PM", Done and Not today.
class NextDotCard extends StatelessWidget {
  const NextDotCard({
    required this.task,
    required this.progress,
    required this.when,
    required this.onDone,
    required this.onNotToday,
    super.key,
  });

  final Occurrence task;

  /// Share of its planned time gone; 0 before it starts.
  final double progress;
  final String when;
  final VoidCallback onDone;
  final VoidCallback onNotToday;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return LowEnergyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.m,
        children: [
          Center(
            child: FocusRing(
              progress: progress,
              color: TaskColor.fromKey(task.colorKey),
              icon: TaskIcon.fromKey(task.iconKey),
            ),
          ),
          Text(
            task.title,
            textAlign: TextAlign.center,
            style: t.styles.pageTitle,
          ),
          Text(
            when,
            textAlign: TextAlign.center,
            style: t.styles.body.copyWith(color: t.colors.muted),
          ),
          FilledButton(onPressed: onDone, child: Text(l10n.liveDone)),
          TextButton(
            onPressed: onNotToday,
            child: Text(l10n.lowEnergyNotToday),
          ),
        ],
      ),
    );
  }
}

/// "LATER · 5": the rest of today as dots; open, as rows with times.
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
    final l10n = context.l10n;
    const upcoming = DotState.upcoming;
    return LowEnergyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.lowEnergyLater(widget.tasks.length).toUpperCase(),
                  style: t.styles.caption,
                ),
              ),
              IconButton(
                tooltip: _open
                    ? l10n.lowEnergyHideLater
                    : l10n.lowEnergyShowLater,
                onPressed: () => setState(() => _open = !_open),
                icon: DotIcon(
                  _open ? DotGlyphs.chevronUp : DotGlyphs.chevronDown,
                  color: t.colors.muted,
                  size: DotSize.rowIcon,
                ),
              ),
            ],
          ),
          if (!_open)
            Wrap(
              spacing: DotSpace.s,
              runSpacing: DotSpace.s,
              children: [
                for (final o in widget.tasks)
                  TaskDot(
                    color: TaskColor.fromKey(o.colorKey),
                    icon: TaskIcon.fromKey(o.iconKey),
                    state: upcoming,
                    label: taskDotLabel(l10n, title: o.title, state: upcoming),
                  ),
              ],
            )
          else
            for (final o in widget.tasks)
              MergeSemantics(
                child: Row(
                  spacing: DotSpace.m,
                  children: [
                    TaskDot(
                      color: TaskColor.fromKey(o.colorKey),
                      icon: TaskIcon.fromKey(o.iconKey),
                      state: upcoming,
                      label: taskDotLabel(
                        l10n,
                        title: o.title,
                        state: upcoming,
                      ),
                      size: DotSize.macRowDot,
                    ),
                    Expanded(child: Text(o.title, style: t.styles.rowTitle)),
                    Text(widget.time(o), style: t.styles.rowMeta),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// "Move everything optional to tomorrow?  Propose" (offered once a day).
class ProposeTomorrowCard extends StatelessWidget {
  const ProposeTomorrowCard({required this.onPropose, super.key});

  final VoidCallback onPropose;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return LowEnergyCard(
      dashed: true,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DotSpace.m,
        runSpacing: DotSpace.s,
        children: [
          Text(l10n.lowEnergyPropose, style: t.styles.body),
          FilledButton(
            onPressed: onPropose,
            child: Text(l10n.lowEnergyProposeAction),
          ),
        ],
      ),
    );
  }
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
          size: DotSize.rowIcon,
        ),
        Flexible(
          child: Text(context.l10n.lowEnergyNudgesOff, style: t.styles.rowMeta),
        ),
      ],
    );
  }
}

/// "Low-energy · on ⬤" in the Today header (`B-ios-low-energy`): one tap
/// turns the mode off.
class LowEnergySwitch extends StatelessWidget {
  const LowEnergySwitch({required this.onChanged, super.key});

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.pill),
        border: Border.all(color: t.colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: DotSpace.m),
        child: MergeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.lowEnergyOn, style: t.styles.rowMeta),
              Switch.adaptive(
                value: true,
                activeTrackColor: t.colors.accent,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
