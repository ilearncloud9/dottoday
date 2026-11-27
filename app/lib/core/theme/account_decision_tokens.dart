import 'package:dottoday/core/theme/account_tokens.dart';
import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/dot_type.dart';
import 'package:flutter/painting.dart';

/// The account decisions, B1 "Which settings should Dottoday use?" (E-CR160
/// `SettingsChoice`, `AndroidB1`, `TabletB1`, `AndroidTabletB1`,
/// `DesktopB1`; ED-494) and G1/G1b "This device has tasks made without an
/// account" (`GuestWork`, `GuestWorkLocked`; elsewhere as B1, ED-495).
abstract final class AccountDecisionSize {
  /// Phones: iPhone 20 from the sides, 12 under the status bar, 36 below;
  /// Android 16 (the words 8 further in), 28 and 32.
  static const EdgeInsets padIphone = EdgeInsets.fromLTRB(20, 12, 20, 36);
  static const EdgeInsets padAndroid = EdgeInsets.fromLTRB(16, 28, 16, 32);
  static const double wordsInsetAndroid = 8;

  /// The centred column: 680 on tablets, 580 on the Mac and web.
  static const double tabletColumn = 680;
  static const double desktopColumn = 580;

  /// Two cards side by side once each can have this (tablets, Mac/web).
  static const double cardMinTablet = 280;
  static const double cardMinDesktop = 260;

  /// Between blocks: 18 on iPhone and iPad, 16 on Android and Mac/web;
  /// 8 between the title and the body; 12 between the cards.
  static const double gap = 18;
  static const double gapCompact = 16;
  static const double headGap = 8;
  static const double cardGap = 12;

  /// Above the end-aligned buttons (tablets, Mac/web).
  static const double actionsTop = 4;

  /// Continue's and Decide later's side padding on tablets: iPad 28 / 22,
  /// Android 24 / 16 (Mac/web: the usual 18).
  static const double continuePadIpad = 28;
  static const double laterPadIpad = 22;
  static const double continuePadAndroid = 24;
  static const double laterPadAndroid = 16;

  /// A card: 16 in, 12 between its head and rows, a 2 outline.
  static const double cardPad = 16;
  static const double cardInner = 12;
  static const double cardOutline = 2;

  /// G1's cards (`GuestWork`): the mark 1 below the title's top; 4
  /// between the title, the line and the box; the box row 44 tall, 6
  /// above, 10 between the box and its words.
  static const double markTop = 1;
  static const double cardLines = 4;
  static const double boxRow = 44;
  static const double boxTop = 6;
  static const double boxGap = 10;

  /// Corners 22 (iPhone, iPad), 20 (Android), 18 (Mac/web).
  static double radius(AccountDialogLook look) => switch (look) {
    AccountDialogLook.iphone => 22,
    AccountDialogLook.android => 20,
    AccountDialogLook.desktop => 18,
  };

  /// The radio: 22, 20, 18; 12 (Mac/web 10) before the title.
  static double radio(AccountDialogLook look) => switch (look) {
    AccountDialogLook.iphone => 22,
    AccountDialogLook.android => 20,
    AccountDialogLook.desktop => 18,
  };
  static double radioGap(AccountDialogLook look) =>
      look == AccountDialogLook.desktop ? 10 : 12;

  /// The head row's touch height: 44 on iPad and iPhone, 48 on Android.
  static double headMin(AccountDialogLook look) => switch (look) {
    AccountDialogLook.iphone => 44,
    AccountDialogLook.android => 48,
    AccountDialogLook.desktop => 0,
  };

  /// The rows' label column at least 112 on iPhone, 104 on Android and
  /// tablets, 84 on the Mac and web; 8 between rows (Mac/web 6).
  static double labelMin(AccountDialogLook look, {required bool phone}) =>
      switch (look) {
        AccountDialogLook.iphone => phone ? 112 : 104,
        AccountDialogLook.android => 104,
        AccountDialogLook.desktop => 84,
      };
  static double rowGap(AccountDialogLook look) =>
      look == AccountDialogLook.desktop ? 6 : 8;
  static const double columnGap = 8;
}

/// B1's type.
abstract final class AccountDecisionType {
  /// 22/28 700 −0.2 (iPhone, iPad, Mac/web), 24/32 700 on Android.
  static TextStyle title(DotType t, AccountDialogLook look) =>
      look == AccountDialogLook.android
      ? t.promptTitle.copyWith(fontSize: 24, height: 32 / 24)
      : t.promptTitle.copyWith(letterSpacing: -0.2);

