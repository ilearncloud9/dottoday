import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/pwa/install_prompt.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Install Dottoday" on the web from the second visit (docs/07 Web,
/// docs/09 M5.7): Install opens the browser's own dialog; Not now hides it
/// for good in this browser. Nothing anywhere else.
class InstallBanner extends ConsumerWidget {
  const InstallBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!(ref.watch(installAvailableProvider).value ?? false)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final prompt = ref.read(installPromptProvider);
    void hide() => ref.invalidate(installAvailableProvider);
    return BannerStrip(
      glyph: DotGlyphs.add,
      text: l10n.installText,
      actions: [
        (
          l10n.installAction,
          () => unawaited(prompt.install().whenComplete(hide)),
        ),
        (
          l10n.promptNotNow,
          () {
            prompt.dismiss();
            hide();
          },
        ),
      ],
    );
  }
}
