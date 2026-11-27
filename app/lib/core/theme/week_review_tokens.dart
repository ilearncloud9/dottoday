import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/dot_type.dart';
import 'package:flutter/painting.dart';

/// This week (E-R2-24 §1, ED-326, ED-496): sizes from the board.
abstract final class WeekSize {
  /// Between the sheet's blocks: 12.
  static const double gap = 12;

  /// The week card: 22 corners, 10 in.
  static const double cardRadius = 22;
  static const double cardPad = 10;

  /// A day's column: 2 apart, 6 above and below, 14 corners when chosen,
  /// 4 between the letter, the ring and the count.
  static const double columnGap = 2;
  static const double columnPad = 6;
  static const double columnRadius = 14;
  static const double columnLines = 4;

  /// The day's ring: 30 across, a 4 stroke (the share image: 32, 4.5).
  static const double ring = 30;
  static const double ringStroke = 4;
  static const double shareRing = 32;
  static const double shareRingStroke = 4.5;

  /// The open day's tasks under a hairline: 8 above, 8 / 6 / 2 in; rows at
  /// least 30 tall, 10 between the 12 dot, the title and the time; the
  /// done dot filled, the open one a 2.5 ring; 4 above the planned line.
  static const double threadTop = 8;
  static const EdgeInsets threadPad = EdgeInsets.fromLTRB(6, 8, 6, 2);
  static const double threadRow = 30;
  static const double threadGap = 10;
  static const double threadDot = 12;
  static const double threadDotRing = 2.5;
  static const double threadFoot = 4;

  /// The chips: 24 tall, 10 in, 12 corners, 6 apart.
  static const double chip = 24;
  static const double chipPad = 10;
  static const double chipGap = 6;

  /// The sentence: 18 corners, 14 by 12 in.
  static const double sentenceRadius = 18;
  static const EdgeInsets sentencePad = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  /// The carry card: 18 corners, 14 by 12 in, 10 above its buttons, 8
  /// between them; Place 40 with 18 in, Leave in Inbox 14 in.
  static const double carryRadius = 18;
  static const EdgeInsets carryPad = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const double carryActionsTop = 10;
  static const double carryButtonGap = 8;
  static const double carryButton = 40;
  static const double carryPlacePad = 18;
  static const double carryInboxPad = 14;

  /// The share image: 22 corners, 18 in; 12 above the rings, 4 to their
  /// letters, 14 above "dottoday".
  static const double shareRadius = 22;
  static const double sharePad = 18;
  static const double shareRingsTop = 12;
  static const double shareLetterGap = 4;
  static const double shareNameTop = 14;

  /// The titles switch row 44 tall, 10 above; Share image 50 tall, 6
  /// above, an 18 glyph 8 before its words.
  static const double switchRow = 44;
  static const double switchTop = 10;
  static const double shareButton = 50;
  static const double shareButtonTop = 6;
  static const double shareGlyph = 18;
  static const double shareGlyphGap = 8;
}

/// This week's type: the board's system face (Manrope for the share
/// image's caption, letters and name).
abstract final class WeekType {
  static TextStyle _sys(DotType t, double size, double height, int w) =>
      t.caption.copyWith(
        fontSize: size,
        height: height / size,
        fontWeight: FontWeight.values[(w ~/ 100) - 1],
      );

  /// "November 2 – November 8": 500 14 secondary.
  static TextStyle range(DotType t, DotColors c) =>
      _sys(t, 14, 20, 500).copyWith(color: c.muted);

  /// A day's letter (600 12 secondary) and count (600 12 ink 2).
  static TextStyle letter(DotType t, DotColors c) =>
      _sys(t, 12, 16, 600).copyWith(color: c.muted);
  static TextStyle count(DotType t, DotColors c) =>
      _sys(t, 12, 16, 600).copyWith(color: c.ink2);

  /// The open day's tasks: title 600 14, time 500 12, the planned line
  /// 600 12.5, all secondary but the open title.
  static TextStyle task(DotType t, DotColors c, {required bool done}) =>
      _sys(t, 14, 20, 600).copyWith(
        color: done ? c.muted : c.text,
        decoration: done ? TextDecoration.lineThrough : null,
        decorationColor: c.muted,
      );
  static TextStyle time(DotType t, DotColors c) =>
      _sys(t, 12, 16, 500).copyWith(color: c.muted);
  static TextStyle foot(DotType t, DotColors c) =>
      _sys(t, 12.5, 18, 600).copyWith(color: c.muted);

  /// A chip: 700 12 in ink.
  static TextStyle chip(DotType t, DotColors c) =>
      _sys(t, 12, 16, 700).copyWith(color: c.text);

  /// The sentence: 600 15/21 in the accent's ink.
  static TextStyle sentence(DotType t, DotColors c) =>
      _sys(t, 15, 21, 600).copyWith(color: c.accentInk);

  /// The carry question: 600 15; its buttons 700 14 in the app's button
  /// face (as every E button).
  static TextStyle carry(DotType t, DotColors c) =>
      _sys(t, 15, 21, 600).copyWith(color: c.text);
  static TextStyle carryButton(DotType t) => t.button.copyWith(fontSize: 14);

  /// The share image: "NOV 2 – NOV 8" Manrope 800 11 tracked 1, the
  /// letters 700 11, "dottoday" 800 14 in the accent.
  static TextStyle shareRange(DotType t, DotColors c) => t.rowMeta.copyWith(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation.weight(800)],
    letterSpacing: 1,
    color: c.muted,
  );
  static TextStyle shareLetter(DotType t, DotColors c) => t.rowMeta.copyWith(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w700,
    fontVariations: const [FontVariation.weight(700)],
    color: c.muted,
  );
  static TextStyle shareName(DotType t, DotColors c) => t.rowMeta.copyWith(
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation.weight(800)],
    color: c.accent,
  );
  static TextStyle shareTitles(DotType t, DotColors c) =>
      t.rowMeta.copyWith(color: c.text);

  /// "Show task titles" 500 16; Share image 700 16; the closing line 500
  /// 13 secondary.
  static TextStyle switchLabel(DotType t, DotColors c) =>
      _sys(t, 16, 22, 500).copyWith(color: c.text);
  static TextStyle shareButton(DotType t) => t.button.copyWith(fontSize: 16);
  static TextStyle closing(DotType t, DotColors c) =>
      _sys(t, 13, 18, 500).copyWith(color: c.muted);
}

/// This week's colours.
abstract final class WeekColors {
  /// The ring's track: the accent at 20 % (`#11615C33`).
  static Color track(DotColors c) => c.accent.withValues(alpha: 0.2);

  /// A chip's fill: the control colour (`#ECE5DC`).
  static Color chip(DotColors c) => c.control;
}
