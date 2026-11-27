import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/dot_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Which board an account dialog follows (E-CR160, ED-222 to ED-230,
/// ED-365): the iPhone's (`SignOutPlain`, `Main`; the iPad's `TabletA1`,
/// `TabletA2` centre it at 440), Android's (`AndroidA1`, `AndroidA2`; the
/// tablet's at 400 / 440), or the Mac and web's (`DesktopA1`,
/// `DesktopA2`).
enum AccountDialogLook { iphone, android, desktop }

/// Sizes of the E-CR160 sign-out dialogs (A1, A2), named after the boards.
abstract final class AccountDialogSize {
  /// Phones: 20 from the screen's sides on iPhone, 24 on Android.
  static const double insetIphone = 20;
  static const double insetAndroid = 24;

  /// Tablets, the Mac and the web: a centred 440 (Android tablet A1: 400).
  static const double width = 440;
  static const double widthAndroidPlain = 400;

  /// Corners: 28 on phones and tablets, 20 on the Mac and web.
  static const double radius = 28;
  static const double radiusDesktop = 20;

  /// Padding: iPhone 28 24 20; Android 24 (A1: 16 below); Mac/web 24.
  static const EdgeInsets padIphone = EdgeInsets.fromLTRB(24, 28, 24, 20);
  static const EdgeInsets padAndroid = EdgeInsets.all(24);
  static const EdgeInsets padAndroidPlain = EdgeInsets.fromLTRB(24, 24, 24, 16);
  static const EdgeInsets padDesktop = EdgeInsets.all(24);

  /// Between the badge, title, body and buttons: 16; Mac/web 14.
  static const double gap = 16;
  static const double gapDesktop = 14;

  /// Above the buttons: 4 on iPhone, 8 on Android, 6 on the Mac and web.
  static const double actionsTopIphone = 4;
  static const double actionsTopAndroid = 8;
  static const double actionsTopDesktop = 6;

  /// Between buttons: 10 on iPhone and the Mac/web, 8 on Android.
  static const double buttonGap = 10;
  static const double buttonGapAndroid = 8;

  /// Buttons: 52 on iPhone, 48 on Android, 40 on the Mac and web.
  static const double buttonIphone = 52;
  static const double buttonAndroid = 48;
  static const double buttonDesktop = 40;

  /// Side padding inside a button: Android's text buttons 12, Mac/web 18.
  static const double buttonPadAndroid = 12;
  static const double buttonPadDesktop = 18;

  /// The outlined button's ring: 1.5 (Android's A3 outline is 1).
  static const double outline = 1.5;

  /// Android A2's cloud: 24.
  static const double androidIcon = 24;
}

/// The E-CR160 dialogs' type (Manrope; Android's buttons in Roboto).
abstract final class AccountDialogType {
  /// Title: 22/28 700 −0.2 on iPhone, 24/32 700 on Android, 18/23 700 on
  /// the Mac and web.
  static TextStyle title(DotType t, AccountDialogLook look) => switch (look) {
    AccountDialogLook.iphone => t.promptTitle.copyWith(letterSpacing: -0.2),
    AccountDialogLook.android => t.promptTitle.copyWith(
      fontSize: 24,
      height: 32 / 24,
    ),
    AccountDialogLook.desktop => t.promptTitle.copyWith(
      fontSize: 18,
      height: 23 / 18,
    ),
  };

  /// Body in ink 2: 15/22 on iPhone, 14/20 on Android, 14/21 Mac/web.
  static TextStyle body(DotType t, DotColors c, AccountDialogLook look) {
    final base = t.body.copyWith(color: c.ink2);
    return switch (look) {
      AccountDialogLook.iphone => base,
      AccountDialogLook.android => base.copyWith(fontSize: 14, height: 20 / 14),
      AccountDialogLook.desktop => base.copyWith(fontSize: 14, height: 21 / 14),
    };
  }

  /// Button labels: 16/700 on iPhone, 14/700 on the Mac and web, Roboto
  /// 14/500 on Android.
  static TextStyle button(DotType t, AccountDialogLook look) => switch (look) {
    AccountDialogLook.iphone => t.button.copyWith(fontSize: 16),
    AccountDialogLook.desktop => t.button.copyWith(fontSize: 14),
    AccountDialogLook.android => const TextStyle(
      // Named as the board does: Android's own Roboto (Material's
      // Typography names it the same way); the bundled copy on the web.
      fontFamily: kIsWeb ? DotType.webChromeFamily : 'Roboto',
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
    ),
  };

  /// The hint under Stay signed in (13/18) and Mac/web's Esc note
  /// (12.5/18), secondary.
  static TextStyle note(DotType t, AccountDialogLook look) =>
      look == AccountDialogLook.desktop
      ? t.rowMeta.copyWith(fontSize: 12.5, height: 18 / 12.5)
      : t.rowMeta;
}

/// The E-CR160 dialogs' colours, from the palette's roles.
abstract final class AccountDialogColors {
  /// The dialog: the card in light (`#FFFDF9`), the tile in dark
  /// (`#2F2A30`).
  static Color fill(DotColors c) =>
      c.brightness == Brightness.dark ? c.tile : c.raised;

  /// The outlined button's ring: `#DDD7E0`/`#CFC6D6` light, `#8C838A`
  /// dark.
  static Color outline(DotColors c) =>
      c.brightness == Brightness.dark ? c.ring : c.controlOutline;
}
