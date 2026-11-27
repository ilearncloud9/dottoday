import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A3's art (E-CR160 `SignedOut`): an empty day ring with a lock, [size]
/// across. Decorative (ED-223): screen readers skip it.
class SignedOutArt extends StatelessWidget {
  const SignedOutArt({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * SignedOutSize.artRing,
                height: size * SignedOutSize.artRing,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SignedOutColors.ring(c),
                    width: size * SignedOutSize.artRingStroke,
                  ),
                ),
              ),
              Container(
                width: size * SignedOutSize.artInner,
                height: size * SignedOutSize.artInner,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SignedOutColors.inner(c),
                ),
              ),
              DotIcon(
                DotGlyphs.signedOutLock,
                color: c.muted,
                size: size * SignedOutSize.artLock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
