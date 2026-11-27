@Tags(['golden'])
library;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// E-R2-24's strips above every screen (ED-497): after an update, the web's
// install offer, the calendar's three. Phone and wide, light and dark.
void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'strips_r2_24',
    height: 560,
    widths: const {'compact', 'expanded'},
    build: (_) => Builder(
      builder: (context) {
        final l10n = context.l10n;
        void none() {}
        return Column(
          children: [
            BannerStrip(
              card: true,
              text: l10n.whatsNewBanner('1.2.0'),
              actions: [(l10n.whatsNewOpen, none), (l10n.promptNotNow, none)],
            ),
            BannerStrip(
              card: true,
              glyph: DotGlyphs.download,
              text: l10n.installText,
              actions: [(l10n.installAction, none), (l10n.promptNotNow, none)],
            ),
            BannerStrip(
              card: true,
              text: l10n.bannerWriteBackClash(2),
              actions: [
                (l10n.syncKeepMine, none),
                (l10n.bannerUseCalendars, none),
              ],
            ),
            BannerStrip(
              card: true,
              text: l10n.bannerWriteBackPending(1),
              actions: [(l10n.stateRetry, none)],
            ),
            BannerStrip(
              card: true,
              text: l10n.calendarsReconnectDetail,
              actions: [(l10n.calendarsReconnect, none)],
            ),
          ],
        );
      },
    ),
  );
}