  /// Secondary: 15/22 on iPhone and iPad, 14/20 Android, 14/21 Mac/web.
  static TextStyle body(DotType t, DotColors c, AccountDialogLook look) {
    final base = t.body.copyWith(color: c.muted);
    return switch (look) {
      AccountDialogLook.iphone => base,
      AccountDialogLook.android => base.copyWith(fontSize: 14, height: 20 / 14),
      AccountDialogLook.desktop => base.copyWith(fontSize: 14, height: 21 / 14),
    };
  }

  /// A card's title: 17, 16, 15, all 700.
  static TextStyle cardTitle(DotType t, AccountDialogLook look) =>
      t.choiceTitle.copyWith(
        fontSize: switch (look) {
          AccountDialogLook.iphone => 17,
          AccountDialogLook.android => 16,
          AccountDialogLook.desktop => 15,
        },
        height: 22 / 17,
      );

  /// A row: 14/20 (Mac/web 13.5/20); the label in secondary.
  static TextStyle row(DotType t, AccountDialogLook look) => t.body.copyWith(
    fontSize: look == AccountDialogLook.desktop ? 13.5 : 14,
    height: look == AccountDialogLook.desktop ? 20 / 13.5 : 20 / 14,
  );
}

/// Settings › Account's Sync block and "Choose settings" row (E-CR160
/// `AccountChoose`, `AndroidAccountChoose`, `TabletAccountChoose`,
/// `AndroidTabletAccountChoose`, `DesktopAccountChoose`; ED-494).
abstract final class AccountSyncSize {
  /// iPhone and iPad: the Sync card, 20 corners, 16 in, 12 between lines;
  /// the tick 16, 8 before "Synced".
  static const double cardRadius = 20;
  static const double cardPad = 16;
  static const double cardGap = 12;
  static const double tick = 16;
  static const double tickGap = 8;

  /// Android: 8 under the caption, 4 between lines.
  static const double androidHeadPad = 8;
  static const double androidGap = 4;

  /// The row: iPhone/iPad a 64 card, 12 by 16 in, 20 corners, chevron 16;
  /// Android a 72 list row on the page's margin, chevron 24; Mac/web a
  /// 56 card up to 520, 10 by 16, 14 corners, a 1 ring, chevron 14.
  static const double rowIphone = 64;
  static const double rowAndroid = 72;
  static const double rowDesktop = 56;
  static const double rowDesktopMax = 520;
  static const double rowRadius = 20;
  static const double rowRadiusDesktop = 14;
  static const EdgeInsets rowPadIphone = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  // The page's own margin stands in for the board's 16, so the row lines
  // up with "Signed in as …".
  static const EdgeInsets rowPadAndroid = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets rowPadDesktop = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );
  static const double rowGap = 12;
  static const double rowGapAndroid = 16;
  static const double chevronIphone = 16;
  static const double chevronAndroid = 24;
  static const double chevronDesktop = 14;
  static const double rowRing = 1;

  /// Between the row's title and its line.
  static const double rowLines = 2;
}

/// The Sync block's and the row's type.
abstract final class AccountSyncType {
  /// "Signed in as …": 15 (iPhone, iPad, Mac/web), 16/24 on Android.
  static TextStyle who(DotType t, AccountDialogLook look) =>
      look == AccountDialogLook.android
      ? t.body.copyWith(fontSize: 16, height: 24 / 16)
      : t.body;

  /// "Synced" / "3 changes waiting to sync": 14/20 secondary.
  static TextStyle status(DotType t, DotColors c) =>
      t.body.copyWith(fontSize: 14, height: 20 / 14, color: c.muted);

  /// The row's title: 16/22 700 (Android 16/24 600, Mac/web 14/20 700).
  static TextStyle rowTitle(DotType t, AccountDialogLook look) =>
      switch (look) {
        AccountDialogLook.iphone => t.body.copyWith(
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w700,
          fontVariations: const [FontVariation.weight(700)],
        ),
        AccountDialogLook.android => t.body.copyWith(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w600,
          fontVariations: const [FontVariation.weight(600)],
        ),
        AccountDialogLook.desktop => t.body.copyWith(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w700,
          fontVariations: const [FontVariation.weight(700)],
        ),
      };

  /// The row's line: 14/20 secondary (Mac/web 13/19).
  static TextStyle rowLine(DotType t, DotColors c, AccountDialogLook look) =>
      look == AccountDialogLook.desktop
      ? t.body.copyWith(fontSize: 13, height: 19 / 13, color: c.muted)
      : status(t, c);
}
