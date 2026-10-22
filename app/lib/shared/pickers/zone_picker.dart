import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/time_zones.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

export 'package:dottoday/domain/time/time_zones.dart' show zoneCity;

/// "Time zone" (docs/10 §5.3): search the bundled IANA zones by city or
/// id. Returns the picked id, or null.
Future<String?> showZonePicker(
  BuildContext context, {
  required String current,
}) => showAppSheet<String>(
  context: context,
  title: context.l10n.timeMenuZone,
  builder: (_) => _ZonePicker(current: current),
);

class _ZonePicker extends StatefulWidget {
  const _ZonePicker({required this.current});

  final String current;

  @override
  State<_ZonePicker> createState() => _ZonePickerState();
}

/// A leaf: only the search text.
class _ZonePickerState extends State<_ZonePicker> {
  var _query = '';

  late final List<String> _all = pickableZones(
    tz.timeZoneDatabase.locations.keys,
  );

  List<String> get _matches =>
      _query.trim().isEmpty ? [widget.current] : searchZones(_all, _query);

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          autofocus: true,
          autocorrect: false,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: l10n.zoneSearch,
            prefixIcon: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: DotIcon(
                DotGlyphs.search,
                color: t.colors.muted,
                size: DotSize.rowIcon,
              ),
            ),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        for (final id in _matches)
          ListTile(
            minTileHeight: DotTouch.android,
            title: Text(zoneCity(id), style: t.styles.body),
            subtitle: Text(id, style: t.styles.rowMeta),
            selected: id == widget.current,
            trailing: id == widget.current
                ? DotIcon(DotGlyphs.check, color: t.colors.accentInk)
                : null,
            onTap: () => Navigator.of(context).pop(id),
          ),
      ],
    );
  }
}
