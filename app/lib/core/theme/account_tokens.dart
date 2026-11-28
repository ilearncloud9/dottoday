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
  static const double outlineAndroid = 1;

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
      c.brightness == Brightness.dark ? c.tile : c.card;

  /// The outlined button's ring: `#DDD7E0`/`#CFC6D6` light, `#8C838A`
  /// dark.
  static Color outline(DotColors c) =>
      c.brightness == Brightness.dark ? c.ring : c.controlOutline;
}

/// A3 "You're signed out" (E-CR160 `SignedOut`, `AndroidA3`, `TabletA3`,
/// `AndroidTabletA3`, `DesktopA3`): sizes, type and colours.
abstract final class SignedOutSize {
  /// Phone sides and foot: iPhone 28 and 44, Android 24 and 40.
  static const EdgeInsets padIphone = EdgeInsets.fromLTRB(28, 0, 28, 44);
  static const EdgeInsets padAndroid = EdgeInsets.fromLTRB(24, 0, 24, 40);

  /// The centred column: 440 on tablets, 400 on the Mac and web.
  static const double tabletColumn = 440;
  static const double desktopColumn = 400;

  /// Between the art, title and body: 20; Mac/web 16.
  static const double gap = 20;
  static const double gapDesktop = 16;

  /// Above the buttons when they follow the body (tablets, Mac/web).
  static const double actionsTop = 8;

  /// The art: 96, 80 on the Mac and web. At 96: a ring 90 across drawn
  /// 10 wide, a 60 inner disc, the lock 30 (its 2.5 stroke).
  static const double art = 96;
  static const double artDesktop = 80;
  static const double artRing = 90 / 96;
  static const double artRingStroke = 10 / 96;
  static const double artInner = 60 / 96;
  static const double artLock = 30 / 96;
}

/// A3's type (Manrope 800 titles; body and note in secondary).
abstract final class SignedOutType {
  /// 28/34 800 −0.5 on iPhone and iPad, 28/36 on Android, 24/30 −0.4 on
  /// the Mac and web.
  static TextStyle title(DotType t, AccountDialogLook look) {
    final base = t.promptTitle.copyWith(
      fontWeight: FontWeight.w800,
      fontVariations: const [FontVariation.weight(800)],
    );
    return switch (look) {
      AccountDialogLook.iphone => base.copyWith(
        fontSize: 28,
        height: 34 / 28,
        letterSpacing: -0.5,
      ),
      AccountDialogLook.android => base.copyWith(
        fontSize: 28,
        height: 36 / 28,
        letterSpacing: -0.5,
      ),
      AccountDialogLook.desktop => base.copyWith(
        fontSize: 24,
        height: 30 / 24,
        letterSpacing: -0.4,
      ),
    };
  }

  /// 15/22 on iPhone and iPad, 14/20 on Android, 14/21 Mac/web.
  static TextStyle body(DotType t, DotColors c, AccountDialogLook look) {
    final base = t.body.copyWith(color: c.secondary);
    return switch (look) {
      AccountDialogLook.iphone => base,
      AccountDialogLook.android => base.copyWith(fontSize: 14, height: 20 / 14),
      AccountDialogLook.desktop => base.copyWith(fontSize: 14, height: 21 / 14),
    };
  }
}

/// A3's art: the ring (`#EDE7DF` / `#28232A`) and the inner disc
/// (`#F6F1EA` / `#1F1B1E`).
abstract final class SignedOutColors {
  static Color ring(DotColors c) =>
      c.brightness == Brightness.dark ? c.card : c.chip;
  static Color inner(DotColors c) => c.sunk;
}
