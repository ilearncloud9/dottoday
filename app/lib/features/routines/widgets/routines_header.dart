import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/chips/count_pill.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Routines page's top (E-R2-22): on phones "‹ Planning" over the
/// tile and the large title on the iPhone, ← beside them on Android; on
/// tablets, the Mac and the web (a sidebar destination) no back, and the
/// subtitle carries the number of routines.
class RoutinesHeader extends StatelessWidget {
  const RoutinesHeader({
    required this.count,
    required this.wide,
    this.pill = false,
    super.key,
  });

  final int count;
  final bool wide;

  /// The count in a pill beside the title (E-R2-30, ED-500), not in the
  /// subtitle: Routines as its own place on the Mac and the web.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    final title = Semantics(
      header: true,
      child: Text(
        l10n.routinesTitle,
        style: ios
            ? t.styles.dayTitle
            : (wide ? t.styles.pageTitle : t.styles.topBarTitle),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.xs,
      children: [
        if (!wide && ios) const _BackToPlanning(),
        Row(
          spacing: DotSpace.s + DotSpace.xxs,
          children: [
            if (!wide && !ios)
              IconButton(
                tooltip: l10n.settingsBack,
                onPressed: () => _back(context),
                icon: DotIcon(DotGlyphs.arrowLeft, color: t.colors.ink),
              ),
            const _Tile(),
            Flexible(child: title),
          ],
        ),
        if (pill)
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.routinesSubtitle,
                  style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
                ),
              ),
              CountPill(l10n.routinesCount(count)),
            ],
          )
        else
          Text(
            wide
                ? l10n.routinesSubtitleCount(
                    l10n.routinesSubtitle,
                    l10n.routinesCount(count),
                  )
                : l10n.routinesSubtitle,
            style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
          ),
      ],
    );
  }
}

/// Back, also when the page was opened by a link.
void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(AppRoutes.settings);

/// The iPhone's "‹ Planning": Routines lives in Settings › Planning.
class _BackToPlanning extends StatelessWidget {
  const _BackToPlanning();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: context.l10n.settingsPlanning,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _back(context),
        borderRadius: BorderRadius.circular(DotRadii.sidebarRow),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.min),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DotIcon(
                DotGlyphs.chevronLeft,
                color: t.colors.accentText,
                size: DotSize.rowIcon,
              ),
              Text(
                context.l10n.settingsPlanning,
                style: t.styles.body.copyWith(color: t.colors.accentText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The repeat glyph on the accent's tint.
class _Tile extends StatelessWidget {
  const _Tile();

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return ExcludeSemantics(
      child: Container(
        width: DotSize.pageTile,
        height: DotSize.pageTile,
        decoration: BoxDecoration(
          color: c.tonal,
          borderRadius: BorderRadius.circular(DotRadii.sidebarRow),
        ),
        alignment: Alignment.center,
        child: DotIcon(
          DotGlyphs.repeat,
          color: c.accentText,
          size: DotSize.rowIcon,
        ),
      ),
    );
  }
}

/// "+ New routine / or save a selection from any day" as a card.
class NewRoutineCard extends StatelessWidget {
  const NewRoutineCard({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.routineNew,
      hint: l10n.routineNewHint,
      excludeSemantics: true,
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.cardLarge),
          side: BorderSide(color: c.hairline, width: DotSpace.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.m),
            child: Row(
              spacing: DotSpace.m,
              children: [
                Container(
                  width: DotSize.pageTile,
                  height: DotSize.pageTile,
                  decoration: BoxDecoration(
                    color: c.tonal,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: DotIcon(
                    DotGlyphs.add,
                    color: c.accentText,
                    size: DotSize.rowIcon,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.routineNew,
                        style: t.styles.cardTitle.copyWith(color: c.accentText),
                      ),
                      Text(
                        l10n.routineNewHint,
                        style: t.styles.rowMeta.copyWith(color: c.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
