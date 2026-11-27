import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A full-screen account decision on a phone (E-CR160 A3, B1): [head] at
/// the top, or in the middle of the free space when [centred], and [foot]
/// at the bottom; it all scrolls when it doesn't fit (200 % text, small
/// phones). The padding sits inside the fill, so the foot's margin is
/// kept rather than scrolled past.
class AccountPhoneFrame extends StatelessWidget {
  const AccountPhoneFrame({
    required this.padding,
    required this.head,
    required this.foot,
    this.gap = 0,
    this.centred = false,
    super.key,
  });

  final EdgeInsets padding;
  final List<Widget> head;
  final Widget foot;

  /// Between the [head]'s children, and kept between them and [foot].
  final double gap;
  final bool centred;

  @override
  Widget build(BuildContext context) {
    final top = Column(
      mainAxisAlignment: centred
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: head,
    );
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    // Keeps the words clear of the foot when it scrolls,
                    // without moving a centred head.
                    padding: EdgeInsets.only(
                      top: centred ? gap : 0,
                      bottom: gap,
                    ),
                    child: top,
                  ),
                ),
                foot,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tablets, the Mac and the web: one [width] column, [children] [gap]
/// apart, in the middle of the window; it scrolls when it doesn't fit.
class AccountCentredColumn extends StatelessWidget {
  const AccountCentredColumn({
    required this.width,
    required this.gap,
    required this.children,
    super.key,
  });

  final double width;
  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: DotSpace.xl),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: (box.maxHeight - 2 * DotSpace.xl).clamp(0, 1e9),
        ),
        child: Center(
          child: SizedBox(
            width: width.clamp(0, box.maxWidth - 2 * DotSpace.page),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap,
              children: children,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Buttons and their notes stacked full width: 10 apart on iPhone, 8 on
/// Android (A3, B1 on phones).
class AccountButtonStack extends StatelessWidget {
  const AccountButtonStack({
    required this.look,
    required this.children,
    super.key,
  });

  final AccountDialogLook look;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: look == AccountDialogLook.android
        ? AccountDialogSize.buttonGapAndroid
        : AccountDialogSize.buttonGap,
    children: children,
  );
}
