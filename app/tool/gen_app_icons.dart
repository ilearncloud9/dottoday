// Generates Dottoday's app icons and launch marks for all four targets
// (docs/09 M8.6, docs/10 §1): the day dot on its thread. A conic ring
// filling from 12 o'clock with the small centre dot (`DayDot`), threaded
// on the dotted free-time line, in white on the indigo accent; launch
// screens show the same mark in the accent on the surface colour.
//
// Run from app/:  dart run tool/gen_app_icons.dart
// Colours come from assets/design/palette.json (accent) and the surfaces
// of docs/10 §2.1; test/tool/app_icons_test.dart checks every file below
// is what this writes and that the colours match `DotPrimitives`.
import 'dart:convert';
import 'dart:io';

import 'icons/raster.dart';

/// Surface colours of docs/10 §2.1 (`DotPrimitives.paper` / `night12`).
const paperHex = '#FAFAF8';
const nightHex = '#121214';

/// The indigo accent (light, dark) from the design palette.
({String light, String dark}) accentHex() {
  final json =
      jsonDecode(File('assets/design/palette.json').readAsStringSync())
          as Map<String, Object?>;
  final key = json['defaultAccent'];
  final accent = (json['accents']! as List)
      .cast<Map<String, Object?>>()
      .firstWhere((a) => a['key'] == key);
  return (light: accent['light']! as String, dark: accent['dark']! as String);
}

/// How an icon is drawn: the mark's colour and what is behind it.
enum IconKind {
  /// Opaque accent square, white mark (iOS, web maskable, apple-touch).
  fullBleed,

  /// macOS: a rounded plate with a soft shadow on transparent.
  macPlate,

  /// Web "any" icons and favicon: a rounded plate, no shadow.
  flatPlate,

  /// Android legacy round icon: the accent circle.
  roundPlate,

  /// Android adaptive foreground and monochrome: white mark, transparent.
  foreground,

  /// Launch / splash marks in the light accent, transparent.
  launchLight,

  /// Launch / splash marks in the dark accent, transparent.
  launchDark,
}

/// One file: where, how big (px), what kind, and the mark's height as a
/// share of the canvas (the visible area differs per mask).
typedef IconJob = ({String path, int size, IconKind kind, double mark});

/// Mark height on a full-bleed square; Android's adaptive mask shows the
/// middle 72 of 108 dp, so its foreground uses two thirds of that.
const _fullMark = 0.74;
const _adaptiveMark = _fullMark * 72 / 108;

/// Below this mark height (px) the thread is left out.
const _smallMark = 40.0;

/// Every generated file, relative to app/.
List<IconJob> iconJobs() => [
  for (final (pt, scales) in const [
    (20.0, [1, 2, 3]),
    (29.0, [1, 2, 3]),
    (40.0, [1, 2, 3]),
    (60.0, [2, 3]),
    (76.0, [1, 2]),
    (83.5, [2]),
    (1024.0, [1]),
  ])
    for (final s in scales)
      (
        path:
            'ios/Runner/Assets.xcassets/AppIcon.appiconset/'
            'Icon-App-${_pt(pt)}x${_pt(pt)}@${s}x.png',
        size: (pt * s).round(),
        kind: IconKind.fullBleed,
        mark: _fullMark,
      ),
  for (final s in [1, 2, 3]) ...[
    (
      path:
          'ios/Runner/Assets.xcassets/LaunchImage.imageset/'
          'LaunchImage${s == 1 ? '' : '@${s}x'}.png',
      size: 160 * s,
      kind: IconKind.launchLight,
      mark: 0.9,
    ),
    (
      path:
          'ios/Runner/Assets.xcassets/LaunchImage.imageset/'
          'LaunchImageDark${s == 1 ? '' : '@${s}x'}.png',
      size: 160 * s,
      kind: IconKind.launchDark,
      mark: 0.9,
    ),
  ],
  for (final size in [16, 32, 64, 128, 256, 512, 1024])
    (
      path:
          'macos/Runner/Assets.xcassets/AppIcon.appiconset/'
          'app_icon_$size.png',
      size: size,
      kind: IconKind.macPlate,
      mark: _fullMark * 0.805,
    ),
  for (final (dpi, scale) in const [
    ('mdpi', 1.0),
    ('hdpi', 1.5),
    ('xhdpi', 2.0),
    ('xxhdpi', 3.0),
    ('xxxhdpi', 4.0),
  ]) ...[
    (
      path: 'android/app/src/main/res/mipmap-$dpi/ic_launcher.png',
      size: (48 * scale).round(),
      kind: IconKind.roundPlate,
      mark: _fullMark * 0.8,
    ),
    (
      path: 'android/app/src/main/res/mipmap-$dpi/ic_launcher_foreground.png',
      size: (108 * scale).round(),
      kind: IconKind.foreground,
      mark: _adaptiveMark,
    ),
  ],
  // Android 12+ splash: a 288 dp icon whose content fits a 192 dp circle;
  // one density, the system scales it (also the pre-12 launch drawable).
  (
    path: 'android/app/src/main/res/drawable-xxxhdpi/splash_mark.png',
    size: 1152,
    kind: IconKind.launchLight,
    mark: _fullMark * 192 / 288,
  ),
  (
    path: 'android/app/src/main/res/drawable-night-xxxhdpi/splash_mark.png',
    size: 1152,
    kind: IconKind.launchDark,
    mark: _fullMark * 192 / 288,
  ),
  (path: 'web/favicon.png', size: 32, kind: IconKind.flatPlate, mark: 0.7),
  for (final size in [192, 512]) ...[
    (
      path: 'web/icons/Icon-$size.png',
      size: size,
      kind: IconKind.flatPlate,
      mark: _fullMark * 0.86,
    ),
    // Maskable: the safe zone is the middle 80 % circle.
    (
      path: 'web/icons/Icon-maskable-$size.png',
      size: size,
      kind: IconKind.fullBleed,
      mark: _fullMark * 0.8,
    ),
  ],
  (
    path: 'web/icons/apple-touch-icon.png',
    size: 180,
    kind: IconKind.fullBleed,
    mark: _fullMark,
  ),
];

