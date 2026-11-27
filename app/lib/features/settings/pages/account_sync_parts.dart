import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/sync/sign_out_check.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:flutter/material.dart';

/// Which E-CR160 board Settings › Account follows: the Mac's and web's
/// form, iPhone and iPad's cards, or Android's list.
AccountDialogLook accountPageLook(BuildContext context) {
  if (settingsFormAt(context)) return AccountDialogLook.desktop;
  return DotIdiom.of(context) == DotIdiom.cupertino
      ? AccountDialogLook.iphone
      : AccountDialogLook.android;
}

/// The line under "Signed in as …" (ED-494): "Synced" with a tick once the
/// server confirmed everything, else how many changes wait ("Nothing
/// waiting to sync" until it is confirmed); nothing before [pending] is
/// read.
class AccountSyncLine extends StatelessWidget {
  const AccountSyncLine({
    required this.status,
    required this.pending,
    required this.look,
    super.key,
  });

  final SyncStatus? status;
  final int? pending;
  final AccountDialogLook look;

  @override
  Widget build(BuildContext context) {
    final count = pending;
    if (count == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final synced = everythingSynced(status, count);
    final text = Text(
      synced ? l10n.syncSynced : l10n.syncPending(count),
      style: look == AccountDialogLook.desktop
          ? t.styles.inspectorValue.copyWith(color: t.colors.muted)
          : AccountSyncType.status(t.styles, t.colors),
    );
    // The tick is the iPhone and iPad cards' (`AccountChoose`).
    if (!synced || look != AccountDialogLook.iphone) {
      return Semantics(liveRegion: true, child: text);
    }
    return Semantics(
      liveRegion: true,
      child: Row(
        spacing: AccountSyncSize.tickGap,
        children: [
          DotIcon(
            DotGlyphs.check,
            color: t.colors.muted,
            size: AccountSyncSize.tick,
          ),
          Expanded(child: text),
        ],
      ),
    );
  }
}

/// The Sync block on a phone or tablet: iPhone and iPad's "Sync" caption
/// over a card; Android's over plain lines. The caption is the page's own
/// (sentence case, the accent on Android), so it lines up with Profile.
class AccountSyncBlock extends StatelessWidget {
  const AccountSyncBlock({
    required this.look,
    required this.children,
    super.key,
  });

  final AccountDialogLook look;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final android = look == AccountDialogLook.android;
    final caption = Padding(
      padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
      child: Semantics(
        header: true,
        child: Text(
          context.l10n.accountSync,
          style: android
              ? t.styles.caption.copyWith(color: t.colors.accentInk)
              : t.styles.caption,
        ),
      ),
    );
    if (android) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AccountSyncSize.androidGap,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: AccountSyncSize.androidHeadPad,
            ),
            child: caption,
          ),
          ...children,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        caption,
        DecoratedBox(
          decoration: BoxDecoration(
            color: t.colors.raised,
            borderRadius: BorderRadius.circular(AccountSyncSize.cardRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AccountSyncSize.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AccountSyncSize.cardGap,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

/// "Choose settings" while B1 waits (after Decide later): a card row on
/// iPhone, iPad and the Mac/web, a list row on Android; opens B1 again.
class ChooseSettingsRow extends StatelessWidget {
  const ChooseSettingsRow({required this.look, required this.onTap, super.key});

  final AccountDialogLook look;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final (min, pad, chevron, gap) = switch (look) {
      AccountDialogLook.iphone => (
        AccountSyncSize.rowIphone,
        AccountSyncSize.rowPadIphone,
        AccountSyncSize.chevronIphone,
        AccountSyncSize.rowGap,
      ),
      AccountDialogLook.android => (
        AccountSyncSize.rowAndroid,
        AccountSyncSize.rowPadAndroid,
        AccountSyncSize.chevronAndroid,
        AccountSyncSize.rowGapAndroid,
      ),
      AccountDialogLook.desktop => (
        AccountSyncSize.rowDesktop,
        AccountSyncSize.rowPadDesktop,
        AccountSyncSize.chevronDesktop,
        AccountSyncSize.rowGap,
      ),
    };
    final ShapeBorder shape = switch (look) {
      AccountDialogLook.iphone => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AccountSyncSize.rowRadius),
      ),
      AccountDialogLook.android => const RoundedRectangleBorder(),
      AccountDialogLook.desktop => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AccountSyncSize.rowRadiusDesktop),
        side: BorderSide(color: c.outline, width: AccountSyncSize.rowRing),
      ),
    };
    final row = Material(
      color: look == AccountDialogLook.android ? Colors.transparent : c.raised,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: min),
          child: Padding(
            padding: pad,
            child: Row(
              spacing: gap,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: AccountSyncSize.rowLines,
                    children: [
                      Text(
                        l10n.accountChooseSettings,
                        style: AccountSyncType.rowTitle(t.styles, look),
                      ),
                      Text(
                        l10n.accountChooseSettingsBody,
                        style: AccountSyncType.rowLine(t.styles, c, look),
                      ),
                    ],
                  ),
                ),
                DotIcon(DotGlyphs.chevronRight, color: c.muted, size: chevron),
              ],
            ),
          ),
        ),
      ),
    );
    final button = Semantics(button: true, child: row);
    if (look != AccountDialogLook.desktop) return button;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AccountSyncSize.rowDesktopMax,
        ),
        child: button,
      ),
    );
  }
}
