import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/shared/controls/dot_segmented.dart';
import 'package:dottoday/shared/layout/layout_switch.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Layout (docs/14 §2.6, §4; E-G3-9b, ED-161): "Show everything or show
/// less" with Everything · Less beside it, in each platform's own
/// segmented control ([DotSegmented]). On Appearance in Full and first in minimal
/// Settings; the choice applies at once and asks nothing (§5).
class LayoutRow extends ConsumerWidget {
  const LayoutRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final minimal = ref.watch(layoutPolicyProvider.select((p) => p.isMinimal));
    void choose(bool less) => setLayout(context, minimal: less);

    final control = DotSegmented<bool>(
      segments: [(false, l10n.layoutEverything), (true, l10n.layoutLess)],
      selected: minimal,
      onChanged: choose,
    );
    // On a Mac/web form: "Layout:" and the control, its words under it
    // (ED-452).
    if (settingsFormAt(context)) {
      return FormLine(
        label: l10n.layoutRow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.xs,
          children: [control, FormHelp(l10n.layoutRowDetail)],
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, box) {
        final beside = box.maxWidth >= DotSize.layoutSegmentsBeside;
        return SettingsRow(
          glyph: DotGlyphs.dottedRow,
          tint: t.colors.accentInk,
          title: l10n.layoutRow,
          subtitle: l10n.layoutRowDetail,
          trailing: beside ? control : null,
          below: beside
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: DotSpace.s),
                  child: control,
                ),
        );
      },
    );
  }
}
