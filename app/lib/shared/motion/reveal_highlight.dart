import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A one-time accent behind [child] (docs/13 §4.3): an `accentTint` pill,
/// with no padding so adding or dropping it never moves a pixel, that holds for `DotMotion.reveal`, then fades over `slow`. Under
/// reduced motion nothing is drawn. Either way [announcement] is said once
/// to screen readers and [onDone] runs once, so the caller can remember it
/// was shown. Inactive, it is just [child].
class RevealHighlight extends StatefulWidget {
  const RevealHighlight({
    required this.child,
    required this.active,
    required this.announcement,
    required this.onDone,
    super.key,
  });

  final Widget child;
  final bool active;
  final String announcement;
  final VoidCallback onDone;

  @override
  State<RevealHighlight> createState() => _RevealHighlightState();
}

class _RevealHighlightState extends State<RevealHighlight> {
  bool _lit = false;
  bool _started = false;
  Timer? _hold;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _start();
  }

  @override
  void didUpdateWidget(RevealHighlight old) {
    super.didUpdateWidget(old);
    _start();
  }

  void _start() {
    if (!widget.active || _started) return;
    _started = true;
    final motion = DotTheme.of(context).motion;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        widget.announcement,
        Directionality.of(context),
      ),
    );
    if (motion.reveal == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
      return;
    }
    _lit = true;
    _hold = Timer(motion.reveal, () {
      if (!mounted) return;
      setState(() => _lit = false);
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return AnimatedContainer(
      duration: t.motion.slow,
      curve: t.motion.curve,
      decoration: BoxDecoration(
        color: _lit
            ? t.colors.accentTint
            : t.colors.accentTint.withValues(alpha: 0),
        borderRadius: const BorderRadius.all(Radius.circular(DotRadii.pill)),
      ),
      child: widget.child,
    );
  }
}
