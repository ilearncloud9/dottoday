import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/now/now_inputs.dart';
import 'package:dottoday/features/timeline/now/wide/now_pane.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal's Now in a medium window (600–839: iPad portrait, an Android
/// tablet or foldable, a narrow browser; E-R2-1 2b, ED-266; M19.6 part
/// 6e-2): the Day column has room below, not beside, so Now comes first
/// and the Day follows under its own header with the Day menu, in the
/// page's scroll. The places are the shell's (top tabs, the rail).
class NowStacked extends ConsumerWidget {
  const NowStacked({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = NowInputs.watch(context, ref);
    if (n == null) return const Scaffold();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, box) => ListView(
            padding: const EdgeInsets.fromLTRB(
              DotSpace.xl,
              DotSpace.l,
              DotSpace.xl,
              0,
            ),
            children: [
              NowPane(
                inputs: n,
                app: !webChrome(context),
                dayHidden: false,
                stacked: true,
              ),
              const SizedBox(height: DotSpace.xl),
              Divider(color: t.colors.hairline, height: DotSpace.hairline),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.workspaceDay,
                          style: t.styles.cardTitle,
                        ),
                      ),
                    ),
                    TodayMenu(
                      date: n.today,
                      today: n.today,
                      button: ToolbarPill(label: l10n.workspaceDay, menu: true),
                    ),
                  ],
                ),
              ),
              // A window tall: the page brings the Day up, then the Day
              // scrolls (its own scroll opens at the live task, ED-103).
              SizedBox(
                height: box.maxHeight,
                child: DayPage(
                  date: n.today,
                  today: n.today,
                  page: true,
                  runningLate: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
