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

  /// You're in: the card shrinks to .94 as it leaves (`.card.gone`).
  static const double cardExitScale = 0.94;

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

  /// What fills your days' thread (`threadHTML`, `.tl2`, `.trow`): 6 under
  /// the line, inset 12 above and 8 below, rows 28 in from each end and at
  /// least 52 apart (46 next to a pick, 40 between picks), shrunk
  /// together when they don't fit. The time ends at 72; the thread is 4
  /// wide at 98; the words start at 132.
  static const double fillsTop = 6;
  static const double threadInsetTop = 12;
  static const double threadInsetBottom = 8;
  static const double threadPad = 28;
  static const double gapAnchors = 52;
  static const double gapOne = 46;
  static const double gapPicks = 40;
  static const double rowTimeEnd = 72;
  static const double rowTimeTop = 10;
  static const double threadX = 98;
  static const double threadWidth = 4;
  static const double rowWords = 132;

  /// Row dots: Wake Up and Wind Down 40 (32 when shrunk), picks 32 (24
  /// when shrunk, icon 14); a 3 ring; icons 20. The words sit 21 above the
  /// row's line (17 for a pick, 11 when shrunk).
  static const double anchorDot = 40;

  /// The nudge's subject (`.trow.task .dt`): 44, filled.
  static const double taskDot = 44;

  /// Its drop (`@keyframes drop`): from 160 above, a 12 bounce, then 3.
  static const double dropFrom = 160;
  static const double dropBounce = 12;
  static const double dropBounceSmall = 3;
  static const double anchorDotSmall = 32;
  static const double pickDot = 32;
  static const double pickDotSmall = 24;
  static const double rowRing = 3;
  static const double rowIcon = 20;
  static const double rowIconSmall = 14;
  static const double wordsTop = 21;
  static const double wordsTopPick = 17;
  static const double wordsTopSmall = 11;

  /// NOW (`.nowm`): its line from 86, 2 high at .55 of coral, stopping 4
  /// either side of a row's words; the pill 22 high, padding 7.
  static const double nowLine = 86;
  static const double nowLineHeight = 2;
  static const double nowLineAlpha = 0.55;
  static const double nowGap = 4;
  static const double nowPill = 22;
  static const double nowPillPad = 7;

  /// The chips (`.rchips`, `.rchip`): 10 above, 14 below, 8 apart; 46
  /// high, padding 6 then 16, the dot 34 with a 3 ring, 8 to the words; a
  /// picked chip's 2 ring; its shadow 0 4 12 -6 at .18; off at .4,
  /// pressed to .95.
  static const double chipsTop = 10;
  static const double chipsBottom = 14;
  static const double chipGap = 8;
  static const double chip = 46;
  static const double chipStart = 6;
  static const double chipEnd = 16;
  static const double chipDot = 34;
  static const double chipRing = 3;
  static const double chipPickedRing = 2;
  static const double chipIcon = 18;

  /// Above and below a chip's words, so they stand as tall as its dot
  /// (Material's chip needs that): (34 − 19) / 2.
  static const double chipWordsPad = 7.5;
  static const double chipShadowY = 4;
  static const double chipShadowBlur = 12;
  static const double chipShadowSpread = -6;
  static const double chipShadowAlpha = 0.18;
  static const double chipOff = 0.4;
  static const double chipPressScale = 0.95;

  /// "Add your own" (`.addown`): 52 high, padding 8 then 4, 8 apart, 12
  /// below; its 1 line (2 in the accent while typing); the + 44, icon 20.
  static const double addField = 52;
  static const double addStart = 8;
  static const double addEnd = 4;
  static const double addBottom = 12;
  static const double addButton = 44;
  static const double addIcon = 20;

  /// Above and below the typed words, so the field is a 48 target
  /// inside the 52 pill: (48 − 19) / 2.
  static const double addWordsPad = 14.5;

  /// The flying dot (`.fly`): shadow 0 6 14 -4 at .35; it rises 50 at the
  /// middle of its arc and grows to 1.25, landing at .94; the row's dot
  /// then pops from .6 through 1.15.
  static const double flyShadowY = 6;
  static const double flyShadowBlur = 14;
  static const double flyShadowSpread = -4;
  static const double flyShadowAlpha = 0.35;
  static const double flyRise = 50;
  static const double flyMidX = 0.45;
  static const double flyMidY = 0.55;
  static const double flyMidScale = 1.25;
  static const double flyEndScale = 0.94;
  static const double landFrom = 0.6;
  static const double landPeak = 1.15;

  /// At 200 % text the step scrolls; the thread keeps this height.
  static const double threadMinHeight = 300;

  /// The nudge (`vNudge`): the thread from 64 under the top row to 318
  /// above the bottom, under the sheet.
  static const double nudgeThreadTop = 64;
  static const double nudgeThreadBottom = 318;

  /// The reminder preview (`.banner`): 12 from the screen's sides (14 in
  /// the card), 4 over
  /// the top row on a phone or 4 under it in the card; padding 12 × 14, 12
  /// apart; corner 24 (20 on Android); the glass at .82 (.86 dark), blur
  /// 20 at 1.6 saturation.
  static const double bannerSide = 12;
  static const double bannerSideCard = 14;
  static const double bannerOverlap = 4;
  static const double bannerPadV = 12;
  static const double bannerPadH = 14;
  static const double bannerGap = 12;
  static const double bannerRadius = 24;
  static const double bannerRadiusAndroid = 20;
  static const double glassAlphaLight = 0.82;
  static const double glassAlphaDark = 0.86;
  static const double bannerBlur = 20;
  static const double bannerSaturation = 1.6;

  /// The app's mark in it (`.appic`): 40, corner 11; the dot 16 with a 4
  /// ring of the accent and a 6 ring round that.
  static const double appIcon = 40;
  static const double appIconRadius = 11;
  static const double appIconDot = 16;
  static const double appIconGap = 4;
  static const double appIconRing = 6;

  /// "PREVIEW" (`.pv`): 9 above the banner, 16 in; 18 high, padding 7.
  static const double previewTop = 9;
  static const double previewStart = 16;
  static const double previewHeight = 18;
  static const double previewPad = 7;

  /// The ask (`.sheet`): 8 from the screen's edges (10 in the card), corner
  /// 40 (28 Android, 30 in the card), padding 26 22 24, shadow 0 −10 40 −10
  /// at .3; the buttons 20 under the words.
  static const double sheetInset = 8;
  static const double sheetInsetCard = 10;
  static const double sheetRadius = 40;
  static const double sheetRadiusAndroid = 28;
  static const double sheetRadiusCard = 30;
  static const double sheetPadTop = 26;
  static const double sheetPadSide = 22;
  static const double sheetPadBottom = 24;
  static const double sheetShadowY = -10;
  static const double sheetShadowBlur = 40;
  static const double sheetShadowSpread = -10;
  static const double sheetShadowAlpha = 0.3;
  static const double sheetCtaTop = 20;

  /// "Two more, if you like" (ED-489, the owner's option C): the rows in a
  /// group 18 under the words, corner 22, on the ground colour; rows at
  /// least 64, padding 12 × 14, 12 apart, the dot 40 with its 3 ring.
  static const double moreTop = 18;
  static const double moreRadius = 22;
  static const double moreRow = 64;
  static const double moreRowPadV = 12;
  static const double moreRowPadH = 14;
  static const double moreGap = 12;

  /// You're in (`vToday`, ED-490): the hint (`.hint`) 40 high, padding 14,
  /// its 6 arrow pointing at the done circle, 6 from it.
  static const double hint = 40;
  static const double hintPad = 14;
  static const double hintArrow = 6;
  static const double hintGap = 6;

  /// The sync card (`.sync`): 8 above, 10 below, padding 12 8 12 14,
  /// corner 22, 12 apart, its 1 line; Sign in 40 high, padding 14; ✕ 44.
  static const double syncTop = 8;
  static const double syncBottom = 10;
  static const double syncPadV = 12;
  static const double syncPadStart = 14;
  static const double syncPadEnd = 8;
  static const double syncRadius = 22;
  static const double syncGap = 12;
  static const double syncButton = 40;
  static const double syncButtonPad = 14;
  static const double syncIcon = 24;
  static const double syncClose = 44;
  static const double syncCloseIcon = 18;

  /// From this text size Sign in takes its own line (the duration chips'
  /// threshold, §5.4).
  static const double syncLargeText = 1.3;

  /// Things rising in (`rise`): from 14 below. The hint leaves 6 up, the
  /// card 10 down.
  static const double arriveRise = 14;
  static const double hintLeave = 6;
  static const double syncLeave = 10;
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

  /// NOW on its coral pill: white in both themes (`.nowm span`).
  static const nowInk = Color(0xFFFFFFFF);

  /// The chips' and the flying dot's shadows: black in both themes
  /// (`rgba(0,0,0,…)`).
  static const black = Color(0xFF000000);

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

  /// CSS `ease` (a transition with no curve named: the card's fade and
  /// the scrim as the card leaves).
  static const ease = Cubic(0.25, 0.1, 0.25, 1);

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

  /// What fills your days: a chip's dot flies onto its row (560 ms, the
  /// draw curve), the row's dot pops (320 ms, the spring); a chip presses
  /// in over 150 ms. Reduce Motion: the row fades in (200 ms).
  static const fly = Duration(milliseconds: 560);
  static const land = Duration(milliseconds: 320);
  static const chipPress = Duration(milliseconds: 150);

  /// A chip's dot filling when picked (`.rd` transition .2 s).
  static const chipFill = Duration(milliseconds: 200);

  /// The nudge: the subject drops (620 ms; the light tap lands at 55 %),
  /// the preview slides down at 450 ms (420 ms) from 130 % above, the ask
  /// rises at 800 ms (500 ms) from 110 % below, both emphasized
  /// decelerate; focus moves to Allow nudges at 900 ms. Reduce Motion:
  /// all three fade in (200 ms) at once.
  static const nudge = Duration(milliseconds: 1300);
  static const drop = Duration(milliseconds: 620);
  static const double dropLand = 0.55;
  static const bannerStart = Duration(milliseconds: 450);
  static const bannerIn = Duration(milliseconds: 420);
  static const double bannerFrom = 1.3;
  static const sheetStart = Duration(milliseconds: 800);
  static const sheetIn = Duration(milliseconds: 500);
  static const double sheetFrom = 1.1;
  static const askFocus = Duration(milliseconds: 900);

  /// You're in (`.stg`): rows rise in turn, 500 ms each (emphasized
  /// decelerate) from 150 ms, 120 ms apart; the hint at 1.1 s, the sync
  /// card at 1.6 s. The hint leaves over 400 ms, the card over 300 ms.
  static const arrive = Duration(milliseconds: 500);
  static const arriveFirst = Duration(milliseconds: 150);
  static const arriveGap = Duration(milliseconds: 120);
  static const hintStart = Duration(milliseconds: 1100);
  static const syncStart = Duration(milliseconds: 1600);
  static const hintLeave = Duration(milliseconds: 400);
  static const syncLeave = Duration(milliseconds: 300);
}
