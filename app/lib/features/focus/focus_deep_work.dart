import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/focus/focus_providers.dart';
import 'package:dottoday/domain/focus/deep_work.dart';
import 'package:dottoday/features/focus/focus_parts.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Deep work · Focus on" (11 A3, docs/09 M10.5): Android turns Do Not
/// Disturb on until [untilUtc] (alarms only, so dot starts still ring) —
/// asking for notification-policy access first; iPhone and Mac can't
/// switch Focus from an app, so it explains the Shortcuts way; the web
/// says to use the computer's own setting.
class DeepWorkToggle extends ConsumerWidget {
  const DeepWorkToggle({required this.untilUtc, super.key});

  /// The dot's planned end, when Do Not Disturb goes off by itself.
  final DateTime? untilUtc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(deepWorkStatusProvider).value;
    final kind = status?.kind ?? DeepWorkKind.none;
    return switch (kind) {
      DeepWorkKind.dnd => FocusToggle(
        glyph: DotGlyphs.moon,
        label: l10n.focusDeepWork,
        // The footer already says dot starts break through; the line is
        // for what the user must do first.
        detail: status!.granted ? null : l10n.focusDeepWorkAccess,
        value: status.on,
        onChanged: (on) => unawaited(_android(ref, status, on)),
      ),
      DeepWorkKind.shortcuts => FocusToggle(
        glyph: DotGlyphs.moon,
        label: l10n.focusDeepWork,
        value: false,
        onChanged: (_) => unawaited(_shortcuts(context, ref)),
      ),
      DeepWorkKind.none => FocusToggle(
        glyph: DotGlyphs.moon,
        label: l10n.focusDeepWork,
        detail: l10n.focusDeepWorkWeb,
        value: false,
        onChanged: null,
      ),
    };
  }

  Future<void> _android(WidgetRef ref, DeepWorkStatus status, bool on) async {
    final gateway = ref.read(deepWorkGatewayProvider);
    final until = untilUtc;
    if (on && (!status.granted || until == null)) {
      // Granted in Settings; the status is read again on return.
      if (!status.granted) await gateway.openSettings();
      return;
    }
    on ? await gateway.turnOn(until!) : await gateway.turnOff();
    ref.invalidate(deepWorkStatusProvider);
  }

  Future<void> _shortcuts(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    await showAppSheet<void>(
      context: context,
      title: l10n.focusShortcutsTitle,
      builder: (sheet) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.l,
        children: [
          Text(l10n.focusShortcutsBody),
          FilledButton(
            onPressed: () {
              Navigator.of(sheet).pop();
              unawaited(ref.read(deepWorkGatewayProvider).openSettings());
            },
            child: Text(l10n.focusShortcutsOpen),
          ),
        ],
      ),
    );
  }
}
