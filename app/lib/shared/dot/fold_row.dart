import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The Earlier fold component (ED-164, ED-246): one quiet 48 px row on the
/// thread, up to three overlapping dots in the tasks' colours, the [label]
/// in the secondary colour and "Show ⌄" / "Hide ⌃" in the accent ink.
///
/// It is a button that says whether it is expanded. Tab reaches it, Space
/// or Return toggles, → opens and ← closes (E-R2-39).
class FoldRow extends StatelessWidget {
  const FoldRow({
    required this.label,
    required this.spoken,
    required this.dots,
    required this.open,
    required this.onToggle,
    this.piece = const BlankPiece(),
    super.key,
  });

  final String label;

  /// The screen reader's name: "Earlier, done tasks".
  final String spoken;

  /// The dots in the axis column; empty draws none.
  final List<Color> dots;
  final bool open;
  final ValueChanged<bool> onToggle;

  /// The thread through the row.
  final AxisPiece piece;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    // 700 13 in the accent ink (E-Earlier).
    final action = DotType.emphasis(
      t.styles.threadMeta.copyWith(color: t.colors.accentInk),
      bold: true,
      italic: false,
    );
    void toggle() => onToggle(!open);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          if (!open) onToggle(true);
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          if (open) onToggle(false);
        },
      },
      child: Semantics(
        button: true,
        expanded: open,
        label: spoken,
        onTap: toggle,
        excludeSemantics: true,
        child: InkWell(
          onTap: toggle,
          borderRadius: BorderRadius.circular(DotRadii.card),
          child: ThreadRowFrame(
            minHeight: DotSize.foldRow,
            piece: piece,
            dot: dots.isEmpty ? null : FoldDots(colors: dots),
            trailing: Padding(
              padding: const EdgeInsetsDirectional.only(end: DotSpace.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    open ? l10n.threadFoldHide : l10n.threadFoldShow,
                    style: action,
                  ),
                  const SizedBox(width: DotSpace.xxs),
                  DotIcon(
                    open ? DotGlyphs.chevronUp : DotGlyphs.chevronDown,
                    color: t.colors.accentInk,
                    size: DotSize.rowIcon,
                  ),
                ],
              ),
            ),
            child: Text(label, style: t.styles.dayCaption),
          ),
        ),
      ),
    );
  }
}

/// Up to three 24 px dots, each half over the one before, ringed in the
/// page colour so they read apart (E-Earlier).
class FoldDots extends StatelessWidget {
  const FoldDots({required this.colors, super.key});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final ground = DotTheme.of(context).colors.ground;
    final width = DotSize.foldDot + DotSize.foldDotStep * (colors.length - 1);
    return SizedBox(
      width: width,
      height: DotSize.foldDot,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final (i, color) in colors.indexed)
            PositionedDirectional(
              start: DotSize.foldDotStep * i,
              child: Container(
                width: DotSize.foldDot,
                height: DotSize.foldDot,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ground,
                    width: DotSize.foldDotRing,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The Earlier fold's row (ED-164): "Earlier" with the folded tasks' dots;
/// open, no dots, and the thread runs through it into the first done task.
class EarlierRow extends StatelessWidget {
  const EarlierRow({required this.earlier, this.onToggle, super.key});

  final ThreadEarlier earlier;

  /// The caller keeps the choice and re-folds the entries.
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final e = earlier;
    Color c(TaskColor color) => t.tasks[color].color;
    return FoldRow(
      label: l10n.threadEarlier,
      spoken: l10n.threadEarlierLabel,
      dots: e.open ? const [] : [for (final d in e.dots) c(d)],
      open: e.open,
      onToggle: onToggle ?? (_) {},
      piece: e.open
          ? FreePiece(color: c(e.first))
          : CapPiece(below: true, color: c(e.last)),
    );
  }
}
