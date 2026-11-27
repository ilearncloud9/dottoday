import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Which E-CR160 board a dialog follows here: the Mac's and the web's at
/// medium width and up; otherwise the phone's, iPhone or Android, which
/// the iPad and Android tablets centre at their width (ED-365).
AccountDialogLook accountDialogLook(BuildContext context) {
  final wide =
      WidthClass.of(MediaQuery.sizeOf(context).width) != WidthClass.compact;
  if (wide && !touchApp(context)) return AccountDialogLook.desktop;
  return DotIdiom.of(context) == DotIdiom.cupertino
      ? AccountDialogLook.iphone
      : AccountDialogLook.android;
}

/// An E-CR160 dialog (A1, A2) in [look]: [children] [AccountDialogSize.gap]
/// apart, scrolling inside the dialog at large text. [plain] is A1, which
/// Android's tablet draws 400 wide and with 16 below its buttons.
class AccountDialog extends StatelessWidget {
  const AccountDialog({
    required this.look,
    required this.children,
    this.plain = false,
    this.width,
    super.key,
  });

  final AccountDialogLook look;
  final bool plain;

  /// A board's own width on tablets and the Mac/web (D1: 480).
  final double? width;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final compact =
        WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.compact;
    final desktop = look == AccountDialogLook.desktop;
    final android = look == AccountDialogLook.android;
    final width =
        this.width ??
        (android && plain
            ? AccountDialogSize.widthAndroidPlain
            : AccountDialogSize.width);
    return Dialog(
      backgroundColor: AccountDialogColors.fill(c),
      insetPadding: EdgeInsets.symmetric(
        horizontal: android
            ? AccountDialogSize.insetAndroid
            : AccountDialogSize.insetIphone,
        vertical: DotSpace.xl,
      ),
      constraints: compact
          ? const BoxConstraints()
          : BoxConstraints.tightFor(width: width),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          desktop ? AccountDialogSize.radiusDesktop : AccountDialogSize.radius,
        ),
      ),
      child: SingleChildScrollView(
        padding: switch (look) {
          AccountDialogLook.iphone => AccountDialogSize.padIphone,
          AccountDialogLook.android =>
            plain
                ? AccountDialogSize.padAndroidPlain
                : AccountDialogSize.padAndroid,
          AccountDialogLook.desktop => AccountDialogSize.padDesktop,
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: desktop
              ? AccountDialogSize.gapDesktop
              : AccountDialogSize.gap,
          children: children,
        ),
      ),
    );
  }
}

enum _Kind { filled, outlined, tonal, tint, text }

/// A button of an E-CR160 dialog in [look]'s size and type: 52 pills on
/// iPhone, 48 on Android (Roboto 14/500), 40 on the Mac and web. Focus
/// shows the ED-174 ring.
class AccountButton extends StatelessWidget {
  const AccountButton.filled({
    required this.look,
    required this.label,
    required this.onPressed,
    this.autofocus = false,
    this.pad,
    super.key,
  }) : _kind = _Kind.filled;

  const AccountButton.outlined({
    required this.look,
    required this.label,
    required this.onPressed,
    this.autofocus = false,
    this.pad,
    super.key,
  }) : _kind = _Kind.outlined;

  /// Android's tonal pill (`AndroidA2` Stay signed in).
  const AccountButton.tonal({
    required this.look,
    required this.label,
    required this.onPressed,
    this.autofocus = false,
    this.pad,
    super.key,
  }) : _kind = _Kind.tonal;

  /// The accent's tint behind its ink (D1's "Export my data first").
  const AccountButton.tint({
    required this.look,
    required this.label,
    required this.onPressed,
    this.autofocus = false,
    this.pad,
    super.key,
  }) : _kind = _Kind.tint;

  /// Android's text button, in the accent's ink.
  const AccountButton.text({
    required this.look,
    required this.label,
    required this.onPressed,
    this.autofocus = false,
    this.pad,
    super.key,
  }) : _kind = _Kind.text;

  final AccountDialogLook look;
  final String label;
  final VoidCallback? onPressed;
  final bool autofocus;

  /// Side padding when a board sets its own (B1's tablet buttons).
  final double? pad;
  final _Kind _kind;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final android = look == AccountDialogLook.android;
    final (fill, ink) = switch (_kind) {
      _Kind.filled => (c.accentFill, c.onAccent),
      // Android's outlined button reads in the accent (`AndroidA3`).
      _Kind.outlined => (Colors.transparent, android ? c.accentInk : c.text),
      _Kind.tonal => (c.tonalAndroid, c.onTonalAndroid),
      _Kind.tint => (Color.alphaBlend(c.accentTint, c.raised), c.accentInk),
      _Kind.text => (Colors.transparent, c.accentInk),
    };
    final rest = _kind == _Kind.outlined
        ? BorderSide(
            color: AccountDialogColors.outline(c),
            width: android
                ? AccountDialogSize.outlineAndroid
                : AccountDialogSize.outline,
          )
        : BorderSide.none;
    final height = switch (look) {
      AccountDialogLook.iphone => AccountDialogSize.buttonIphone,
      AccountDialogLook.android => AccountDialogSize.buttonAndroid,
      AccountDialogLook.desktop => AccountDialogSize.buttonDesktop,
    };
    final pad =
        this.pad ??
        switch (look) {
          AccountDialogLook.desktop => AccountDialogSize.buttonPadDesktop,
          _ => AccountDialogSize.buttonPadAndroid,
        };
    final style = ButtonStyle(
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      minimumSize: WidgetStatePropertyAll(Size(height, height)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: pad)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStatePropertyAll(
        AccountDialogType.button(t.styles, look),
      ),
      // Disabled (Delete until the word is typed, a request in flight):
      // the control fill and secondary words, never the live colours.
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled) ? c.muted : ink,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled) && fill != Colors.transparent
            ? c.control
            : fill,
      ),
      elevation: const WidgetStatePropertyAll(0),
      side: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.focused)
            ? BorderSide(color: c.focus, width: DotSize.smallDotOutline)
            : rest,
      ),
    );
    return TextButton(
      style: style,
      autofocus: autofocus,
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
