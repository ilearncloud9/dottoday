import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/validation/field_rules.dart' show maxAlerts;
import 'package:dottoday/shared/feedback/permission_notice.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sheets/sheet_nav_bar.dart';
import 'package:flutter/material.dart';

/// "10 min before", "At start", "At end", "5 min overdue".
String alertLabel(AppLocalizations l10n, Alert a) => switch (a.kind) {
  AlertKind.before => l10n.alertBefore(a.offsetMin),
  AlertKind.atStart => l10n.alertAtStart,
  AlertKind.atEnd => l10n.alertAtEnd,
  AlertKind.overdue => l10n.alertOverdue(a.offsetMin),
};

/// The ones the editor offers, in time order around the task.
const alertChoices = [
  Alert(kind: AlertKind.before, offsetMin: 60),
  Alert(kind: AlertKind.before, offsetMin: 30),
  Alert(kind: AlertKind.before, offsetMin: 15),
  Alert(kind: AlertKind.before, offsetMin: 10),
  Alert(kind: AlertKind.before, offsetMin: 5),
  Alert(kind: AlertKind.atStart),
  Alert(kind: AlertKind.atEnd),
  Alert(kind: AlertKind.overdue, offsetMin: 10),
];

/// The Alerts editor (docs/10 §5.3, docs/09 M3f.2, R-10; E-R2-27 §2):
/// a form, Cancel (×) · Alerts · Done; the task's alerts in a card with ×,
/// the choices to add (up to [maxAlerts], then "Up to 5 alerts"), and —
/// when [onWindDown] is given — the every-evening Wind Down reminder in its
/// own card. Returns the alerts in time order on Done, or null when
/// dismissed.
Future<List<Alert>?> showAlertsEditor(
  BuildContext context, {
  required List<Alert> initial,
  bool windDown = false,
  ValueChanged<bool>? onWindDown,
  Future<bool> Function()? deniedOpenSettings,
}) => showAppSheet<List<Alert>>(
  context: context,
  builder: (_) => _Alerts(
    initial: initial,
    windDown: windDown,
    onWindDown: onWindDown,
    deniedOpenSettings: deniedOpenSettings,
  ),
);

class _Alerts extends StatefulWidget {
  const _Alerts({
    required this.initial,
    required this.windDown,
    this.onWindDown,
    this.deniedOpenSettings,
  });

  final List<Alert> initial;
  final bool windDown;
  final ValueChanged<bool>? onWindDown;

  /// Set while notifications are denied (M3f.8): the notice on top, whose
  /// button calls it.
  final Future<bool> Function()? deniedOpenSettings;

  @override
  State<_Alerts> createState() => _AlertsState();
}

/// A leaf: the list being edited and the switch's echo.
class _AlertsState extends State<_Alerts> {
  late final _alerts = [...widget.initial];
  late var _windDown = widget.windDown;

  /// Time order: the earliest fire first.
  static int _order(Alert a) => switch (a.kind) {
    AlertKind.before => -a.offsetMin,
    AlertKind.atStart => 0,
    AlertKind.atEnd => 100000,
    AlertKind.overdue => 100000 + a.offsetMin,
  };

  void _add(Alert a) => setState(
    () => _alerts
      ..add(a)
      ..sort((x, y) => _order(x).compareTo(_order(y))),
  );

  void _windDownTo(bool on, ValueChanged<bool> set) {
    setState(() => _windDown = on);
    set(on);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final full = _alerts.length >= maxAlerts;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        SheetNavBar(
          title: l10n.alertsTitle,
          actionLabel: l10n.alertsDone,
          onCancel: () => Navigator.of(context).pop(),
          onAction: () => Navigator.of(context).pop(_alerts),
        ),
        if (widget.deniedOpenSettings case final open?)
          PermissionNotice(onOpenSettings: open),
        if (_alerts.isEmpty)
          Text(l10n.sheetNoAlerts, style: t.styles.body)
        else
          _Card(
            children: [
              for (final a in _alerts)
                ListTile(
                  minTileHeight: DotTouch.android,
                  title: Text(alertLabel(l10n, a), style: t.styles.body),
                  trailing: IconButton(
                    tooltip: l10n.alertsRemove(alertLabel(l10n, a)),
                    onPressed: () => setState(() => _alerts.remove(a)),
                    icon: DotIcon(DotGlyphs.close, color: t.colors.muted),
                  ),
                ),
            ],
          ),
        Text(l10n.alertsAdd.toUpperCase(), style: t.styles.caption),
        Wrap(
          spacing: DotSpace.xs,
          runSpacing: DotSpace.xs,
          children: [
            // Only those not added yet (E-R2-27); all off at the limit.
            for (final a in alertChoices)
              if (!_alerts.contains(a))
                ActionChip(
                  label: Text(alertLabel(l10n, a)),
                  shape: dotChipShape(context),
                  onPressed: full ? null : () => _add(a),
                ),
          ],
        ),
        if (full)
          Text(
            l10n.alertsMax,
            style: t.styles.cardTitle.copyWith(color: t.colors.accentInk),
          ),
        if (widget.onWindDown case final set?)
          _Card(
            children: [
              MergeSemantics(
                child: ListTile(
                  title: Text(l10n.alertsWindDown, style: t.styles.body),
                  subtitle: Text(
                    l10n.alertsWindDownDetail,
                    style: t.styles.rowMeta,
                  ),
                  onTap: () => _windDownTo(!_windDown, set),
                  trailing: DotSwitch(
                    value: _windDown,
                    onChanged: (v) => _windDownTo(v, set),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// A raised card of rows split by hairlines (E-R2-27's grouped list); a
/// Material, so the rows' ink shows.
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Material(
      color: c.raised,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.card),
        side: BorderSide(color: c.outline),
      ),
      child: Column(
        children: [
          for (final (i, row) in children.indexed) ...[
            if (i > 0) Divider(height: DotSpace.hairline, color: c.outline),
            row,
          ],
        ],
      ),
    );
  }
}
