import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// [child] rising in once (`rise`: 14 below and clear, to place, 500 ms,
/// emphasized decelerate) after [delay]; with Reduce Motion it fades in
/// over 200 ms, also after [delay]. The first Today's rows, hint and sync
/// card (ED-490).
class FirstTodayRise extends StatefulWidget {
  const FirstTodayRise({
    required this.delay,
    required this.child,
    this.from = OnbSize.arriveRise,
    super.key,
  });

  final Duration delay;
  final double from;
  final Widget child;

  @override
  State<FirstTodayRise> createState() => _FirstTodayRiseState();
}

/// A leaf: only its one run.
class _FirstTodayRiseState extends State<FirstTodayRise>
    with SingleTickerProviderStateMixin {
  late final _run = AnimationController(
    vsync: this,
    duration: OnbMotion.arrive,
  );
  Timer? _wait;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wait != null || _run.isAnimating || _run.isCompleted) return;
    if (DotTheme.of(context).motion.isReduced) {
      _run.duration = OnbMotion.fade;
    }
    _wait = Timer(widget.delay, () {
      if (mounted) _run.forward().ignore();
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = DotTheme.of(context).motion.isReduced;
    if (reduced) return FadeTransition(opacity: _run, child: widget.child);
    final eased = CurvedAnimation(parent: _run, curve: OnbMotion.decelerate);
    return AnimatedBuilder(
      animation: eased,
      builder: (_, child) => Opacity(
        opacity: eased.value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - eased.value) * widget.from),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// When the thread's row at [index] starts rising: 150 ms, then 120 ms
/// apart.
Duration firstTodayRowDelay(int index) =>
    OnbMotion.arriveFirst + OnbMotion.arriveGap * index;