String _pt(double pt) => pt == pt.roundToDouble() ? '${pt.round()}' : '$pt';

/// The PNG bytes of [job].
List<int> renderIcon(IconJob job) {
  final r = drawIcon(job);
  final opaque = job.kind == IconKind.fullBleed;
  return encodePng(job.size, r.bytes(opaque: opaque), opaque: opaque);
}

/// The painted canvas of [job] (tests compare its pixels).
Raster drawIcon(IconJob job) {
  final accent = accentHex();
  final white = rgb('#FFFFFF');
  final n = job.size.toDouble(), c = n / 2;
  final r = Raster(job.size);
  switch (job.kind) {
    case IconKind.fullBleed:
      r.fill(everywhere(), rgb(accent.light));
      _mark(r, n * job.mark, white);
    case IconKind.macPlate:
      // Apple's macOS grid: an 824/1024 plate, centred, shadow below.
      final side = n * 824 / 1024, radius = n * 185 / 1024;
      r.shadow(
        roundedSquare(c, c + n * 10 / 1024, side, radius),
        rgb('#000000', 0.3),
        n * 20 / 1024,
      );
      r.fill(roundedSquare(c, c, side, radius), rgb(accent.light));
      _mark(r, n * job.mark, white);
    case IconKind.flatPlate:
      r.fill(roundedSquare(c, c, n * 0.94, n * 0.22), rgb(accent.light));
      _mark(r, n * job.mark, white);
    case IconKind.roundPlate:
      r.fill(circle(c, c, n * 0.46), rgb(accent.light));
      _mark(r, n * job.mark, white);
    case IconKind.foreground:
      _mark(r, n * job.mark, white);
    case IconKind.launchLight:
      _mark(r, n * job.mark, rgb(accent.light));
    case IconKind.launchDark:
      _mark(r, n * job.mark, rgb(accent.dark));
  }
  return r;
}

/// The mark, [height] px tall, centred: a design where the ring has outer
/// radius 220 units and the thread's dots reach ±417 (`u` = px per unit).
/// Under [_smallMark] px the dots would blur into noise, so the ring alone
/// fills the height (favicon, 16–32 px Mac and iPad sizes).
void _mark(Raster r, double height, Rgba ink) {
  final small = height < _smallMark;
  final u = height / (small ? 470 : 834), c = r.size / 2;
  final faint = (r: ink.r, g: ink.g, b: ink.b, a: ink.a * 0.32);
  final thread = (r: ink.r, g: ink.g, b: ink.b, a: ink.a * 0.7);
  for (final dy in small ? const <double>[] : const [272.0, 336.0, 400.0]) {
    r
      ..fill(circle(c, c - dy * u, 17 * u), thread)
      ..fill(circle(c, c + dy * u, 17 * u), thread);
  }
  r
    ..fill(ring(c, c, 190 * u, 60 * u), faint)
    ..fill(arc(c, c, 190 * u, 60 * u, 0.72), ink)
    ..fill(circle(c, c, 70 * u), ink);
}

void main() {
  for (final job in iconJobs()) {
    final file = File(job.path)..parent.createSync(recursive: true);
    file.writeAsBytesSync(renderIcon(job));
  }
  stdout.writeln('Wrote ${iconJobs().length} icons.');
}
