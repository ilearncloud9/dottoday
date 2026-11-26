import 'package:flutter/animation.dart';

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
}
