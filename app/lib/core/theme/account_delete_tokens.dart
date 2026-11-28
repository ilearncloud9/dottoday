import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/dot_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// D1 "Delete your account?" (E-CR160 `DeleteNative` on phones,
/// `DeleteWeb` as a dialog on wider windows; ED-495).
abstract final class DeleteSize {
  /// Phones: 20 from the sides, 8 under the status bar, 32 below; 16
  /// between blocks.
  static const EdgeInsets padPhone = EdgeInsets.fromLTRB(20, 8, 20, 32);
  static const double gap = 16;

  /// The dialog: 480 wide (the Mac/web board; tablets centre the phone's
  /// sizes at the same width).
  static const double dialogWidth = 480;

  /// "Export my data first" and its hint: 6 apart (the hint 4 in) on
  /// phones; side by side, 12 apart, in the dialog. The phone's pill is 48.
  static const double exportGap = 6;
  static const double exportHintInset = 4;
  static const double exportRowGap = 12;
  static const double exportPhone = 48;

  /// What goes: phones a card (22 corners, 16 by 14 in, 8 between the
  /// caption and the words); the dialog a sunk box (14 corners, 14 by 12).
  static const double summaryRadius = 22;
  static const EdgeInsets summaryPad = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );
  static const double summaryGap = 8;
  static const double summaryRadiusDialog = 14;
  static const EdgeInsets summaryPadDialog = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  /// "Type DELETE to confirm": 6 above the field; the field 48 tall, 16
  /// corners, 14 in on phones; 40, 12 and 12 in the dialog; a 1.5 ring.
  static const double fieldGap = 6;
  static const double field = 48;
  static const double fieldDialog = 40;
  static const double fieldRadius = 16;
  static const double fieldRadiusDialog = 12;
  static const double fieldPad = 14;
  static const double fieldPadDialog = 12;
  static const double fieldOutline = 1.5;

  /// 4 above the dialog's buttons.
  static const double buttonsTop = 4;
}

/// D1's type.
abstract final class DeleteType {
  /// "Removed from this device": 13/700 secondary (the board's caption, in
  /// E's sentence case).
  static TextStyle caption(DotType t, DotColors c) => t.caption.copyWith(
    fontWeight: FontWeight.w700,
    fontVariations: const [FontVariation.weight(700)],
    color: c.secondary,
  );

  /// What goes, and the field's label: 14/20 (dialog 13.5/20); the label
  /// in ink 2.
  static TextStyle line(DotType t, {required bool dialog}) => t.body.copyWith(
    fontSize: dialog ? 13.5 : 14,
    height: dialog ? 20 / 13.5 : 20 / 14,
  );

  /// The typed word: 16 on phones, 14 in the dialog.
  static TextStyle field(DotType t, {required bool dialog}) =>
      t.body.copyWith(fontSize: dialog ? 14 : 16);
}

/// D1's colours from the palette's roles.
abstract final class DeleteColors {
  /// The phone's summary card: `#FFFDF9` / `#1F1B1E`.
  static Color card(DotColors c) =>
      c.brightness == Brightness.dark ? c.sunk : c.card;

  /// The dialog's summary box: `#F6F1EA` / `#28232A`.
  static Color box(DotColors c) =>
      c.brightness == Brightness.dark ? c.card : c.sunk;

  /// The field: phones `#F6F1EA` / `#28232A`; the dialog `#FFFDF9` /
  /// `#1F1B1E`.
  static Color field(DotColors c, {required bool dialog}) =>
      dialog ? card(c) : box(c);
}

/// "Removal from this browser didn't finish" (E-CR160 `DeleteWebRetry`;
/// ED-495): a 480 card, 20 corners, 28 in, 14 between lines.
abstract final class RemovalRetrySize {
  static const double width = 480;
  static const double radius = 20;
  static const double pad = 28;
  static const double gap = 14;
  static const double buttonsTop = 4;
}

/// The retry card's type: title 20/26 700; body 14/21 in ink 2.
abstract final class RemovalRetryType {
  static TextStyle title(DotType t) =>
      t.promptTitle.copyWith(fontSize: 20, height: 26 / 20);

  static TextStyle body(DotType t, DotColors c) =>
      t.body.copyWith(fontSize: 14, height: 21 / 14, color: c.ink2);
}
