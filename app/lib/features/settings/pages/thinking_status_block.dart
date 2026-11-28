import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/data/thinking/thinking_settings.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:dottoday/shared/thinking/thinking_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Privacy › Help with thinking's status (docs/09 M14.2): what
/// answers on this device now and the exact next step, per vendor, in a
/// tinted box (E-R2-23 §3); Open
/// Settings only where the OS has a link (on iPhone with the note that it
/// opens Dottoday's own page). Re-read on resume (`app_lifecycle.dart`).
class ThinkingStatusBlock extends ConsumerWidget {
  const ThinkingStatusBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(thinkingStatusProvider).value;
    if (status == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        // The status in a tinted box, bold (E-R2-23 §3).
        DecoratedBox(
          decoration: BoxDecoration(
            color: t.colors.tonal,
            borderRadius: BorderRadius.circular(DotRadii.card),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DotSpace.m,
              vertical: DotSpace.s,
            ),
            child: Text(
              l10n.thinkingStatusLine(status),
              style: t.styles.chip.copyWith(color: t.colors.accentText),
            ),
          ),
        ),
        if (status.opensSettings) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton(
              onPressed: () => unawaited(
                ref.read(thinkingSettingsOpenerProvider)(status.vendor),
              ),
              child: Text(l10n.privacyAiOpenSettings),
            ),
          ),
          if (status.vendor == ThinkingVendor.appleIos)
            Text(
              l10n.privacyAiOpenSettingsIos,
              style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
            ),
        ],
      ],
    );
  }
}
