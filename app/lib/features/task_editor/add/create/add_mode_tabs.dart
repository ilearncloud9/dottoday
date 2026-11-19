import 'package:dottoday/core/editing/add_modes.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Task · Brain dump · Routine: the native control on each platform.
class AddModeTabs extends StatelessWidget {
  const AddModeTabs({
    required this.mode,
    required this.onMode,
    this.popover = false,
    this.touch = true,
    super.key,
  });

  final AddMode mode;
  final ValueChanged<AddMode> onMode;

  /// The Mac and web popover's tabs (E-R2-36): the sliding control on
  /// both, at the Workspace's tab size (28 tall, 12/500).
  final bool popover;

  /// Touch-sized segments (48, the floor every touch target meets); the
  /// popover's pointer tabs are 28 (E-R2-36).
  final bool touch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      AddMode.task: l10n.createTabTask,
      AddMode.brainDump: l10n.dumpTitle,
      AddMode.routine: l10n.routineDropTitle,
    };
    if (!popover && DotIdiom.of(context) == DotIdiom.material) {
      return SegmentedButton<AddMode>(
        segments: [
          for (final m in AddMode.values)
            ButtonSegment(value: m, label: Text(labels[m]!)),
        ],
        selected: {mode},
        onSelectionChanged: (s) => onMode(s.first),
      );
    }
    final children = {
      for (final m in AddMode.values)
        m: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: touch ? DotTouch.android : DotSize.popoverPill,
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              labels[m]!,
              style: popover ? DotTheme.of(context).styles.viewTab : null,
            ),
          ),
        ),
    };
    void pick(AddMode? m) {
      if (m != null) onMode(m);
    }

    if (!popover) {
      return CupertinoSlidingSegmentedControl<AddMode>(
        groupValue: mode,
        onValueChanged: pick,
        children: children,
      );
    }
    // The popover's track and raised tab as drawn (E-R2-36); they keep the
    // label's contrast in dark too. The phones keep iOS's own.
    final c = DotTheme.of(context).colors;
    return CupertinoSlidingSegmentedControl<AddMode>(
      groupValue: mode,
      backgroundColor: c.chip,
      thumbColor: c.raised,
      onValueChanged: pick,
      children: children,
    );
  }
}
