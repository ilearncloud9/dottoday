import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/day_column_prefs.dart';
import 'package:dottoday/features/timeline/now/now_inputs.dart';
import 'package:dottoday/features/timeline/now/wide/day_column.dart';
import 'package:dottoday/features/timeline/now/wide/day_edge.dart';
import 'package:dottoday/features/timeline/now/wide/now_pane.dart';
import 'package:dottoday/features/timeline/now/wide/now_toolbar.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal's Now on the Mac and the web (E-Minimal frames 1 and 2,
/// ED-068, ED-232; M19.6 part 6c): the Now pane takes the room the
/// sidebar and the 290 Day column leave. The Mac adds its toolbar over
/// both; the web puts the date in the pane. Only the chrome differs.
///
/// Narrow windows (ED-170, part 6e-1): when the pane's minimum and the
/// column don't both fit (≈ 1042 at 100 % text, more at larger text) the
/// column folds behind a 44 "Day" edge button that opens it as a panel
/// over Now, not modal and not dimmed; Esc, ✕ or the button close it and
/// focus goes back to the button. Resizing changes nothing else.
class NowWide extends ConsumerStatefulWidget {
  const NowWide({super.key});

  @override
  ConsumerState<NowWide> createState() => _NowWideState();
}

/// A leaf: only whether the folded column's panel is open.
class _NowWideState extends ConsumerState<NowWide> {
  bool _open = false;
  final _edge = FocusNode();

  @override
  void dispose() {
    _edge.dispose();
    super.dispose();
  }

  /// Opens or closes the panel; the button keeps the focus, so Esc
  /// works from it and focus is where closing returns it (ED-170).
  void _toggle() {
    setState(() => _open = !_open);
    _edge.requestFocus();
  }

  void _close() {
    setState(() => _open = false);
    ref.read(editingTaskProvider.notifier).close();
    ref.read(reviewBesideProvider.notifier).close();
    _edge.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final n = NowInputs.watch(context, ref);
    if (n == null) return const Scaffold();
    // The apps' chrome (the Mac, iPad, Android tablets: E-Minimal 1,
    // E-R2-1 2a, 4a); the web keeps the date in the pane (frame 2).
    final app = !webChrome(context);
    // A task or the review opened here brings the column out (ED-089,
    // ED-099), even when the person put the Day away.
    final editing =
        ref.watch(editingTaskProvider) != null ||
        ref.watch(reviewBesideProvider) != null;
    // A task opened from the pane (Open on a dot) brings the column out
    // for it, even when the person put the Day away (ED-089).
    final hidden =
        (ref.watch(dayColumnHiddenProvider).value ?? false) && !editing;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (app) NowToolbar(inputs: n),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final folds =
                    box.maxWidth <
                    DotSize.nowPaneMin * scale +
                        DotSize.dayColumn +
                        DotSpace.hairline;
                if (!folds) {
                  // Tab finishes the pane, then the Day column (ED-248 A,
                  // E-DF3); without groups it went row by row across both.
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: FocusTraversalGroup(
                          child: NowPane(
                            inputs: n,
                            app: app,
                            dayHidden: hidden,
                          ),
                        ),
                      ),
                      if (!hidden)
                        FocusTraversalGroup(child: DayColumn(today: n.today)),
                    ],
                  );
                }
                final open = _open || editing;
                // Esc closes the panel from the button or from inside it.
                return CallbackShortcuts(
                  bindings: {
                    if (open)
                      const SingleActivator(LogicalKeyboardKey.escape): _close,
                  },
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: FocusTraversalGroup(
                              child: NowPane(
                                inputs: n,
                                app: app,
                                dayHidden: !open,
                                onDayRow: _toggle,
                              ),
                            ),
                          ),
                          DayEdge(open: open, focusNode: _edge, onTap: _toggle),
                        ],
                      ),
                      if (open)
                        PositionedDirectional(
                          top: 0,
                          bottom: 0,
                          end: DotSize.dayEdge,
                          // Over Now, not modal and not dimmed (ED-170).
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              boxShadow: DotElevation.floating,
                            ),
                            child: FocusTraversalGroup(
                              child: DayColumn(today: n.today, onClose: _close),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
