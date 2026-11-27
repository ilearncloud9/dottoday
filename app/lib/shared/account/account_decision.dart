import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:dottoday/shared/account/account_page_frame.dart';
import 'package:flutter/material.dart';

/// Where an account decision is shown: [look] picks the board's sizes;
/// [phone] the phone frame (compact width) over the centred column.
typedef AccountDecisionPlace = ({AccountDialogLook look, bool phone});

/// The place for [context]: the Mac's and web's board at medium width and
/// up off touch, else iPhone's or Android's, centred on tablets (ED-365).
AccountDecisionPlace accountDecisionPlace(BuildContext context) => (
  look: accountDialogLook(context),
  phone: WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.compact,
);

/// A full-screen account decision as the E-CR160 boards draw B1 and G1
/// (ED-494, ED-495): [title] and [body], then [content]; on phones the
/// [buttons] stack at the foot (the last, the main one, on top) with
/// [hint] centred under them; on tablets (680) and the Mac and web (580)
/// one centred column with the [buttons] at the end, in order, and [hint]
/// aligned to the end.
class AccountDecision extends StatelessWidget {
  const AccountDecision({
    required this.place,
    required this.title,
    required this.body,
    required this.content,
    required this.buttons,
    this.hint,
    super.key,
  });

  final AccountDecisionPlace place;
  final String title;
  final String body;

  /// Between the words and the buttons: cards and their notes. Wrap text
  /// in [words] so Android phones inset it as drawn.
  final List<Widget> content;
  final List<Widget> buttons;
  final String? hint;

  /// [child] 8 further in than the cards on an Android phone
  /// (`AndroidB1`), as is everywhere else.
  static Widget words(AccountDecisionPlace place, Widget child) =>
      place.phone && place.look == AccountDialogLook.android
      ? Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AccountDecisionSize.wordsInsetAndroid,
          ),
          child: child,
        )
      : child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final look = place.look;
    final desktop = look == AccountDialogLook.desktop;
    final android = look == AccountDialogLook.android;
    final note = AccountDialogType.note(t.styles, look);
    final head = <Widget>[
      words(
        place,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AccountDecisionSize.headGap,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: AccountDecisionType.title(t.styles, look),
              ),
            ),
            Text(
              body,
              style: AccountDecisionType.body(t.styles, t.colors, look),
            ),
          ],
        ),
      ),
      ...content,
    ];
    final Widget page;
    if (place.phone) {
      page = AccountPhoneFrame(
        padding: android
            ? AccountDecisionSize.padAndroid
            : AccountDecisionSize.padIphone,
        gap: android ? AccountDecisionSize.gapCompact : AccountDecisionSize.gap,
        head: head,
        foot: AccountButtonStack(
          look: look,
          children: [
            ...buttons.reversed,
            if (hint case final h?)
              Text(h, textAlign: TextAlign.center, style: note),
          ],
        ),
      );
    } else {
      final gap = android
          ? AccountDialogSize.buttonGapAndroid
          : AccountDialogSize.buttonGap;
      page = AccountCentredColumn(
        width: desktop
            ? AccountDecisionSize.desktopColumn
            : AccountDecisionSize.tabletColumn,
        gap: desktop || android
            ? AccountDecisionSize.gapCompact
            : AccountDecisionSize.gap,
        children: [
          ...head,
          Padding(
            padding: const EdgeInsets.only(top: AccountDecisionSize.actionsTop),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: gap,
              runSpacing: gap,
              children: buttons,
            ),
          ),
          if (hint case final h?)
            Text(h, textAlign: TextAlign.end, style: note),
        ],
      );
    }
    return Material(
      color: t.colors.surface,
      child: SafeArea(child: page),
    );
  }
}

/// A button's side padding at the end of a centred decision: the
/// tablets' wider pills (`TabletB1`, `AndroidTabletB1`); the board's own
/// elsewhere (null). [main] is the filled one.
double? accountDecisionPad(AccountDecisionPlace place, {required bool main}) {
  if (place.phone) return null;
  return switch (place.look) {
    AccountDialogLook.iphone =>
      main
          ? AccountDecisionSize.continuePadIpad
          : AccountDecisionSize.laterPadIpad,
    AccountDialogLook.android =>
      main
          ? AccountDecisionSize.continuePadAndroid
          : AccountDecisionSize.laterPadAndroid,
    AccountDialogLook.desktop => null,
  };
}
