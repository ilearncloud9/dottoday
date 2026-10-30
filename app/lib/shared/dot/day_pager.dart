import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Horizontal pager of day sheets (docs/10 §3 `DayPager`, ADR-0015): each
/// day fills the width and page physics snap; no neighbour peeks and no
/// page dots, so the thread gets the room (the week strip already says
/// which day shows).
///
/// Opens on [initialIndex] (the feature passes today's index, §6 "Today
/// always opens on the current date"). A new [initialIndex] later (a tap on
/// the week strip) slides the pager there.
class DayPager extends StatefulWidget {
  const DayPager({
    required this.itemCount,
    required this.initialIndex,
    required this.itemBuilder,
    this.onChanged,
    super.key,
  });

  final int itemCount;
  final int initialIndex;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onChanged;

  @override
  State<DayPager> createState() => _DayPagerState();
}

class _DayPagerState extends State<DayPager> {
  // Set in initState, not lazily: a lazy field first read in
  // didUpdateWidget would take the new index and never slide there.
  late final PageController _controller;
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = widget.initialIndex;
    _controller = PageController(initialPage: _page);
  }

  @override
  void didUpdateWidget(DayPager old) {
    super.didUpdateWidget(old);
    final target = widget.initialIndex;
    if (target == old.initialIndex || target == _page) return;
    _page = target;
    final c = _controller;
    if (!c.hasClients) return;
    final motion = DotTheme.of(context).motion;
    if (motion.isReduced) {
      c.jumpToPage(target);
    } else {
      unawaited(
        c.animateToPage(target, duration: motion.slow, curve: motion.curve),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.itemCount,
      onPageChanged: (i) {
        _page = i;
        widget.onChanged?.call(i);
      },
      itemBuilder: widget.itemBuilder,
    );
  }
}
