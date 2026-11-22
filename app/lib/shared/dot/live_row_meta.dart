import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "9:00–11:00 AM · **Now, 18 min left**" (E rules §5.3): the range, then
/// the time left in the accent at 700.
class NowMeta extends StatelessWidget {
  const NowMeta({
    required this.range,
    required this.style,
    this.now,
    this.tail,
    super.key,
  });

  final String range;
  final String? now;

  /// Joined last with " · ": "Your one thing".
  final String? tail;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = this.now;
    final tail = this.tail;
    if (now == null) {
      return Text(
        tail == null ? range : l10n.liveMeta(range, tail),
        style: style,
      );
    }
    final timed = l10n.liveMeta(range, now);
    final line = tail == null ? timed : l10n.liveMeta(timed, tail);
    final at = timed.lastIndexOf(now);
    if (at < 0) return Text(line, style: style);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: line.substring(0, at)),
          TextSpan(
            text: now,
            // Manrope is variable: bold needs the wght axis too.
            style: DotType.emphasis(
              TextStyle(color: DotTheme.of(context).colors.accentInk),
              bold: true,
              italic: false,
            ),
          ),
          TextSpan(text: line.substring(at + now.length)),
        ],
      ),
      style: style,
    );
  }
}
