import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A Settings sub-page (docs/09 M3f.7): ‹ and the page title over the
/// same readable column as Settings, then [children] with group spacing.
class SettingsPageFrame extends StatelessWidget {
  const SettingsPageFrame({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                DotSpace.page,
                DotSpace.l,
                DotSpace.page,
                DotSpace.fabClearance,
              ),
              children: [
                _TitleRow(title: title),
                for (final child in children) ...[
                  const SizedBox(height: DotSpace.l),
                  child,
                ],
              ],
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
/// health" at 200 % on a 390 px phone).
class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final back = IconButton(
      tooltip: context.l10n.settingsBack,
      onPressed: () => _back(context),
      icon: DotIcon(DotGlyphs.arrowLeft, color: t.colors.text),
    );
    final heading = Semantics(
      header: true,
      child: Text(title, style: t.styles.pageTitle),
    );
    return LayoutBuilder(
      builder: (context, box) {
        final beside = box.maxWidth - kMinInteractiveDimension;
        if (longestWordFits(context, title, t.styles.pageTitle, beside)) {
          return Row(
            children: [
              back,
              Expanded(child: heading),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [back, heading],
        );
      },
    );
  }

  /// Back to Settings, also when the page was opened by a link.
  static void _back(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(AppRoutes.settings);
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
