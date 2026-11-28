import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Next free slot today: 11:00–11:45 AM · fits Buy a birthday gift"
/// (E-R2-13, ED-295): a tinted line over the Inbox's rows. Placing is
/// each row's Place, so the line only says where the time is.
class NextFreeSlot extends StatelessWidget {
  const NextFreeSlot({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.tonal,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.m,
          vertical: DotSpace.s,
        ),
        child: Text(
          text,
          style: t.styles.rowMeta.copyWith(
            color: c.accentText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
