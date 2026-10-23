import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/security/app_lock_store.dart';
import 'package:dottoday/domain/security/app_lock.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// APP LOCK on Settings › Privacy (docs/06 §2, docs/09 M5.8): the switch
/// and how long before it locks again. This device only; the web has no
/// device check, so it says what does protect it (07 Web, R-13).
class AppLockGroup extends ConsumerWidget {
  const AppLockGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!appLockSupported) return const _WebLock();
    final settings = ref.watch(appLockSettingProvider).value;
    if (settings == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsGroup(
      caption: l10n.lockCaption,
      children: [
        SettingsRow(
          glyph: DotGlyphs.check,
          tint: t.colors.accentInk,
          title: l10n.lockToggle,
          subtitle: l10n.lockToggleDetail,
          toggle: settings.enabled,
          onToggle: (on) =>
              unawaited(_save(context, ref, settings.copyWith(enabled: on))),
        ),
        if (settings.enabled)
          SettingsRow(
            glyph: DotGlyphs.repeat,
            tint: t.colors.accentInk,
            title: l10n.lockAfter,
            value: _label(l10n, settings.after),
            onTap: () async {
              final picked = await showChoiceSheet<Duration>(
                context,
                title: l10n.lockAfter,
                selected: settings.after,
                options: [
                  for (final d in AppLockSettings.choices)
                    (value: d, label: _label(l10n, d), detail: null),
                ],
              );
              if (picked != null && context.mounted) {
                await _save(context, ref, settings.copyWith(after: picked));
              }
            },
          ),
      ],
    );
  }

  static String _label(AppLocalizations l10n, Duration d) => d == Duration.zero
      ? l10n.lockAfterNow
      : l10n.lockAfterMinutes(d.inMinutes);

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    AppLockSettings next,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final saved = await ref
        .read(appLockSettingProvider.notifier)
        .save(next, reason: l10n.lockReason);
    if (!saved) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.lockUnavailable)));
    }
  }
}

/// The web fallback: no switch, just what keeps the tasks private.
class _WebLock extends StatelessWidget {
  const _WebLock();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsGroup(
      caption: l10n.lockCaption,
      children: [
        SettingsRow(
          glyph: DotGlyphs.check,
          tint: DotTheme.of(context).colors.muted,
          title: l10n.lockWebTitle,
          subtitle: l10n.lockWebDetail,
        ),
      ],
    );
  }
}
