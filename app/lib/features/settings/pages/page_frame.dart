import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:dottoday/features/settings/panes/settings_pane_scope.dart';
import 'package:dottoday/features/settings/settings_places.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A Settings sub-page (docs/09 M3f.7): ‹ and the page title over the
/// same readable column as Settings, then [children] with group spacing.
/// With [page] the title wears the page's icon and ‹ names and returns to
/// its parent (M20.7 part 1, E-Phones Settings).
class SettingsPageFrame extends StatelessWidget {
  const SettingsPageFrame({
    required this.title,
    required this.children,
    this.page,
    this.singleGroup = false,
    this.pinned,
    this.form = false,
    super.key,
  });

  /// Drawn as a Mac/web form where [settingsFormFits] (ED-450): only the
  /// pages drawn that way say so; the others keep the phone rows there.
  final bool form;

  final String title;
  final List<Widget> children;
  final SettingsPage? page;

  /// One group under the title: its caption would repeat the title.
  final bool singleGroup;

  /// Stays under the title while the groups scroll (Appearance's live
  /// preview, ED-161); scrolls with them where the window is too short to
  /// spare the room.
  final Widget? pinned;

  /// Shorter than this, [pinned] scrolls with the page (a phone on its
  /// side, 200 % text).
  static const _pinFrom = 560.0;

  @override
  Widget build(BuildContext context) {
    const side = EdgeInsets.symmetric(horizontal: DotSpace.page);
    final asForm = form && settingsFormFits(context);
    final head = [
      _TitleRow(title: title, page: page, form: asForm),
      if (pinned case final p?) ...[const SizedBox(height: DotSpace.l), p],
    ];
    final groups = [
      for (final (i, child) in children.indexed) ...[
        const SizedBox(height: DotSpace.l),
        SettingsFormScope(
          form: asForm,
          first: i == 0,
          child: singleGroup
              ? SettingsCaptionScope(hidden: true, child: child)
              : child,
        ),
      ],
    ];
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: LayoutBuilder(
              builder: (context, box) {
                if (pinned == null || box.maxHeight < _pinFrom) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      DotSpace.page,
                      DotSpace.l,
                      DotSpace.page,
                      DotSpace.fabClearance,
                    ),
                    children: [...head, ...groups],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: side.copyWith(top: DotSpace.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: head,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: side.copyWith(bottom: DotSpace.fabClearance),
                        children: groups,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// ‹ and the page title: side by side while every word of the title fits
/// beside ‹; otherwise ‹ above and the title on the full width, so large
/// text wraps at spaces instead of breaking a word ("Notificatio / n
/// health" at 200 % on a 390 px phone). On iPhone a placed page has
/// "‹ Parent" above its icon and title, as UIKit's back button.
class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, this.page, this.form = false});

  final String title;
  final SettingsPage? page;

  /// A Mac/web form page: "‹ Parent" above the title, as on iPad (ED-450).
  final bool form;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final place = switch (page) {
      final p? => settingsPlace(context.l10n, p),
      null => null,
    };
    final heading = Semantics(
      header: true,
      child: Text(title, style: t.styles.pageTitle),
    );
    final icon = place == null
        ? null
        : SettingsIcon(glyph: place.glyph, tint: t.tasks[place.colour].ink);
    if (settingsDetailWithoutBack(context, page)) {
      return Row(
        spacing: DotSpace.m,
        children: [
          ?icon,
          Expanded(child: heading),
        ],
      );
    }
    if (place != null && (form || DotIdiom.of(context) == DotIdiom.cupertino)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ParentBack(label: _parentTitle(context, place), onTap: _onBack),
          Row(
            spacing: DotSpace.m,
            children: [
              ?icon,
              Expanded(child: heading),
            ],
          ),
        ],
      );
    }
    final back = IconButton(
      tooltip: place == null
          ? context.l10n.settingsBack
          : context.l10n.settingsBackTo(_parentTitle(context, place)),
      onPressed: () => _onBack(context),
      icon: DotIcon(DotGlyphs.arrowLeft, color: t.colors.text),
    );
    return LayoutBuilder(
      builder: (context, box) {
        final beside =
            box.maxWidth -
            kMinInteractiveDimension -
            DotSpace.m -
            (icon == null ? 0 : DotSize.rowDot + DotSpace.m);
        final lead = Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.m,
          children: [back, ?icon],
        );
        if (longestWordFits(context, title, t.styles.pageTitle, beside)) {
          return Row(
            spacing: DotSpace.m,
            children: [
              lead,
              Expanded(child: heading),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [lead, heading],
        );
      },
    );
  }

  String _parentTitle(BuildContext context, SettingsPlace place) =>
      switch (place.parent) {
        final p? => settingsPlace(context.l10n, p).title,
        null => context.l10n.navSettings,
      };

  /// Back to the parent page, also when the page was opened by a link.
  /// In two panes it always goes to the parent, so a page opened from
  /// the list never backs into the list's own root (part 5a).
  void _onBack(BuildContext context) {
    final inPanes = SettingsPaneScope.paneAt(context) != null;
    if (!inPanes && context.canPop()) return context.pop();
    final parent = page == null
        ? null
        : settingsPlace(context.l10n, page!).parent;
    context.go(
      parent == null ? AppRoutes.settings : AppRoutes.settingsPage(parent),
    );
  }
}

/// "‹ Settings": the iPhone back button, in the accent.
class _ParentBack extends StatelessWidget {
  const _ParentBack({required this.label, required this.onTap});

  final String label;
  final void Function(BuildContext) onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: context.l10n.settingsBackTo(label),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(DotRadii.card),
        onTap: () => onTap(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DotIcon(DotGlyphs.chevronLeft, color: t.colors.accentInk),
              Flexible(
                child: Text(
                  label,
                  style: t.styles.body.copyWith(color: t.colors.accentInk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A paragraph in the page's muted body style.
class PageText extends StatelessWidget {
  const PageText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Text(text, style: t.styles.body.copyWith(color: t.colors.muted));
  }
}
