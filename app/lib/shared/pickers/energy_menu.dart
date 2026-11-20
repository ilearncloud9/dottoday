import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/widgets.dart';

/// "Low", "Medium", "High".
String energyText(AppLocalizations l10n, Energy e) => switch (e) {
  Energy.low => l10n.energyLow,
  Energy.medium => l10n.energyMedium,
  Energy.high => l10n.energyHigh,
};

/// Energy's three-item menu (E-R2-40, ED-346): Low, Medium, High with
/// [current] ticked, under [at]; the system menu on the Mac and iOS,
/// Material's on Android (owner, 4d). Picking the ticked level clears it,
/// as built. Returns the new level in a record (its energy null when
/// cleared), or null when dismissed.
Future<({Energy? energy})?> pickEnergy(
  BuildContext context, {
  required Rect? at,
  required Energy? current,
}) async {
  final l10n = context.l10n;
  final rtl = Directionality.of(context) == TextDirection.rtl;
  final picked = await showContextMenu<Energy>(
    context,
    at: at == null ? Offset.zero : (rtl ? at.bottomRight : at.bottomLeft),
    entries: [
      for (final e in Energy.values)
        ContextMenuEntry(
          value: e,
          label: energyText(l10n, e),
          checked: e == current,
        ),
    ],
  );
  if (picked == null) return null;
  return (energy: picked == current ? null : picked);
}
