import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/first_today/first_today_rise.dart';
import 'package:flutter/material.dart';

/// A one-time card at the foot of Today (the onboarding prototype's
/// `.sync`; ED-490, ED-491): [glyph], [title], [body], one [action] and ✕
/// at Today's page margin. It rises in after [delay]; [onAction] or ✕
/// sends it 10 down over 300 ms, then [onGone] (where it is marked done).
/// At large text the action takes its own line, so nothing breaks.
class FootOfferCard extends StatefulWidget {
  const FootOfferCard({
    required this.glyph,
    required this.title,
    required this.body,
    required this.action,
    required this.onAction,
    required this.onGone,
    this.delay = Duration.zero,
    this.dismissLabel,
    super.key,
  });

  final DotGlyph glyph;
  final String title;
  final String body;
  final String action;

  /// The action's own effect (open Settings › Account, switch to Less…).
  final VoidCallback onAction;

  /// After it leaves, whichever way.
  final VoidCallback onGone;
  final Duration delay;

  /// ✕'s screen reader label; "Not now" by default.
  final String? dismissLabel;

  @override
  State<FootOfferCard> createState() => _FootOfferCardState();
}

/// A leaf: only whether it is leaving.
class _FootOfferCardState extends State<FootOfferCard> {
  var _gone = false;

  void _leave({bool act = false}) {
    if (_gone) return;
    setState(() => _gone = true);
    if (act) widget.onAction();
    Future<void>.delayed(OnbMotion.syncLeave, widget.onGone).ignore();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final line = OnbSky.of(c.isDark ? Brightness.dark : Brightness.light).line;
    return Padding(
      // Today's page margin at the sides, as its other foot prompts.
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        OnbSize.syncTop,
        DotSpace.page,
        OnbSize.syncBottom,
      ),
      child: AnimatedOpacity(
        opacity: _gone ? 0 : 1,
        duration: OnbMotion.syncLeave,
        child: AnimatedSlide(
          offset: _gone ? const Offset(0, 0.1) : Offset.zero,
          duration: OnbMotion.syncLeave,
          child: FirstTodayRise(
            delay: widget.delay,
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(
                OnbSize.syncPadStart,
                OnbSize.syncPadV,
                OnbSize.syncPadEnd,
                OnbSize.syncPadV,
              ),
              decoration: ShapeDecoration(
                color: c.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OnbSize.syncRadius),
                  side: BorderSide(color: line),
                ),
              ),
              child: _body(context, t),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, DotTheme t) {
    final c = t.colors;
    final w = widget;
    final large =
        MediaQuery.textScalerOf(context).scale(1) > OnbSize.syncLargeText;
    final words = Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(w.title, style: t.styles.onbSyncTitle),
          Text(w.body, style: t.styles.onbSyncBody),
        ],
      ),
    );
    final icon = DotIcon(w.glyph, color: c.accentText, size: OnbSize.syncIcon);
    final act = FilledButton.tonal(
      onPressed: () => _leave(act: true),
      style: FilledButton.styleFrom(
        backgroundColor: c.tonal,
        foregroundColor: c.accentText,
        textStyle: t.styles.onbSyncButton,
        minimumSize: const Size(0, OnbSize.syncButton),
        padding: const EdgeInsets.symmetric(horizontal: OnbSize.syncButtonPad),
        shape: const StadiumBorder(),
      ),
      child: Text(w.action),
    );
    final close = IconButton(
      onPressed: _leave,
      tooltip: w.dismissLabel ?? context.l10n.promptNotNow,
      constraints: const BoxConstraints.tightFor(
        width: OnbSize.syncClose,
        height: OnbSize.syncClose,
      ),
      icon: DotIcon(
        DotGlyphs.close,
        color: c.secondary,
        size: OnbSize.syncCloseIcon,
      ),
    );
    if (!large) {
      return Row(spacing: OnbSize.syncGap, children: [icon, words, act, close]);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: OnbSize.syncGap,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: OnbSize.syncGap,
          children: [icon, words, close],
        ),
        act,
      ],
    );
  }
}
