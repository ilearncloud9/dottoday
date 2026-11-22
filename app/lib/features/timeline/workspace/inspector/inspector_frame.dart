import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/features/timeline/review/review_panel.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_write.dart';
import 'package:dottoday/features/timeline/workspace/inspector/workspace_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Workspace's Day, 3 days or Week [child] with the inspector at its
/// end edge while a task is picked (ED-170 C1, owner 2026-11-19): docked
/// from 1160 when the grid keeps 3 days, else a card over the grid. Away
/// while nothing is picked, while the person hid it (⌥⌘I) and while the
/// full editor has the task (it takes the inspector's place). Esc puts
/// it away.
///
/// On an iPad or Android tablet it also holds the review as a 420 pane
/// beside the day (ED-297, E-R2-14), in the inspector's place while open;
/// it docks as a side panel does (ED-167) and floats over the grid where
/// the days left would be too narrow.
///
/// Both ways use the same tree, so a resize keeps what is typed in it.
class InspectorFrame extends ConsumerStatefulWidget {
  const InspectorFrame({
    required this.child,
    required this.inspects,
    super.key,
  });

  final Widget child;

  /// Whether this view picks into the inspector (not Month).
  final bool inspects;

  @override
  ConsumerState<InspectorFrame> createState() => _InspectorFrameState();
}

/// A leaf: the focus that lets Esc reach the frame after a click.
class _InspectorFrameState extends ConsumerState<InspectorFrame> {
  final _focus = FocusNode(debugLabel: 'inspector'); // l10n-ignore: debug

  @override
  void initState() {
    super.initState();
    if (widget.inspects) InspectorFrames.mounted();
  }

  @override
  void didUpdateWidget(covariant InspectorFrame old) {
    super.didUpdateWidget(old);
    if (old.inspects == widget.inspects) return;
    widget.inspects ? InspectorFrames.mounted() : InspectorFrames.unmounted();
  }

  @override
  void dispose() {
    if (widget.inspects) InspectorFrames.unmounted();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A click doesn't move focus: bring it inside, so Esc and Tab work on
    // what was just picked.
    ref.listen(inspectedTaskProvider, (_, next) {
      if (next != null && !_focus.hasFocus) _focus.requestFocus();
    });
    final inspects = widget.inspects;
    final id = ref.watch(inspectedTaskProvider);
    final hidden = ref.watch(inspectorHiddenProvider);
    final editing = ref.watch(editingTaskProvider) != null;
    final touch = watchTouchContent(context, ref);
    final review = touch ? ref.watch(reviewBesideProvider) : null;
    final reviewing = inspects && review != null && !editing;
    final shown = inspects && id != null && !hidden && !editing && !reviewing;
    void closeReview() => ref.read(reviewBesideProvider.notifier).close();
    // One tree whether it shows or not: the grid keeps its scroll.
    return CallbackShortcuts(
      bindings: {
        if (shown)
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              ref.read(inspectedTaskProvider.notifier).close(),
        if (reviewing)
          const SingleActivator(LogicalKeyboardKey.escape): closeReview,
      },
      child: Focus(
        focusNode: _focus,
        child: LayoutBuilder(
          builder: (context, box) => reviewing
              ? _layout(
                  context,
                  width: DotSize.sidePanel,
                  docked: AppLayout.docks(context, available: box.maxWidth),
                  panel: Padding(
                    padding: const EdgeInsets.all(DotSpace.l),
                    child: ReviewPanel(
                      key: ValueKey(review),
                      day: review.day,
                      page: review.page,
                      onClose: closeReview,
                    ),
                  ),
                )
              : _layout(
                  context,
                  docked:
                      shown &&
                      inspectorDocks(
                        context,
                        available: box.maxWidth,
                        touch: touch,
                      ),
                  panel: shown
                      ? WorkspaceInspector(key: ValueKey(id), id: id)
                      : null,
                ),
        ),
      ),
    );
  }

  Widget _layout(
    BuildContext context, {
    required bool docked,
    required Widget? panel,
    double width = DotSize.inspector,
  }) {
    final c = DotTheme.of(context).colors;
    final inset = docked ? 0.0 : DotSpace.s;
    return Stack(
      children: [
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          end: docked ? width + DotSpace.hairline : 0,
          child: widget.child,
        ),
        if (panel != null)
          PositionedDirectional(
            top: inset,
            bottom: inset,
            end: inset,
            width: docked ? width + DotSpace.hairline : width,
            child: DecoratedBox(
              // Docked, a hairline divides it from the grid; floating, it
              // is a card over the grid (rules §7.3 inspector look).
              decoration: BoxDecoration(
                color: c.sunk,
                borderRadius: docked
                    ? null
                    : BorderRadius.circular(DotRadii.block),
                border: docked
                    ? BorderDirectional(start: BorderSide(color: c.outline))
                    : Border.all(color: c.outline),
                boxShadow: docked ? null : DotElevation.floating,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: docked ? DotSpace.hairline : 0,
                ),
                child: ClipRRect(
                  borderRadius: docked
                      ? BorderRadius.zero
                      : BorderRadius.circular(DotRadii.block),
                  child: Material(
                    type: MaterialType.transparency,
                    child: panel,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
