import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// How far Settings' cards sit from the screen's edge: 16 on iPhone and
/// iPad (E-R2-24, ED-498) and on Android (E-R2-29, ED-499), the page
/// margin on the Mac and the web.
double settingsSide(BuildContext context) {
  if (DotIdiom.of(context) == DotIdiom.cupertino) return SettingsFrameSize.side;
  if (androidApp(context)) return SettingsAndroidSize.side;
  return DotSpace.page;
}

/// A Settings page's title: 34/41 on iPhone (ED-498), Roboto 22/28
/// regular beside ← on Android (ED-499), the page title elsewhere.
TextStyle settingsTitleStyle(BuildContext context) {
  final t = DotTheme.of(context);
  if (DotIdiom.of(context) == DotIdiom.cupertino) {
    return t.styles.pageTitle.copyWith(
      fontSize: SettingsFrameSize.title,
      height: SettingsFrameSize.titleLine / SettingsFrameSize.title,
    );
  }
  if (androidApp(context)) return SettingsAndroidType.title(t.colors);
  return t.styles.pageTitle;
}

/// [row] as Android draws a settings row (E-R2-29, ED-499): the 40
/// circle, the title, then its value or detail as a second line; a switch
/// or [SettingsRow.trailing] at the end and no chevron; 56 tall with one
/// line, 72 with two.
class AndroidSettingsRow extends StatelessWidget {
  const AndroidSettingsRow(this.row, {super.key});

  final SettingsRow row;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final r = row;
    final on = r.toggle;
    final two = r.value != null || r.subtitle != null || r.below != null;
    final line = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: two
            ? SettingsAndroidSize.rowTwo
            : SettingsAndroidSize.rowOne,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: r.flush ? 0 : SettingsAndroidSize.rowPadH,
          vertical: SettingsAndroidSize.rowPadV,
        ),
        child: Row(
          spacing: SettingsAndroidSize.gap,
          children: [
            ?_lead(r),
            Expanded(child: _texts(c)),
            ?r.trailing,
            if (on != null) DotSwitch(value: on, onChanged: r.onToggle),
          ],
        ),
      ),
    );
    return settingsRowTap(context, r, line);
  }

  Widget? _lead(SettingsRow r) {
    if (r.dot case final colour?) {
      return ExcludeSemantics(
        child: SizedBox.square(
          dimension: DotSize.settingsDot,
          child: DecoratedBox(
            decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
          ),
        ),
      );
    }
    if (r.bare) return null;
    return SettingsIcon(glyph: r.glyph, tint: r.tint);
  }

  Widget _texts(DotColors c) {
    final r = row;
    final title = SettingsAndroidType.row(c);
    final second = SettingsAndroidType.second(c);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r.title,
          style: r.action
              ? title.copyWith(color: c.accentText)
              : r.quiet
              ? title.copyWith(color: c.secondary)
              : title,
        ),
        if (r.value case final v?)
          Text(
            v,
            style: r.accentValue
                ? second.copyWith(color: c.accentText)
                : second,
          ),
        if (r.subtitle case final s?) Text(s, style: second),
        ?r.below,
      ],
    );
  }
}
