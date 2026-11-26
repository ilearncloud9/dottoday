import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Sizes of the approved onboarding (the "Dottoday Onboarding Prototype",
/// ED-305, version `1794780049-65a7`), named after its CSS.
abstract final class OnbSize {
  /// `.view` padding on phones: 24 at the sides, 34 below.
  static const double side = 24;
  static const double bottom = 34;

  /// `.card .view` padding on tablets, Mac and web: 22 26 24.
  static const double cardTop = 22;
  static const double cardSide = 26;
  static const double cardBottom = 24;

  /// `.nav`: 48 high; `.navsp` 60 (Apple) or 48 (Android) to balance Back.
  static const double nav = 48;
  static const double navSpace = 60;
  static const double navSpaceAndroid = 48;

  /// `.prog`: dots 10, the current one 14 with a 4 ring; done and to-do
  /// dots have a 2 ring; bars 26 × 3 between them.
  static const double dot = 10;
  static const double dotCurrent = 14;
  static const double dotRing = 2;
  static const double dotRingCurrent = 4;
  static const double bar = 26;
  static const double barHeight = 3;

  /// `.pbtn` 56 high, `.tbtn` 50; `.cta` gap 8; Hello's buttons 26 under
  /// its line; the age note 6 under them; the question 14 under the nav.
  static const double primary = 56;
  static const double secondary = 50;
  static const double ctaGap = 8;
  static const double ctaTop = 26;
  static const double fineTop = 6;
  static const double titleTop = 14;
  static const double subTop = 8;

  /// Hello's day dot (`.hero svg`): a 300 × 330 drawing.
  static const double heroWidth = 300;
  static const double heroHeight = 330;

  /// `.card`: 440 × 760, corner 36, sitting 8 below centre.
  static const double cardWidth = 440;
  static const double cardHeight = 760;
  static const double cardRadius = 36;
  static const double cardDrop = 8;

  /// Below this window height the card would be cramped; the flow is full
  /// screen there instead (a phone on its side).
  static const double cardMinHeight = 600;

  /// `.wide .back-app.blur`: blur 16, saturation .85, scale 1.03; the
  /// scrim at .6 of the theme's scrim.
  static const double blur = 16;
  static const double blurSaturation = 0.85;
  static const double blurScale = 1.03;
  static const double scrimOpacity = 0.6;

  /// The card's shadow: 0 40 90 -30 at .5.
  static const double cardShadowY = 40;
  static const double cardShadowBlur = 90;
  static const double cardShadowSpread = -30;
  static const double cardShadowAlpha = 0.5;

  /// Your day's dial (`.dial`, `mountDay`): the times run 4:00 to 2:00
  /// the next morning down its height, 34 in from each end. The hour marks
  /// end 94 from its left edge, each with a line from 134 (260 long, the
  /// line colour fading out after 60 %, at .55); the thread runs down 120
  /// (dashed 4 wide, 5 on and 5 off), its awake part 6 wide in the accent.
  static const double dialPad = 34;
  static const double tickEnd = 94;
  static const double tickLine = 134;
  static const double tickLineLength = 260;
  static const double tickLineOpacity = 0.55;
  static const double rail = 120;
  static const double railWidth = 4;
  static const double railDash = 5;
  static const double awakeWidth = 6;

  /// The sun and moon (`.hdl`): 52 round on the card colour, a 3 ring in
  /// their colour inside, a 9 halo at 16 % (14 at 20 % while held), grown
  /// to 1.12 while held; the sun's glyph 26, the moon's 24.
  static const double handle = 52;
  static const double handleRing = 3;
  static const double handleHalo = 9;
  static const double handleHaloHeld = 14;
  static const double handleHaloAlpha = 0.16;
  static const double handleHaloHeldAlpha = 0.2;
  static const double handleHeldScale = 1.12;
  static const double sunGlyph = 26;
  static const double moonGlyph = 24;

  /// Their labels (`.bub`): 158 from the dial's left, corner 16, padding
  /// 8 × 14.
  static const double bubble = 158;
  static const double bubbleRadius = 16;
  static const double bubblePadV = 8;
  static const double bubblePadH = 14;

  /// The soft shadow (`--sh`): 0 10 30 -12, at .28 of the ink in light and
  /// .7 black in dark.
  static const double shadowY = 10;
  static const double shadowBlur = 30;
  static const double shadowSpread = -12;
  static const double shadowAlphaLight = 0.28;
  static const double shadowAlphaDark = 0.7;

  /// The dial's top and bottom fade (`mask-image`: in over 9 %, out from
  /// 91 %); the stars stop 20 short of the sun and the moon, and fade out
  /// from 40 % above and in to 60 % below. The stars are two grids (46 × 34
  /// from 8, 6; 29 × 41 from 21, 19) of dots 1 and .8 round, at .55.
  static const double dialFade = 0.09;
  static const double starGap = 20;
  static const double starsTopSolid = 0.4;
  static const double starsBottomSolid = 0.6;
  static const double starOpacity = 0.55;

  /// The sky's stops round the sun (`.dial` background): night until 14 %
  /// above it, dawn at it, day 16 % below; the same round the moon.
  static const double skyNight = 0.14;
  static const double skyDay = 0.16;

  /// "16 h awake · 8 h of sleep" (`.sum`): 10 above, 12 below; the dial
  /// starts 14 under the line. At large text the step scrolls, and the
  /// dial keeps this height at least.
  static const double sumTop = 10;
  static const double sumBottom = 12;
  static const double dialMinHeight = 360;
}

/// The dial's fade at its top and bottom (`.dial` `mask-image`): an
/// alpha mask, clear at the ends and solid between 9 % and 91 %.
const onbDialFade = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0x00000000),
    Color(0xFF000000),
    Color(0xFF000000),
    Color(0x00000000),
  ],
  stops: [0, OnbSize.dialFade, 1 - OnbSize.dialFade, 1],
);

