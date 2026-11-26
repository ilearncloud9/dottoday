import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/first_today/first_today_hint.dart';
import 'package:dottoday/features/timeline/first_today/first_today_rise.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the first Today after onboarding adds to today's thread (ED-490):
/// the rows rising in, and the task the hint points at.
typedef FirstTodayLook = ({
  Widget Function(int index, Widget child)? arrive,
  ({String id, LayerLink link})? doneLink,
});

/// The first Today's look for today's [blocks] at [now], or null: another
/// day, Minimal (docs/14 §3), or nothing left to show.
FirstTodayLook? watchFirstToday(
  WidgetRef ref, {
  required bool today,
  required List<Occurrence> blocks,
  required DateTime now,
}) {
  if (!today || !watchOnScreen(ref, FeatureId.firstToday)) return null;
  final state = ref.watch(firstTodayProvider).value;
  if (state == null || !(state.rise || state.hint)) return null;
  final target = state.hint ? firstTodayHintTarget(blocks, now) : null;
  return (
    arrive: state.rise
        ? (i, child) =>
              FirstTodayRise(delay: firstTodayRowDelay(i), child: child)
        : null,
    doneLink: target == null
        ? null
        : (id: target, link: ref.watch(firstTodayLinkProvider)),
  );
}

/// The task the hint points at (the prototype's subject): the first not
/// done after [now], else the first not done; never a calendar event,
/// which has no done circle. Null when there is none.
///
/// ```dart
/// firstTodayHintTarget([run7, read2130], nineAm); // read2130's id
/// ```
String? firstTodayHintTarget(List<Occurrence> blocks, DateTime now) {
  final open = [
    for (final o in blocks)
      if (o.status != OccurrenceStatus.done &&
          o.source != OccurrenceSource.calendar &&
          o.startUtc != null)
        o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  if (open.isEmpty) return null;
  return (open.where((o) => o.startUtc!.isAfter(now)).firstOrNull ?? open.first)
      .id;
}

/// Today's day with the first Today around it: the hint over it (until
/// the first tap anywhere on it, which ends the hint for good), and the
/// rise marked done once the last of [rows] has risen.
class FirstTodayLayer extends ConsumerStatefulWidget {
  const FirstTodayLayer({
    required this.look,
    required this.rows,
    required this.child,
    super.key,
  });

  final FirstTodayLook look;
  final int rows;
  final Widget child;

  @override
  ConsumerState<FirstTodayLayer> createState() => _FirstTodayLayerState();
}

/// A leaf: the rise's timer and whether the hint is leaving.
class _FirstTodayLayerState extends ConsumerState<FirstTodayLayer> {
  Timer? _risen;
  var _gone = false;

  @override
  void initState() {
    super.initState();
    // A tap anywhere on the screen, not only on the day (`.screen`).
    GestureBinding.instance.pointerRouter.addGlobalRoute(_route);
    if (widget.look.arrive == null) return;
    _risen = Timer(
      firstTodayRowDelay(widget.rows) + OnbMotion.arrive,
      () => unawaited(ref.read(firstTodayProvider.notifier).risen()),
    );
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_route);
    _risen?.cancel();
    super.dispose();
  }

  void _route(PointerEvent e) {
    if (e is PointerDownEvent) _tap();
  }

  /// The first tap anywhere: the hint leaves (400 ms) and never returns.
  void _tap() {
    if (_gone || widget.look.doneLink == null || !mounted) return;
    setState(() => _gone = true);
    Future<void>.delayed(OnbMotion.hintLeave, () {
      unawaited(ref.read(firstTodayProvider.notifier).hintDone());
    }).ignore();
  }

  @override
  Widget build(BuildContext context) {
    final link = widget.look.doneLink?.link;
    if (link == null) return widget.child;
    return FirstTodayHint(link: link, gone: _gone, child: widget.child);
  }
}
