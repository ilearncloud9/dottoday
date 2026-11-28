import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Widest a row's value grows, as a share of the screen.
const double _valueShare = 0.45;

/// Row height: 48 on iPhone, 56 on Material (docs/10 §3 `SettingsGroup`).
double settingsRowHeight(BuildContext context) =>
    DotIdiom.of(context) == DotIdiom.cupertino
    ? DotTouch.android
    : DotTouch.android + DotSpace.s;

/// "DAY SHAPE", "PLANNING" …: a caption over a raised card of rows with
/// hairlines between them (`A-ios-settings`).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.caption,
    required this.children,
    this.footer,
    this.list = false,
    this.formBreak = true,
    this.formHeading = false,
    super.key,
  });

  /// On a form page, [caption] as the section's heading (Wake Up and Wind
  /// Down's The night, Wake Up alarm, Reminders, ED-452).
  final bool formHeading;

  /// On a form page, a hairline above it; off where groups run on as one
  /// section (Appearance's Layout, Theme and App colour, ED-452).
  final bool formBreak;

  final String caption;

  /// Rows that only open other pages: they stay the list's rows on a Mac
  /// or web form page too (ED-450).
  final bool list;
  final List<Widget> children;

  /// A muted note under the card ("Learning happens on your device …").
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final form = settingsFormAt(context);
    if (form && !list) return _form(context);
    // A list group on a form page keeps its rows as rows (ED-450).
    if (form) {
      return SettingsFormScope(form: false, child: _card(context, t));
    }
    return _card(context, t);
  }

  Widget _card(BuildContext context, DotTheme t) {
    // iPhone and iPad: E-R2-24's cards (ED-498); Android: E-R2-29's,
    // 20 corners and no lines between rows (ED-499).
    final iphone = DotIdiom.of(context) == DotIdiom.cupertino;
    final android = androidApp(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        // No caption: minimal Settings' one group (docs/14 §4 "no sections"),
        // or a page that is this one group (M20.7).
        if (caption.isNotEmpty && !SettingsCaptionScope.hiddenAt(context))
          Padding(
            padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
            child: Semantics(
              header: true,
              // Sentence case, as E draws it (no uppercase captions); the
              // Material list subheader is in the accent (E-Phones).
              child: Text(
                caption,
                // iPhone: regular weight, as E-R2-24 draws it (ED-498).
                style: iphone
                    ? t.styles.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        fontVariations: const [],
                      )
                    : android
                    ? SettingsAndroidType.caption(t.colors)
                    : t.styles.caption.copyWith(color: t.colors.accentText),
              ),
            ),
          ),
        Material(
          color: t.colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              iphone
                  ? SettingsFrameSize.cardRadius
                  : android
                  ? SettingsAndroidSize.cardRadius
                  : DotRadii.cardLarge,
            ),
            side: BorderSide(color: t.colors.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0 && !android)
                  Divider(
                    height: iphone ? SettingsFrameSize.hairline : 1,
                    thickness: iphone ? SettingsFrameSize.hairline : null,
                    color: t.colors.hairline,
                  ),
                child,
              ],
            ],
          ),
        ),
        if (footer case final f?)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DotSpace.xs,
            ),
            child: Text(
              f,
              style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
            ),
          ),
      ],
    );
  }

  /// On a Mac/web form page (ED-450): a hairline, then the rows as form
  /// lines; the caption is dropped (rows carry their own labels) and the
  /// footer is help under the controls.
  Widget _form(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: DotSpace.m,
    children: [
      if (formBreak && !settingsFormFirstAt(context)) const FormBreak(),
      if (formHeading && caption.isNotEmpty)
        Semantics(
          header: true,
          child: Text(
            caption,
            style: DotTheme.of(
              context,
            ).styles.inspectorLabel.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ...children,
      if (footer case final f?) FormLine(child: FormHelp(f)),
    ],
  );
}

/// Hides the captions of the groups under it: a Settings page that is one
/// group already says its name in the title (M20.7 part 1).
class SettingsCaptionScope extends InheritedWidget {
  const SettingsCaptionScope({
    required this.hidden,
    required super.child,
    super.key,
  });

  final bool hidden;

  /// Whether a group at [context] shows no caption.
  static bool hiddenAt(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<SettingsCaptionScope>()
          ?.hidden ??
      false;

  @override
  bool updateShouldNotify(SettingsCaptionScope old) => old.hidden != hidden;
}

/// One settings row: a tinted icon, title (and subtitle), then a value
/// with a chevron, a switch, or a custom [trailing].
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.glyph,
    required this.tint,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.toggle,
    this.onToggle,
    this.trailing,
    this.below,
    this.action = false,
    this.accentValue = false,
    this.selected = false,
    this.formLabel,
    this.choices,
    this.formButton,
    this.formReady,
    this.choiceHeaders,
    this.flush = false,
    this.dot,
    this.quiet = false,
    this.bare = false,
    super.key,
  });

  /// A colour dot in place of the icon tile: a calendar in its own colour
  /// (E-R2-24 §2, ED-497; status and list rows keep what they show,
  /// ED-332).
  final Color? dot;

  /// The title in secondary: a row that only says nothing is there yet
  /// ("No calendars connected yet", E-R2-24 §2).
  final bool quiet;

  /// No icon: a row that only tells (the web's "Uses your computer's
  /// lock", E-R2-24 §3).
  final bool bare;

  /// No side inset: the row sits flush with a sheet's title and text, as
  /// E-R2-21's sheet rows do (the multi-file rows, ED-477), not inside a
  /// group's card.
  final bool flush;

  final DotGlyph glyph;

  /// On a Mac/web form page (ED-450): the label beside a checkbox or an
  /// action ("Nudges:"); null lines it up under the label above.
  final String? formLabel;

  /// On a Mac/web form page: the pop-up menu's choices, picked in place
  /// of [onTap]'s sheet.
  final List<FormChoice>? choices;

  /// Group titles in the pop-up, by the index of each group's first choice.
  final Map<int, String>? choiceHeaders;

  /// On a Mac/web form page: a button that runs [onTap] ("Check…",
  /// "Open Routines") beside [value], in place of the pop-up face; beside
  /// the pop-up when there are [choices] ("All sounds…").
  final String? formButton;

  /// On a Mac/web form page, a row that only tells: done when true, an
  /// open ring while still under way (Learn my day); null shows its icon
  /// (Notification health's checks).
  final bool? formReady;

  /// Icon colour (a task colour or the accent ink); the circle is its tint.
  final Color tint;
  final String title;
  final String? subtitle;

  /// "7:00", "Monday": shown before the chevron.
  final String? value;
  final VoidCallback? onTap;

  /// A switch row when non-null.
  final bool? toggle;
  final ValueChanged<bool>? onToggle;
  final Widget? trailing;

  /// Under the title, full width (the accent swatches).
  final Widget? below;

  /// A row that does something rather than opens a page ("Send a test
  /// alarm", E-Phones): its title in the accent, no chevron.
  final bool action;

  /// The value in the accent, as E-Phones draws "Alarm sounds on · This
  /// iPhone".
  final bool accentValue;

  /// The page open beside Settings' list in two panes (E-R2-11, ED-291):
  /// the row is tinted and says it is selected.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (settingsFormAt(context)) return _form(context);
    if (androidApp(context)) return AndroidSettingsRow(this);
    // Only a value can stack under the title; without one the row needs no
    // width, so it also lays out where its size is measured first (the
    // multi-file rows inside Delete account's frame, ED-477).
    if (value == null) return _build(context, double.infinity);
    return LayoutBuilder(
      builder: (context, box) => _build(context, box.maxWidth),
    );
  }

  /// The row as a form line (ED-450): a switch is a checkbox, a value a
  /// pop-up (a menu with [choices], else a face that opens [onTap]'s
  /// sheet), an action or a page a button.
  Widget _form(BuildContext context) {
    final on = toggle;
    if (on != null) {
      return FormLine(
        label: formLabel,
        child: FormCheck(
          value: on,
          title: title,
          detail: subtitle,
          below: below,
          onChanged: onToggle,
        ),
      );
    }
    final help = [if (subtitle case final s?) FormHelp(s), ?below];
    Widget line(String? label, Widget control) => FormLine(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.xs,
        children: [control, ...help],
      ),
    );
    if (action) {
      return line(formLabel, FormButton(label: title, onPressed: onTap));
    }
    if (choices case final cs?) {
      return line(
        title,
        Wrap(
          spacing: DotSpace.s,
          runSpacing: DotSpace.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FormMenu(
              title: title,
              value: value ?? '',
              choices: cs,
              headers: choiceHeaders ?? const {},
            ),
            ?trailing,
            if (formButton case final b?)
              FormButton(label: b, onPressed: onTap),
          ],
        ),
      );
    }
    if (formButton case final b?) {
      final t = DotTheme.of(context);
      return line(
        title,
        Wrap(
          spacing: DotSpace.s,
          runSpacing: DotSpace.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (value case final v?)
              Text(
                v,
                style: t.styles.inspectorValue.copyWith(
                  color: accentValue ? t.colors.accentText : t.colors.ink,
                ),
              ),
            ?trailing,
            FormButton(label: b, onPressed: onTap),
          ],
        ),
      );
    }
    if (value case final v?) {
      return line(title, FormButton(label: v, onPressed: onTap, menu: true));
    }
    if (onTap == null) {
      return FormLine(label: formLabel, child: _status(context));
    }
    return line(
      formLabel,
      FormButton(label: context.l10n.settingsFormOpen(title), onPressed: onTap),
    );
  }

  /// At large text a word of the title may not fit beside the value
  /// ("Bedt / ime" at 200 %): the value then goes under the title, so
  /// nothing breaks mid-word (accessibility-as-code; found by the M16
  /// minimal Settings goldens).
  bool _stacked(BuildContext context, DotTheme t, double width) {
    final v = value;
    if (v == null || !width.isFinite) return false;
    final valueWidth = math.min(
      textWidth(context, v, t.styles.body),
      MediaQuery.sizeOf(context).width * _valueShare,
    );
    final titleWidth =
        width -
        2 * DotSpace.l -
        DotSize.rowDot -
        3 * DotSpace.m -
        DotSize.rowIcon -
        valueWidth;
    return !longestWordFits(context, title, t.styles.body, titleWidth);
  }

  Widget _build(BuildContext context, double width) {
    final t = DotTheme.of(context);
    final on = toggle;
    final stacked = _stacked(context, t, width);
    final iphone = DotIdiom.of(context) == DotIdiom.cupertino;
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: settingsRowHeight(context)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: flush
              ? 0
              : iphone
              ? SettingsFrameSize.rowPadH
              : DotSpace.l,
          vertical: iphone ? SettingsFrameSize.rowPadV : DotSpace.s,
        ),
        child: Row(
          spacing: DotSpace.m,
          children: [
            if (dot case final colour?)
              ExcludeSemantics(
                child: SizedBox.square(
                  dimension: DotSize.settingsDot,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colour,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            else if (!bare)
              SettingsIcon(glyph: glyph, tint: tint),
            Expanded(
              child: _texts(t, stacked: stacked, iphone: iphone),
            ),
            if (value case final v? when !stacked)
              // As wide as it needs, up to 45 % of the row: short values
              // leave the title room, long ones wrap instead of overflow.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * _valueShare,
                ),
                child: Text(
                  v,
                  textAlign: TextAlign.end,
                  style: t.styles.body.copyWith(
                    color: accentValue
                        ? t.colors.accentText
                        : t.colors.secondary,
                  ),
                ),
              ),
            ?trailing,
            if (on != null)
              DotSwitch(value: on, onChanged: onToggle)
            else if (onTap != null && !action)
              DotIcon(
                DotGlyphs.chevronRight,
                color: t.colors.secondary,
                size: iphone ? SettingsFrameSize.chevron : DotSize.rowIcon,
              ),
          ],
        ),
      ),
    );
    return settingsRowTap(context, this, row);
  }

  /// A row that only tells, as a form line: a small mark, the title and
  /// its detail, then whatever it carries ("6/10", a fix button).
  Widget _status(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final mark = switch (formReady) {
      true => _FormMark(glyph: DotGlyphs.check, tint: c.success),
      false => const _FormMark(),
      null => _FormMark(glyph: glyph, tint: tint),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s + DotSpace.xxs,
      children: [
        mark,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotSpace.xxs,
            children: [
              Text(
                title,
                style: t.styles.inspectorValue.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (subtitle case final s?) FormHelp(s),
              ?below,
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _texts(DotTheme t, {required bool stacked, bool iphone = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Regular weight, as E draws Settings rows (E-R2-33).
          Text(
            title,
            // iPhone rows 16 (E-R2-24, ED-498).
            style:
                (action
                        ? t.styles.body.copyWith(color: t.colors.accentText)
                        : quiet
                        ? t.styles.body.copyWith(color: t.colors.secondary)
                        : t.styles.body)
                    .copyWith(fontSize: iphone ? 16 : null),
          ),
          if (subtitle case final s?) Text(s, style: t.styles.rowMeta),
          if (value case final v? when stacked)
            Text(v, style: t.styles.body.copyWith(color: t.colors.secondary)),
          ?below,
        ],
      );
}

/// A Settings row's icon: [glyph] on its solid tile in the boards' pair
/// for [tint]'s colour (ED-332, ED-498): a rounded tile on iPhone and iPad,
/// a circle on Material. 36 across, the owner's size (ED-498; the boards
/// draw 30); Android's rows 40 and its page header 32, as E-R2-29 draws
/// them (ED-499). The mission picker's rows wear it too (E-R2-28).
class SettingsIcon extends StatelessWidget {
  const SettingsIcon({
    required this.glyph,
    required this.tint,
    this.header = false,
    super.key,
  });

  final DotGlyph glyph;

  /// Beside a page's title: Android's smaller circle.
  final bool header;

  /// How wide the icon is drawn at [context].
  static double extentOf(BuildContext context, {bool header = false}) {
    if (!androidApp(context)) return DotSize.rowDot;
    return header ? SettingsAndroidSize.headerIcon : SettingsAndroidSize.icon;
  }

  /// The setting's colour; [SettingsTiles.of] turns it into the drawn pair.
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final pair = SettingsTiles.of(t.colors, t.tasks, tint);
    final tile = DotIdiom.of(context) == DotIdiom.cupertino;
    final side = extentOf(context, header: header);
    final glyphSize = !androidApp(context)
        ? DotSize.rowIcon
        : header
        ? SettingsAndroidSize.headerGlyph
        : SettingsAndroidSize.glyph;
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        shape: tile ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: tile ? BorderRadius.circular(DotRadii.iconTile) : null,
        color: pair.tile,
      ),
      child: Center(
        child: DotIcon(glyph, color: pair.glyph, size: glyphSize),
      ),
    );
  }
}

/// The switch idiom (§4): Cupertino on iPhone, Material elsewhere — by
/// [DotIdiom], not `Switch.adaptive`, which would also give a Mac (and web
/// on a Mac) the iPhone switch while their layout is Material.
class DotSwitch extends StatelessWidget {
  const DotSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DotIdiom.of(context) == DotIdiom.cupertino
        ? CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: t.colors.accentFill,
          )
        : Switch(value: value, onChanged: onChanged);
  }
}

