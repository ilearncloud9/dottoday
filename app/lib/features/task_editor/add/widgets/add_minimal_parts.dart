import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/landing_strip.dart';
import 'package:dottoday/shared/sheets/sheet_nav_bar.dart';
import 'package:flutter/material.dart';

/// Minimal Add's top (E-PhonesMinimal): on the iPhone a sheet's nav bar,
/// Cancel · "New task" · Add; on Android the M3 sheet's title "Add a
/// task" (its Add is at the foot, [AddMinimalFoot]).
class AddMinimalHeader extends StatelessWidget {
  const AddMinimalHeader({
    required this.android,
    required this.onCancel,
    required this.onAdd,
    super.key,
  });

  final bool android;
  final VoidCallback onCancel;

  /// Null while there is nothing to add.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    if (android) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          DotSpace.page,
          DotSpace.s,
          DotSpace.page,
          DotSpace.s,
        ),
        child: Semantics(
          header: true,
          child: Text(
            l10n.addMinimalTitleAndroid,
            style: t.styles.sheetTitleAndroid,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
      child: SheetNavBar(
        title: l10n.addMinimalTitle,
        actionLabel: l10n.addAdd,
        onCancel: onCancel,
        onAction: onAdd,
      ),
    );
  }
}

/// The when and length chips (docs/14 §4), "Today 6:00 PM" with its clock
/// and "1 h"; either opens the When step, so neither is a dead end. On
/// the iPhone, More (the detailed Create task) at the row's end.
class AddQuickChips extends StatelessWidget {
  const AddQuickChips({
    required this.when,
    required this.length,
    required this.onWhen,
    this.onMore,
    super.key,
  });

  /// Null until the day's free time is known.
  final String? when;
  final String length;
  final VoidCallback onWhen;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final chips = [
      if (when case final w?)
        ActionChip(
          avatar: DotIcon(DotGlyphs.clock, color: t.colors.accentText),
          label: Text(w),
          onPressed: onWhen,
        ),
      ActionChip(label: Text(length), onPressed: onWhen),
    ];
    final more = switch (onMore) {
      final m? => TextButton(onPressed: m, child: Text(l10n.moreOptions)),
      null => null,
    };
    // At large text everything wraps, so no chip is cut (200 %).
    if (MediaQuery.textScalerOf(context).scale(1) > 1.5) {
      return Wrap(
        spacing: DotSpace.s,
        runSpacing: DotSpace.s,
        children: [...chips, ?more],
      );
    }
    return Row(
      spacing: DotSpace.s,
      children: [
        Expanded(
          child: Wrap(
            spacing: DotSpace.s,
            runSpacing: DotSpace.s,
            children: chips,
          ),
        ),
        ?more,
      ],
    );
  }
}

/// "Lands at 6:00–7:00 PM · free, no overlap" over the mini horizon.
class AddLandsAt extends StatelessWidget {
  const AddLandsAt({
    required this.range,
    required this.fit,
    required this.strip,
    super.key,
  });

  /// "6:00–7:00 PM", bold.
  final String range;

  /// "free, no overlap" or "overlaps Lunch".
  final String fit;
  final LandingStrip strip;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final bold = t.styles.rowMeta.copyWith(
      color: t.colors.ink,
      fontWeight: FontWeight.w700,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: l10n.addLandsAt(range), style: bold),
              TextSpan(text: l10n.sheetLeftSuffix(fit)),
            ],
          ),
          style: t.styles.rowMeta,
        ),
        strip,
      ],
    );
  }
}

/// The iPhone's line under the preview: several lines open a plan first.
class AddManyHint extends StatelessWidget {
  const AddManyHint({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.m,
      children: [
        DotIcon(
          DotGlyphs.list,
          color: t.colors.accentText,
          size: DotSize.rowIcon,
        ),
        Expanded(
          child: Text(context.l10n.addSeveralLines, style: t.styles.rowMeta),
        ),
      ],
    );
  }
}

/// Android's foot: More options, then Add (E-PhonesMinimal frame 6).
class AddMinimalFoot extends StatelessWidget {
  const AddMinimalFoot({required this.onMore, required this.onAdd, super.key});

  final VoidCallback? onMore;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Material's own: Add drops under More options when they don't fit
    // side by side (200 % text).
    return OverflowBar(
      alignment: MainAxisAlignment.spaceBetween,
      overflowAlignment: OverflowBarAlignment.end,
      overflowSpacing: DotSpace.s,
      children: [
        TextButton(onPressed: onMore, child: Text(l10n.createMore)),
        FilledButton(onPressed: onAdd, child: Text(l10n.addAdd)),
      ],
    );
  }
}