/// Your day's sky (prototype `--night`, `--dawn`, `--dusk`, `--star` and
/// the line `--ln`), light and dark.
final class OnbSky {
  const OnbSky._({
    required this.night,
    required this.dawn,
    required this.dusk,
    required this.star,
    required this.line,
  });

  final Color night;
  final Color dawn;
  final Color dusk;
  final Color star;
  final Color line;

  static const light = OnbSky._(
    night: Color(0xFFE6E2F4),
    dawn: Color(0xFFFBE3CC),
    dusk: Color(0xFFE9E2F7),
    star: Color(0xFFA9A2CF),
    line: Color(0xFFDDD7E0),
  );

  static const dark = OnbSky._(
    night: Color(0xFF16142A),
    dawn: Color(0xFF3A2A1F),
    dusk: Color(0xFF28233F),
    star: Color(0xFF8C88BE),
    line: Color(0xFF4A4348),
  );

  /// The one [brightness] calls for.
  static OnbSky of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// Motion of the approved onboarding (prototype "Motion, haptics and
/// Reduce Motion" table and CSS).
abstract final class OnbMotion {
  /// Changing step: content rises 18 and fades in over 420 ms, emphasized
  /// decelerate; Back comes from 14 above. The old step leaves 12 up (14
  /// down on Back), emphasized accelerate, gone at 260 ms.
  static const stepIn = Duration(milliseconds: 420);
  static const stepOut = Duration(milliseconds: 260);
  static const double rise = 18;
  static const double riseBack = 14;
  static const double leave = 12;
  static const double leaveBack = 14;

  /// Reduce Motion: a 200 ms cross-fade for every moment.
  static const fade = Duration(milliseconds: 200);

  /// The prototype's curves: emphasized decelerate and accelerate, the
  /// draw curve, the spring pop and the standard curve.
  static const decelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const accelerate = Cubic(0.3, 0, 0.8, 0.15);
  static const draw = Cubic(0.3, 0, 0.2, 1);
  static const pop = Cubic(0.34, 1.56, 0.64, 1);
  static const standard = Cubic(0.2, 0, 0, 1);

  /// The progress dots (`.prog i`, all .4 s) and bars (`.prog b::after`,
  /// .5 s standard).
  static const dots = Duration(milliseconds: 400);
  static const bars = Duration(milliseconds: 500);

  /// Hello's day dot: five arcs 550 ms each, 150 ms in and 90 ms apart;
  /// the centre pops 600 ms at 100 ms; the thread draws 600 ms at
  /// 1250 ms; three dots pop 500 ms at 1550, 1680 and 1810 ms; the words
  /// rise 600 ms at 500, 620, 740 and 800 ms.
  static const arc = Duration(milliseconds: 550);
  static const arcStart = Duration(milliseconds: 150);
  static const arcGap = Duration(milliseconds: 90);
  static const corePop = Duration(milliseconds: 600);
  static const coreStart = Duration(milliseconds: 100);
  static const thread = Duration(milliseconds: 600);
  static const threadStart = Duration(milliseconds: 1250);
  static const dotPop = Duration(milliseconds: 500);
  static const dotStarts = [
    Duration(milliseconds: 1550),
    Duration(milliseconds: 1680),
    Duration(milliseconds: 1810),
  ];
  static const words = Duration(milliseconds: 600);
  static const wordStarts = [
    Duration(milliseconds: 500),
    Duration(milliseconds: 620),
    Duration(milliseconds: 740),
    Duration(milliseconds: 800),
  ];
  static const double wordRise = 14;

  /// The whole Hello drawing, to the last dot's end.
  static const hello = Duration(milliseconds: 2310);

  /// `.pbtn:active`: pressed to .97 over 120 ms; `:disabled` at .38.
  static const press = Duration(milliseconds: 120);
  static const double pressScale = 0.97;
  static const double offOpacity = 0.38;

  /// Tablets, Mac and web: the blur over Today (.7 s standard).
  static const blur = Duration(milliseconds: 700);

  /// The sun and moon grow while held (`.hdl` transform .15 s); their
  /// label pops to 1.06 and back over 220 ms when it reaches an hour
  /// (`.bub.tick`, ease).
  static const handle = Duration(milliseconds: 150);
  static const tick = Duration(milliseconds: 220);
  static const double tickScale = 1.06;
  static const tickCurve = Cubic(0.25, 0.1, 0.25, 1);
}
