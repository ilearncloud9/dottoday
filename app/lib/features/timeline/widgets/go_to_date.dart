import 'package:dottoday/core/editing/add_anchor.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/today_month.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Go to date (E-R2-36, ED-342; M19.5 part 5c): the approved month (ED-075)
/// with its planned-day dots, the week on show tinted and today ringed
/// (owner: the approved month everywhere). Each platform's own container:
/// a popover from the date button on the Mac, the web and the iPad, a
/// dialog on Android tablets (Android has no popover), a sheet on phones.
/// A picked day is [onSelect]; ‹ › and Page Up / Page Down change the
/// month, the arrows move a day, Return picks, Esc closes.
Future<void> showGoToDate(
  BuildContext context, {
  required DateTime shown,
  required DateTime today,
  required ValueChanged<DateTime> onSelect,
  Rect? anchor,
}) async {
  Widget panel(BuildContext _) => GoToDatePanel(shown: shown, today: today);
  final compact = AppLayout.classOf(context) == WidthClass.compact;
  final android =
      touchApp(context) && Theme.of(context).platform == TargetPlatform.android;
  final picked = compact
      ? await showAppSheet<DateTime>(context: context, builder: panel)
      : android
      ? await showDialog<DateTime>(
          context: context,
          builder: (dialog) => Dialog(
            child: SizedBox(
              width: DotSize.goToDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: DotSpace.m),
                child: panel(dialog),
              ),
            ),
          ),
        )
      : await showAnchoredPopover<DateTime>(
          context: context,
          anchor: anchor ?? DateAnchor.current(),
          width: DotSize.goToDate,
          builder: panel,
        );
  if (picked != null) onSelect(picked);
}

/// The month in Go to date's container; its pick pops it.
class GoToDatePanel extends StatefulWidget {
  const GoToDatePanel({required this.shown, required this.today, super.key});

  final DateTime shown;
  final DateTime today;

  @override
  State<GoToDatePanel> createState() => _GoToDatePanelState();
}

/// A leaf: the month on show.
class _GoToDatePanelState extends State<GoToDatePanel> {
  late var _month = DateTime(widget.shown.year, widget.shown.month);

  void _shift(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) => Shortcuts(
    // The web maps arrows to scrolling; here they move a day.
    shortcuts: const {
      SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(
        TraversalDirection.left,
      ),
      SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(
        TraversalDirection.right,
      ),
      SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(
        TraversalDirection.up,
      ),
      SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(
        TraversalDirection.down,
      ),
    },
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.pageUp): () => _shift(-1),
        const SingleActivator(LogicalKeyboardKey.pageDown): () => _shift(1),
      },
      child: FocusTraversalGroup(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
          child: TodayMonth(
            month: _month,
            shown: widget.shown,
            today: widget.today,
            goTo: true,
            onSelect: (d) => Navigator.of(context).pop(d),
            onMonth: (m) => setState(() => _month = m),
          ),
        ),
      ),
    ),
  );
}
