import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// The moving now (ED-246 B, owner's option A for fixed rows, ED-364).
///
/// Rows have fixed heights (ED-363), so the bead moves only when a task
/// starts or ends and the bead lands in another row. Then its old row
/// closes and its new one opens, [DotMotion.base] ease-out; under Reduce
/// Motion they jump. A hop seen only after the app was away (no build for
/// [_awake]) jumps too: no catch-up animation.
///
/// It also says the new current task once, politely, when the live task
/// changes; focus never moves.
final class BeadHops {
  /// Longer than a minute tick: an older last build means the app was in
  /// the background.
  static const _awake = Duration(seconds: 90);

  final _since = Stopwatch()..start();

  /// Bumped on each animated hop, so the new bead row is a new element.
  int _hop = 0;

  /// Where the departing row shows in the new entries, while it closes.
  int? closingAt;

  /// The thread colour through the departing row.
  TaskColor? closingSolid;

  /// Compares the entries before and after an update; call from
  /// `didUpdateWidget`.
  void update(
    BuildContext context,
    List<ThreadEntry> before,
    List<ThreadEntry> after,
  ) {
    final awake = _since.elapsed < _awake;
    _since.reset();
    if (!awake) return;
    _announce(context, before, after);
    final from = before.indexWhere((e) => e is ThreadNow);
    final to = after.indexWhere((e) => e is ThreadNow);
    if (from < 0 || to < 0 || from == to) return;
    if (DotTheme.of(context).motion.isReduced) return;
    _hop++;
    closingAt = from.clamp(0, after.length);
    closingSolid = threadSolid(before)[from];
  }

  /// Marks a build, so a later update knows the app was awake.
  void built() => _since.reset();

  /// The bead's row, opening on a fresh hop.
  Widget arriving(Widget row) =>
      BeadRow(key: ValueKey(('bead', _hop)), opening: _hop > 0, child: row);

  /// The departing row, closing; [onDone] drops it.
  Widget departing(VoidCallback onDone) => BeadRow(
    key: ValueKey(('gone', _hop)),
    closing: true,
    onDone: onDone,
    child: _Trace(solid: closingSolid),
  );

  void _announce(
    BuildContext context,
    List<ThreadEntry> before,
    List<ThreadEntry> after,
  ) {
    final was = _live(before);
    final now = _live(after);
    if (now == null || now.id == was?.id) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        context.l10n.threadNowTask(now.title),
        Directionality.of(context),
      ),
    );
  }

  static ThreadTask? _live(List<ThreadEntry> entries) =>
      threadTasks(entries).where((t) => t.state == DotState.live).firstOrNull;
}

/// A bead row that opens from nothing or closes to nothing once, over
/// [DotMotion.base]; otherwise it just shows [child].
class BeadRow extends StatefulWidget {
  const BeadRow({
    required this.child,
    this.opening = false,
    this.closing = false,
    this.onDone,
    super.key,
  });

  final Widget child;
  final bool opening;
  final bool closing;
  final VoidCallback? onDone;

  @override
  State<BeadRow> createState() => _BeadRowState();
}

class _BeadRowState extends State<BeadRow> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    value: widget.opening ? 0 : 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = DotTheme.of(context).motion;
    _c.duration = motion.base;
    if (_c.isAnimating) return;
    if (widget.opening && _c.value == 0) {
      unawaited(_c.forward());
    } else if (widget.closing && _c.value == 1) {
      unawaited(_c.reverse().whenComplete(() => widget.onDone?.call()));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.opening && !widget.closing) return widget.child;
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _c,
        curve: DotTheme.of(context).motion.curve,
      ),
      child: widget.child,
    );
  }
}

/// The thread through the departing row, so the line stays whole while it
/// closes.
class _Trace extends StatelessWidget {
  const _Trace({this.solid});

  final TaskColor? solid;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ThreadRowFrame(
      minHeight: DotSize.threadRowNow,
      piece: FreePiece(
        color: switch (solid) {
          final s? => t.tasks[s].color,
          null => null,
        },
      ),
      child: const SizedBox.shrink(),
    );
  }
}
