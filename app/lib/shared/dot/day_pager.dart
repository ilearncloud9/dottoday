import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Horizontal pager of day cards (docs/10 §3 `DayPager`, `Main`):
/// neighbours peek 22 px, page physics snap, seven page dots below.
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
    this.dotIndexOf = _weekday,
    super.key,
  });

  final int itemCount;
  final int initialIndex;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onChanged;

  /// Which of the 7 dots a page lights (default: its place in the week).
  final int Function(int page) dotIndexOf;

  /// How far each neighbour shows past the edge.
  static const double peek = 22;

  static int _weekday(int page) => page % 7;

  @override
  State<DayPager> createState() => _DayPagerState();
}

class _DayPagerState extends State<DayPager> {
  PageController? _controller;
  double? _width;
  late int _page = widget.initialIndex;

  @override
  void didUpdateWidget(DayPager old) {
    super.didUpdateWidget(old);
    final target = widget.initialIndex;
    if (target == old.initialIndex || target == _page) return;
    _page = target;
    final c = _controller;
    if (c == null || !c.hasClients) return;
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
    _controller?.dispose();
    super.dispose();
  }

  /// Rebuilt when the width changes: the fraction that leaves [peek] each
  /// side depends on it.
  PageController _controllerFor(double width) {
    if (_controller != null && _width == width) return _controller!;
    _controller?.dispose();
    _width = width;
    final fraction = (width - 2 * DayPager.peek) / width;
    return _controller = PageController(
      initialPage: _page,
      viewportFraction: fraction.clamp(0.5, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) => _pager(box.maxHeight));
  }

  /// The pages over their dots; a pager squeezed below [_dotsMinHeight]
  /// keeps only the pages rather than overflow.
  Widget _pager(double height) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => PageView.builder(
              controller: _controllerFor(box.maxWidth),
              itemCount: widget.itemCount,
              onPageChanged: (i) {
                setState(() => _page = i);
                widget.onChanged?.call(i);
              },
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: DotSpace.xs),
                child: widget.itemBuilder(context, i),
              ),
            ),
          ),
        ),
        if (height >= _dotsMinHeight)
          _PageDots(active: widget.dotIndexOf(_page)),
      ],
    );
  }
}

/// The dots need ~46 px; below three times that the card matters more.
const _dotsMinHeight = 140.0;

class _PageDots extends StatelessWidget {
  const _PageDots({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      container: true,
      label: context.l10n.dayPagerPosition(active + 1, 7),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DotSpace.m),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: DotSpace.s,
          children: [
            for (var i = 0; i < 7; i++)
              AnimatedContainer(
                duration: t.motion.base,
                curve: t.motion.curve,
                width: i == active
                    ? DotSize.weekDot * 4.5
                    : DotSize.weekDot + 2,
                height: DotSize.weekDot + 2,
                decoration: BoxDecoration(
                  color: i == active ? t.colors.accent : t.colors.hairline,
                  borderRadius: BorderRadius.circular(DotRadii.pill),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
