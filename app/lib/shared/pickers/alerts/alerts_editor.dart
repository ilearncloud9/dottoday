import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/shared/feedback/permission_notice.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// Most alerts one task carries (docs/05 `alerts`).
const maxAlerts = 5;

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

/// The Alerts editor (docs/10 §5.3, docs/09 M3f.2, R-10): the task's
/// alerts with ×, the choices to add (up to [maxAlerts]), and — when
/// [onBedtime] is given — the every-evening Bedtime reminder. Returns the
/// alerts in time order, or null when dismissed.
Future<List<Alert>?> showAlertsEditor(
  BuildContext context, {
  required List<Alert> initial,
  bool bedtime = false,
  ValueChanged<bool>? onBedtime,
  Future<bool> Function()? deniedOpenSettings,
}) => showAppSheet<List<Alert>>(
  context: context,
  title: context.l10n.alertsTitle,
  builder: (_) => _Alerts(
    initial: initial,
    bedtime: bedtime,
    onBedtime: onBedtime,
    deniedOpenSettings: deniedOpenSettings,
  ),
);

class _Alerts extends StatefulWidget {
  const _Alerts({
    required this.initial,
    required this.bedtime,
    this.onBedtime,
    this.deniedOpenSettings,
  });

  final List<Alert> initial;
  final bool bedtime;
  final ValueChanged<bool>? onBedtime;

  /// Set while notifications are denied (M3f.8): the notice on top, whose
  /// button calls it.
  final Future<bool> Function()? deniedOpenSettings;

  @override
  State<_Alerts> createState() => _AlertsState();
}

/// A leaf: the list being edited and the switch's echo.
class _AlertsState extends State<_Alerts> {
  late final _alerts = [...widget.initial];
  late var _bedtime = widget.bedtime;

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

  void _bedtimeTo(bool on, ValueChanged<bool> set) {
    setState(() => _bedtime = on);
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
        if (widget.deniedOpenSettings case final open?)
          PermissionNotice(onOpenSettings: open),
        if (_alerts.isEmpty) Text(l10n.sheetNoAlerts, style: t.styles.body),
        for (final a in _alerts)
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: DotTouch.android,
            leading: DotIcon(DotGlyphs.bell, color: t.colors.muted),
            title: Text(alertLabel(l10n, a), style: t.styles.body),
            trailing: IconButton(
              tooltip: l10n.alertsRemove(alertLabel(l10n, a)),
              onPressed: () => setState(() => _alerts.remove(a)),
              icon: DotIcon(DotGlyphs.close, color: t.colors.muted),
            ),
          ),
        Text(l10n.alertsAdd.toUpperCase(), style: t.styles.caption),
        Wrap(
          spacing: DotSpace.xs,
          runSpacing: DotSpace.xs,
          children: [
            for (final a in alertChoices)
              ActionChip(
                label: Text(alertLabel(l10n, a)),
                shape: dotChipShape(context),
                onPressed: full || _alerts.contains(a) ? null : () => _add(a),
              ),
          ],
        ),
        if (full) Text(l10n.alertsMax, style: t.styles.rowMeta),
        if (widget.onBedtime case final set?)
          MergeSemantics(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.alertsBedtime, style: t.styles.body),
              subtitle: Text(l10n.alertsBedtimeDetail, style: t.styles.rowMeta),
              onTap: () => _bedtimeTo(!_bedtime, set),
              trailing: DotSwitch(
                value: _bedtime,
                onChanged: (v) => _bedtimeTo(v, set),
              ),
            ),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_alerts),
          child: Text(l10n.alertsDone),
        ),
      ],
    );
  }
}
