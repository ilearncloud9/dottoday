import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The day card's scrolling thread, opened at [anchor] (ED-336, ED-103):
/// today's card scrolls once, on open, so the live task (or the now
/// marker) is in view above the floating controls rather than under them.
/// A day without an anchor opens at its top. Under reduced motion it
/// jumps instead of animating (§2.4).
class DayCardScroll extends StatefulWidget {
  const DayCardScroll({
    required this.anchor,
    required this.slivers,
    this.clearance = 0,
    super.key,
  });

  /// How far down the anchor row now sits (0–1); null opens at the top.
  /// Read once, when the card opens.
  final double? anchor;

  /// The card's slivers; the anchor row carries the given key while the
  /// card looks for it, and none after (null), so a later change of live
  /// task never rebuilds a row mid-drag.
  final List<Widget> Function(GlobalKey? anchorKey) slivers;

  /// The bottom strip the floating controls cover.
  final double clearance;

  @override
  State<DayCardScroll> createState() => _DayCardScrollState();
}

class _DayCardScrollState extends State<DayCardScroll> {
  final _controller = ScrollController();
  final _anchorKey = GlobalKey();

  /// A wider build reach, in viewports, while the lazy list has not built
  /// the anchor row yet; the view stays put meanwhile, so nothing
  /// flickers. Back to the default once the row is found (R-15).
  double? _reach;
  int _tries = 0;
  late bool _seeking = widget.anchor != null;

  /// Each try builds four times further; four cover a long day.
  static const _maxTries = 4;
  static const _growth = 4.0;

  @override
  void initState() {
    super.initState();
    if (_seeking) _next();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() => WidgetsBinding.instance.addPostFrameCallback((_) => _seek());

  void _seek() {
    if (!mounted || !_controller.hasClients) return;
    final row = _anchorKey.currentContext?.findRenderObject();
    if (row is RenderBox && row.hasSize) return _reveal(row);
    if (_tries++ >= _maxTries) return _settle();
    setState(() => _reach = (_reach ?? 1) * _growth);
    _next();
  }

  /// Scrolls the now row's top to the top edge, so the edge falls between
  /// rows and never cuts the line above in half (ED-392); a live task too
  /// long for its now point to show from there scrolls the now point a
  /// little below the top instead. Stays put when the row's head already
  /// sits clear of the floating controls.
  void _reveal(RenderBox row) {
    final p = _controller.position;
    final top = RenderAbstractViewport.of(row).getOffsetToReveal(row, 0).offset;
    final clear = p.viewportDimension - widget.clearance;
    final y = top + widget.anchor! * row.size.height;
    // The row's head (its dot, title and time) must sit clear; a long
    // live task needn't fit whole, so a tall phone usually stays put.
    final tail = (row.size.height - (y - top)).clamp(
      0.0,
      ThreadScale.forWidth(context).dot,
    );
    _settle();
    if (y >= p.pixels && y + tail <= p.pixels + clear) return;
    final fits = y + tail <= top + clear;
    final target = (fits ? top : y - DotSpace.xl).clamp(
      p.minScrollExtent,
      p.maxScrollExtent,
    );
    final motion = DotTheme.of(context).motion;
    if (motion.isReduced) return p.jumpTo(target);
    unawaited(p.animateTo(target, duration: motion.slow, curve: motion.curve));
  }

  void _settle() => setState(() {
    _reach = null;
    _seeking = false;
  });

  @override
  Widget build(BuildContext context) => CustomScrollView(
    controller: _controller,
    scrollCacheExtent: switch (_reach) {
      final r? => ScrollCacheExtent.viewport(r),
      null => null,
    },
    slivers: widget.slivers(_seeking ? _anchorKey : null),
  );
}
