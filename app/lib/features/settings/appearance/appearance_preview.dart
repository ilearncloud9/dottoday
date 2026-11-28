import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Appearance's live preview (E-G3-9b, ED-161): a small Today drawn with
/// the theme, App colour and layout in use, so each choice shows at once.
/// Everything shows the week, three dots and the tabs with Create task;
/// Less shows the Now ring, Done, Next and three tabs. Switching crossfades
/// (instant under reduced motion). Read as one label by screen readers.
class AppearancePreview extends ConsumerWidget {
  const AppearancePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final less = ref.watch(layoutPolicyProvider.select((p) => p.isMinimal));
    final use24h = ref.watch(currentProfileProvider).value?.settings.use24h;
    return Semantics(
      label: context.l10n.previewLabel,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(DotSpace.m),
        decoration: BoxDecoration(
          color: t.colors.card,
          borderRadius: BorderRadius.circular(DotRadii.cardLarge),
          border: Border.all(color: t.colors.hairline),
        ),
        // Its own height, which grows with the text size; the switch
        // crossfades and the card eases to the new height.
        child: AnimatedSize(
          duration: t.motion.slow,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: t.motion.slow,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: less
                ? const _Less(key: ValueKey(true))
                : _Everything(key: const ValueKey(false), use24h: use24h),
          ),
        ),
      ),
    );
  }
}

class _Everything extends StatelessWidget {
  const _Everything({required this.use24h, super.key});

  final bool? use24h;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final number = NumberFormat.decimalPattern(locale);
    final narrow = DateFormat('EEEEE', locale); // l10n-ignore: date pattern
    final small = t.styles.rowMeta;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var d = 1; d <= 7; d++)
              Expanded(
                child: Column(
                  children: [
                    Text(narrow.format(DateTime(2024, 1, d)), style: small),
                    _Day(text: number.format(d), today: d == 3),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: DotSpace.s),
        for (final (colour, minute, done) in [
          (TaskColor.mint, 7 * 60 + 30, true),
          (TaskColor.coral, 12 * 60 + 30, true),
          (TaskColor.sky, 15 * 60, false),
        ])
          _Line(
            colour: colour,
            time: clockText(context, minute, use24h),
            done: done,
          ),
        const SizedBox(height: DotSpace.s),
        Row(
          spacing: DotSpace.s,
          children: [
            Expanded(
              child: _Tabs(
                glyphs: [
                  DotGlyphs.today,
                  DotGlyphs.inbox,
                  DotGlyphs.calendar,
                  DotGlyphs.search,
                ],
              ),
            ),
            Flexible(child: _Pill(text: l10n.createTask)),
          ],
        ),
      ],
    );
  }
}

class _Less extends StatelessWidget {
  const _Less({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final small = t.styles.rowMeta;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: DotSize.previewRing,
          child: CustomPaint(
            painter: _Ring(track: t.colors.hairline, arc: t.colors.accentText),
            child: Center(
              child: Text(number.format(18), style: t.styles.rowTitle),
            ),
          ),
        ),
        Text(l10n.previewTask, style: small.copyWith(color: t.colors.ink)),
        _Pill(text: l10n.liveDone),
        Text(l10n.previewNext, style: small),
        const SizedBox(height: DotSpace.s),
        _Tabs(
          glyphs: [DotGlyphs.now, DotGlyphs.today, DotGlyphs.inbox],
          centre: true,
        ),
      ],
    );
  }
}

/// The tab bar as its icons, the first in the accent.
class _Tabs extends StatelessWidget {
  const _Tabs({required this.glyphs, this.centre = false});

  final List<DotGlyph> glyphs;
  final bool centre;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      mainAxisAlignment: centre
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      spacing: DotSpace.l,
      children: [
        for (final (i, g) in glyphs.indexed)
          DotIcon(
            g,
            size: DotSize.rowIcon,
            color: i == 0 ? t.colors.accentText : t.colors.secondary,
          ),
      ],
    );
  }
}

/// A day number, today's in the accent's circle.
class _Day extends StatelessWidget {
  const _Day({required this.text, required this.today});

  final String text;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final style = t.styles.rowMeta.copyWith(
      color: today ? t.colors.onAccent : t.colors.ink,
      fontWeight: FontWeight.w700,
    );
    return Container(
      width: DotSize.pickerDot,
      height: DotSize.pickerDot,
      alignment: Alignment.center,
      decoration: today
          ? BoxDecoration(color: t.colors.accentFill, shape: BoxShape.circle)
          : null,
      child: Text(text, style: style),
    );
  }
}

/// A dot, the thread as a bar, the time, and done as a filled mark.
class _Line extends StatelessWidget {
  const _Line({required this.colour, required this.time, required this.done});

  final TaskColor colour;
  final String time;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.tasks[colour];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DotSpace.xxs),
      child: Row(
        spacing: DotSpace.s,
        children: [
          Container(
            width: DotSize.pickerDot / 2,
            height: DotSize.pickerDot / 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? c.color : null,
              border: Border.all(color: c.ring, width: DotSize.smallDotOutline),
            ),
          ),
          Expanded(
            child: Container(
              height: DotSpace.xs,
              decoration: BoxDecoration(
                color: t.colors.hairline,
                borderRadius: BorderRadius.circular(DotSpace.xs),
              ),
            ),
          ),
          Text(time, style: t.styles.rowMeta),
        ],
      ),
    );
  }
}

/// Create task / Done in the accent.
class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.s,
        vertical: DotSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: t.colors.accentFill,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: Text(
        text,
        style: t.styles.rowMeta.copyWith(
          color: t.colors.onAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// The Now ring: three quarters of the time left, in the accent.
class _Ring extends CustomPainter {
  const _Ring({required this.track, required this.arc});

  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width / 12;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawArc(rect, 0, 2 * math.pi, false, paint..color = track)
      ..drawArc(rect, -math.pi / 2, 1.5 * math.pi, false, paint..color = arc);
  }

  @override
  bool shouldRepaint(_Ring old) => old.track != track || old.arc != arc;
}
