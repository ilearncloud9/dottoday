import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/live_activity/live_dot_plan.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';

/// What the browser tab shows (docs/09 M9.7, docs/11 A1 web): while a dot
/// is live, the title "● 38 min left · Deep work" and a favicon ring; the
/// Inbox count on the installed app's badge, where the browser has one.
/// Null [title] / [favicon] = the app's own.
final class WebLiveDot {
  const WebLiveDot({this.title, this.favicon, this.badge = 0});

  static const none = WebLiveDot();

  final String? title;

  /// A `data:image/svg+xml` URL (CSP: `img-src data:`).
  final String? favicon;

  final int badge;

  @override
  bool operator ==(Object other) =>
      other is WebLiveDot &&
      other.title == title &&
      other.favicon == favicon &&
      other.badge == badge;

  @override
  int get hashCode => Object.hash(title, favicon, badge);
}

/// The tab for [snapshot] at [nowUtc] in [l10n]'s language; the favicon
/// ring in the App colour's [accent] tones (`appColourTones`), as on the
/// Live Activity (M20.9 part 6, ED-474).
///
/// ```dart
/// webLiveDot(snapshot, now, l10n, accent: tones).title; // '● 38 min left · Deep work'
/// ```
WebLiveDot webLiveDot(
  DaySnapshot? snapshot,
  DateTime nowUtc,
  AppLocalizations l10n, {
  required Map<String, Map<String, String>> accent,
}) {
  if (snapshot == null) return WebLiveDot.none;
  final plan = liveDotPlan(snapshot, nowUtc);
  final badge = snapshot.inboxCount;
  if (plan == null || !plan.isLive) return WebLiveDot(badge: badge);
  final dot = plan.focus;
  final left = dot.endUtc.difference(nowUtc);
  // Overrunning: the dot and its name, no "0 min left".
  final title = left.isNegative || left == Duration.zero
      ? '● ${dot.title}'
      : '● ${l10n.liveActivityLeft(l10n.durationMinutes((left.inSeconds / 60).ceil()))} · ${dot.title}';
  final total = dot.endUtc.difference(dot.startUtc).inSeconds;
  final share = total <= 0
      ? 1.0
      : (nowUtc.difference(dot.startUtc).inSeconds / total).clamp(0.0, 1.0);
  return WebLiveDot(
    title: title,
    favicon: faviconRing(
      share,
      light: accent['light']!['dot']!,
      dark: accent['dark']!['dot']!,
    ),
    badge: badge,
  );
}

/// A 32 px ring, [share] of it drawn from the top clockwise, a dot inside:
/// the live dot as a favicon. [light] ("#RRGGBB") on a light browser,
/// [dark] on a dark one (the SVG's own `prefers-color-scheme`).
String faviconRing(
  double share, {
  required String light,
  required String dark,
}) {
  const r = 12.0;
  final length = 2 * math.pi * r;
  final drawn = (length * share.clamp(0.0, 1.0)).toStringAsFixed(2);
  final svg =
      "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'>"
      '<style>.c{stroke:$light}.f{fill:$light}'
      '@media (prefers-color-scheme:dark){.c{stroke:$dark}.f{fill:$dark}}'
      '</style>'
      "<circle class='c' cx='16' cy='16' r='$r' fill='none' "
      "stroke-opacity='0.25' stroke-width='5'/>"
      "<circle class='c' cx='16' cy='16' r='$r' fill='none' "
      "stroke-width='5' stroke-linecap='round' "
      "stroke-dasharray='$drawn ${length.toStringAsFixed(2)}' "
      "transform='rotate(-90 16 16)'/>"
      "<circle class='f' cx='16' cy='16' r='4.5'/></svg>";
  return 'data:image/svg+xml,${Uri.encodeComponent(svg)}';
}
