import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/settings_return.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/settings/minimal_settings.dart';
import 'package:dottoday/features/settings/pages/group_pages.dart';
import 'package:dottoday/features/settings/pages/settings_pages.dart';
import 'package:dottoday/features/settings/panes/settings_pane_scope.dart';
import 'package:dottoday/features/settings/settings_places.dart';
import 'package:dottoday/features/settings/settings_search.dart';
import 'package:dottoday/features/settings/widgets/account_row.dart';
import 'package:dottoday/shared/settings/settings_frame.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings (M20.7 part 1, E-Phones Settings): the title, then
/// [SettingsRoot] — Your account, Search settings and six groups (Your
/// day, Planning, Reminders, Appearance, Data and privacy, Help and
/// about), each opening its page. Every change applies at once (03 §3.7).
/// Minimal shows [MinimalSettings] (docs/14 §4).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _key = ValueKey('route:settings');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.value;
    if (profile == null) {
      return StateScaffold(
        key: _key,
        inputs: [profileAsync],
        onRetry: () => ref.invalidate(currentProfileProvider),
      );
    }
    final s = profile.settings;
    final minimal = watchSimplified(ref, FeatureId.notifications);
    final pane = SettingsPaneScope.paneAt(context);
    // In two panes the root is the list; its place in the detail shows
    // the page Settings opens on (owner, part 5a): Your day, or Minimal's
    // Account and sync.
    if (pane == SettingsPane.detail) {
      return settingsPageFor(
        minimal ? SettingsPage.account : SettingsPage.yourDay,
      );
    }
    // Phones open Settings from the profile, not a tab (ED-238): Back and
    // its button return to where it was opened. The Android tablet's list
    // pane keeps ←, as E-R2-11 draws it.
    final phone = AppLayout.classOf(context) == WidthClass.compact;
    final withBack =
        phone ||
        (pane == SettingsPane.list &&
            touchApp(context) &&
            DotIdiom.of(context) == DotIdiom.material);
    void back() => context.go(ref.read(settingsReturnProvider.notifier).take());
    final page = Scaffold(
      key: _key,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: ListView(
              // One saved scroll position per layout: switching layouts
              // never opens the other list part-way down (M16 sweep).
              key: PageStorageKey(
                minimal
                    ? 'settings:minimal' // l10n-ignore: storage key
                    : 'settings', // l10n-ignore: storage key
              ),
              padding: EdgeInsets.fromLTRB(
                settingsSide(context),
                DotSpace.l,
                settingsSide(context),
                DotSpace.fabClearance,
              ),
              children: [
                _RootTitle(onBack: withBack ? back : null),
                const SizedBox(height: DotSpace.l),
                if (minimal)
                  MinimalSettings(settings: s)
                else
                  const SettingsRoot(),
              ],
            ),
          ),
        ),
      ),
    );
    if (!phone) return page;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) back();
      },
      child: page,
    );
  }
}

/// Your account, then Search settings over the six groups: the root of
/// Full, and of minimal's Everything else… (E-PhonesMinimal, ED-084).
class SettingsRoot extends StatelessWidget {
  const SettingsRoot({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: DotSpace.xl,
    children: [
      AccountCard(),
      SettingsSearch(child: SettingsRootGroups()),
    ],
  );
}

/// The root's six groups, each opening its page (M20.7 part 1): the
/// Settings tab in full, and minimal's Everything else… page.
class SettingsRootGroups extends StatelessWidget {
  const SettingsRootGroups({super.key});

  @override
  Widget build(BuildContext context) => SettingsGroup(
    caption: '',
    children: [for (final page in settingsRootGroups) PlaceRow(page)],
  );
}

/// "Settings": under ‹ on iPhone, beside ← on Material (E-Phones); the
/// back button only on phones, which open Settings from the profile.
class _RootTitle extends StatelessWidget {
  const _RootTitle({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final iphone = DotIdiom.of(context) == DotIdiom.cupertino;
    // iPhone: 34/41, 4 in from the cards (E-Phones, ED-498).
    final title = Padding(
      padding: EdgeInsetsDirectional.only(
        start: iphone ? SettingsFrameSize.wordsInset : 0,
      ),
      child: Semantics(
        header: true,
        child: Text(
          context.l10n.navSettings,
          style: settingsTitleStyle(context),
        ),
      ),
    );
    final back = onBack;
    if (back == null) return title;
    final button = BackButton(onPressed: back);
    if (DotIdiom.of(context) == DotIdiom.cupertino) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [button, title],
      );
    }
    return Row(
      spacing: DotSpace.s,
      children: [
        button,
        Expanded(child: title),
      ],
    );
  }
}