/// The open page's tint in Settings' list pane (M20.7 part 5a): iPad's
/// neutral fill and Android's rounded accent tint (E-R2-11, ED-291), the
/// web sidebar's selected colour on the Mac and the web (E-FullA-v2).
BoxDecoration paneSelectedFill(BuildContext context) {
  final c = DotTheme.of(context).colors;
  if (!touchApp(context)) return BoxDecoration(color: c.selectedWeb);
  if (DotIdiom.of(context) == DotIdiom.cupertino) {
    return BoxDecoration(color: c.paneSelectedIos);
  }
  return BoxDecoration(
    color: c.paneSelectedMaterial,
    borderRadius: BorderRadius.circular(DotRadii.paneRowAndroid),
  );
}

/// [line] made [row]'s tap target: a switch row toggles anywhere on it,
/// another opens [SettingsRow.onTap]; the open page's row is tinted.
Widget settingsRowTap(BuildContext context, SettingsRow row, Widget line) {
  if (row.toggle case final on?) {
    return MergeSemantics(
      child: InkWell(onTap: () => row.onToggle?.call(!on), child: line),
    );
  }
  final tap = InkWell(onTap: row.onTap, child: line);
  if (!row.selected) return tap;
  return Semantics(
    selected: true,
    child: Ink(decoration: paneSelectedFill(context), child: tap),
  );
}

/// A form status line's mark (ED-450): [glyph] on its tint in a small
/// circle, or an open ring while something is still under way.
class _FormMark extends StatelessWidget {
  const _FormMark({this.glyph, this.tint});

  final DotGlyph? glyph;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final g = glyph;
    final ink = tint ?? c.secondary;
    return Container(
      width: DotSize.formCheck + DotSpace.xs,
      height: DotSize.formCheck + DotSpace.xs,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: g == null
            ? null
            : ink.withValues(
                alpha: c.isDark ? TaskAlpha.tintDark : TaskAlpha.tintLight,
              ),
        border: g == null
            ? Border.all(color: c.hairlineStrong, width: 1.5)
            : null,
      ),
      child: g == null
          ? null
          : Center(
              child: DotIcon(
                g,
                color: ink,
                size: DotSize.formCheck - DotSpace.xs,
              ),
            ),
    );
  }
}
