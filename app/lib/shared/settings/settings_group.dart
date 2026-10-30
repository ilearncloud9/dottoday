import 'package:dottoday/core/theme/dot_theme.dart';
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
    super.key,
  });

  final String caption;
  final List<Widget> children;

  /// A muted note under the card ("Learning happens on your device …").
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        // No caption: minimal Settings' one group (docs/14 §4 "no sections").
        if (caption.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
            child: Semantics(
              header: true,
              child: Text(caption.toUpperCase(), style: t.styles.caption),
            ),
          ),
        Material(
          color: t.colors.raised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DotRadii.cardLarge),
            side: BorderSide(color: t.colors.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0) Divider(height: 1, color: t.colors.outline),
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
              style: t.styles.rowMeta.copyWith(color: t.colors.muted),
            ),
          ),
      ],
    );
  }
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
    super.key,
  });

  final DotGlyph glyph;

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

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final on = toggle;
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: settingsRowHeight(context)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.l,
          vertical: DotSpace.s,
        ),
        child: Row(
          spacing: DotSpace.m,
          children: [
            _Icon(glyph: glyph, tint: tint),
            Expanded(child: _texts(t)),
            if (value case final v?)
              // As wide as it needs, up to 45 % of the row: short values
              // leave the title room, long ones wrap instead of overflow.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * _valueShare,
                ),
                child: Text(
                  v,
                  textAlign: TextAlign.end,
                  style: t.styles.body.copyWith(color: t.colors.muted),
                ),
              ),
            ?trailing,
            if (on != null)
              DotSwitch(value: on, onChanged: onToggle)
            else if (onTap != null)
              DotIcon(
                DotGlyphs.chevronRight,
                color: t.colors.muted,
                size: DotSize.rowIcon,
              ),
          ],
        ),
      ),
    );
    if (on != null) {
      return MergeSemantics(
        child: InkWell(onTap: () => onToggle?.call(!on), child: row),
      );
    }
    return InkWell(onTap: onTap, child: row);
  }

  Widget _texts(DotTheme t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: t.styles.rowTitle),
      if (subtitle case final s?) Text(s, style: t.styles.rowMeta),
      ?below,
    ],
  );
}

class _Icon extends StatelessWidget {
  const _Icon({required this.glyph, required this.tint});

  final DotGlyph glyph;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    width: DotSize.rowDot,
    height: DotSize.rowDot,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: tint.withValues(
        alpha: DotTheme.of(context).colors.isDark
            ? TaskAlpha.tintDark
            : TaskAlpha.tintLight,
      ),
    ),
    child: Center(
      child: DotIcon(glyph, color: tint, size: DotSize.rowIcon),
    ),
  );
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
