import 'dart:ui' show Brightness;

import 'package:dottoday/core/theme/contrast.dart';
import 'package:dottoday/core/theme/dot_contrast.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:dottoday/core/theme/tokens.dart';
import 'package:flutter/painting.dart';

/// Concept E colour roles for one brightness and one accent
/// (docs/redesign/E_DESIGN_RULES.md §4 and §10; ED-174 to ED-181), with
/// the light → dark pairs measured on the approved boards (ED-181).
///
/// The first block keeps the names widgets already read, now with Concept
/// E's meaning; the rest are Concept E roles the slices adopt as they are
/// rebuilt.
///
/// ```dart
/// final c = DotTheme.of(context).colors;
/// Text('Today', style: TextStyle(color: c.accentText));
/// ```
final class DotColors {
  const DotColors._({
    required this.brightness,
    required this.ground,
    required this.card,
    required this.ink,
    required this.secondary,
    required this.hairline,
    required this.threadAhead,
    required this.accent,
    required this.accentText,
    required this.onAccent,
    required this.accentFill,
    required this.tonal,
    required this.success,
    required this.sunk,
    required this.chip,
    required this.tile,
    required this.control,
    required this.sheet,
    required this.avatar,
    required this.canvas,
    required this.sidebarTint,
    required this.ink2,
    required this.tertiary,
    required this.ring,
    required this.placeholder,
    required this.threadOnRaised,
    required this.controlOutline,
    required this.hairlineStrong,
    required this.calendarIcon,
    required this.tabOff,
    required this.tonalAndroid,
    required this.onTonalAndroid,
    required this.selectedWeb,
    required this.focus,
    required this.switchOn,
    required this.wakeCap,
    required this.wakeIcon,
    required this.windCap,
    required this.windIcon,
    required this.orbTrack,
    required this.orbInner,
    required this.destructive,
    required this.swipeMove,
    required this.scrim,
    required this.grabber,
    required this.menuAndroid,
    required this.toast,
    required this.onToast,
    required this.toastAction,
    required this.barAndroid,
    required this.glassTop,
    required this.glassBottom,
    required this.glassEdge,
    required this.gridLine,
    required this.gridDivider,
    required this.blockEdge,
    required this.fabAndroid,
    required this.shadow,
  });

  /// Light roles with [accent] (Settings › Appearance).
  factory DotColors.light([DotAccent accent = DotAccent.fallback]) =>
      _resolve(Brightness.light, accent.light);

  /// Dark roles with [accent] (Settings › Appearance).
  factory DotColors.dark([DotAccent accent = DotAccent.fallback]) =>
      _resolve(Brightness.dark, accent.dark);

  /// [brightness]'s roles around a custom App colour (ED-161, ED-221): text
  /// and fills derived for 4.5:1, the colour itself never changed.
  factory DotColors.custom(Brightness brightness, Color accent) =>
      _resolve(brightness, accent);

  /// These roles with Increase Contrast on (ED-248 C, E-G4-7-States D4):
  /// secondary text a step further from the ground, the thread ahead and
  /// every edge at the tertiary colour (3:1 or more).
  DotColors moreContrast() => _moreCache[(brightness, accent)] ??= _resolve(
    brightness,
    accent,
    more: true,
  );

  static final _moreCache = <(Brightness, Color), DotColors>{};

  final Brightness brightness;

  /// E `ground`: the page background.
  final Color ground;

  /// E card: cards, sheets, the now card (`#FFFDF9` / `#28232A`).
  final Color card;

  /// E `ink`: primary text and active icons.
  final Color ink;

  /// E `secondary`: times, summaries, labels.
  final Color secondary;

  /// Row and card edges, opaque over [card].
  final Color hairline;

  /// The dotted thread ahead and free-time dots.
  final Color threadAhead;

  /// The accent: Add, Done, selected tab, now-bead, sync dot.
  final Color accent;

  /// E accent text: links, chip text, text on [tonal].
  final Color accentText;

  /// Text and icons on an [accent] fill.
  final Color onAccent;

  /// Buttons with text on them: [accent], deepened (light) or brightened
  /// (dark) only when [onAccent] would fall under 5:1 (ED-161's derived
  /// shade for App colours).
  final Color accentFill;

  /// E tonal: chips, the Focus tile, +5 / +15 / +30.
  final Color tonal;

  /// Done check on a completed day; synced.
  final Color success;

  /// E sunk: the Add field, grouped rows in sheets, the inspector.
  final Color sunk;

  /// Chip and segmented fills, the empty-day ring.
  final Color chip;

  /// Secondary action tiles (Move, Shift the rest).
  final Color tile;

  /// Mac capsules and Close buttons; dark menus and popovers.
  final Color control;

  /// Sheets: the page ground, with cards inside (E-Phones-2, ED-366).
  final Color sheet;

  /// Profile circle.
  final Color avatar;

  /// Workspace time grid.
  final Color canvas;

  /// The Mac sidebar's warm tint over the system's vibrant material
  /// (ED-130, ED-176); [canvas] where the material can't show.
  final Color sidebarTint;

  /// Body copy, Android icons, menu headers.
  final Color ink2;

  /// Calendar-event dot ring.
  final Color tertiary;

  /// Open done-check ring, handles, the Inbox dot ring.
  final Color ring;

  /// Placeholders such as "Add a step" (ED-179).
  final Color placeholder;

  /// The dotted thread on a lighter surface (dark only differs, ED-179).
  final Color threadOnRaised;

  /// Control and outlined-button borders (1.5 px).
  final Color controlOutline;

  /// Inputs and menu dividers.
  final Color hairlineStrong;

  /// The icon inside a calendar-event dot.
  final Color calendarIcon;

  /// Inactive iPhone tab labels (ED-154).
  final Color tabOff;

  /// Android M3 nav pill, FAB and tonal buttons, and the text on them.
  final Color tonalAndroid;
  final Color onTonalAndroid;

  /// The web sidebar's selected row.
  final Color selectedWeb;

  /// Keyboard focus ring, drawn after a 2 px gap (ED-174, ED-211).
  final Color focus;

  /// iOS switch on tint (ED-112, ED-174).
  final Color switchOn;

  /// Wake Up sun cap and its icon; Wind Down moon cap and its icon.
  final Color wakeCap;
  final Color wakeIcon;
  final Color windCap;
  final Color windIcon;

  /// The now ring's track on wide windows and the orb; the orb's centre.
  final Color orbTrack;
  final Color orbInner;

  /// Swipe Delete only; never for unfinished tasks (no-shame rule).
  final Color destructive;

  /// Swipe Move.
  final Color swipeMove;

  /// Modal dimming.
  final Color scrim;

  /// The iOS sheet grabber (the system's, 30 %).
  final Color grabber;

  /// Android menus (M3 menu on E-Phones-2).
  final Color menuAndroid;

  /// The Undo toast (E-R2-7, ED-280): its surface, words and action; the
  /// other way round in dark (cream, with dark teal).
  final Color toast;
  final Color onToast;
  final Color toastAction;

  /// Android's floating toolbar and its + (ED-125): solid here, frosted
  /// at [ChromeAlpha] on Android 12+.
  final Color barAndroid;

  /// The iPhone glass capsule's fill, top to bottom, over its blur, and
  /// its light top edge (ED-034).
  final Color glassTop;
  final Color glassBottom;
  final Color glassEdge;

  /// The hour grid's hour lines and day dividers (E-FullA-v2 Week).
  final Color gridLine;
  final Color gridDivider;

  /// A Workspace block's edge on hover and while dragged (ED-116); its
  /// hover fill is [sunk] (#F5F1EB on the board, dark #1F1B1E).
  final Color blockEdge;
  final Color fabAndroid;

  /// Base colour of elevation shadows (see `DotElevation`).
  final Color shadow;

  /// A picked row in a list of choices: the accent at 8 % (E-R2-34's
  /// one-thing pick).
  Color get selectedRow => accent.withValues(alpha: 0.08);

  /// The open page's row in Settings' list pane on iPad: ink at 8 %
  /// (light), cream at 10 % (dark) (E-R2-11, ED-291).
  Color get paneSelectedIos =>
      isDark ? const Color(0x1AFFF5EB) : const Color(0x14241F2B);

  /// The same on Android tablets: the accent at 12 % (E-R2-11, M3
  /// list-detail). The Mac and the web use [selectedWeb] (E-FullA-v2).
  Color get paneSelectedMaterial => accent.withValues(alpha: 0.12);

  bool get isDark => brightness == Brightness.dark;

  /// Today's column on the hour grid, its header, the now line across the
  /// grid and its stronger stretch on today (E-FullA-v2 Week).
  Color get gridToday =>
      accent.withValues(alpha: isDark ? GridAlpha.todayDark : GridAlpha.today);
  Color get gridTodayHead => accent.withValues(alpha: GridAlpha.todayHead);
  Color get nowLine => accent.withValues(alpha: GridAlpha.nowLine);
  Color get nowLineToday => accent.withValues(alpha: GridAlpha.nowLineToday);

  /// The now bead's edge in the gutter (E-FullA-v2 Week).
  Color get nowBeadEdge => accent.withValues(alpha: GridAlpha.nowBeadEdge);

  /// Where a dragged task would land on the hour grid.
  Color get gridDrop => accent.withValues(alpha: GridAlpha.drop);

  /// The night on a day dot (docs/15 W6): [ink] over [ground] at 12 %
  /// (light) or 18 % (dark), opaque. Faint by design, never a warning.
  Color get night =>
      Color.alphaBlend(ink.withValues(alpha: isDark ? 0.18 : 0.12), ground);

  /// Interpolates every role; used by theme animations.
  DotColors lerp(DotColors other, double t) {
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return DotColors._(
      brightness: t < 0.5 ? brightness : other.brightness,
      ground: l(ground, other.ground),
      card: l(card, other.card),
      ink: l(ink, other.ink),
      secondary: l(secondary, other.secondary),
      hairline: l(hairline, other.hairline),
      threadAhead: l(threadAhead, other.threadAhead),
      accent: l(accent, other.accent),
      accentText: l(accentText, other.accentText),
      onAccent: l(onAccent, other.onAccent),
      accentFill: l(accentFill, other.accentFill),
      tonal: l(tonal, other.tonal),
      success: l(success, other.success),
      sunk: l(sunk, other.sunk),
      chip: l(chip, other.chip),
      tile: l(tile, other.tile),
      control: l(control, other.control),
      sheet: l(sheet, other.sheet),
      avatar: l(avatar, other.avatar),
      canvas: l(canvas, other.canvas),
      sidebarTint: l(sidebarTint, other.sidebarTint),
      ink2: l(ink2, other.ink2),
      tertiary: l(tertiary, other.tertiary),
      ring: l(ring, other.ring),
      placeholder: l(placeholder, other.placeholder),
      threadOnRaised: l(threadOnRaised, other.threadOnRaised),
      controlOutline: l(controlOutline, other.controlOutline),
      hairlineStrong: l(hairlineStrong, other.hairlineStrong),
      calendarIcon: l(calendarIcon, other.calendarIcon),
      tabOff: l(tabOff, other.tabOff),
      tonalAndroid: l(tonalAndroid, other.tonalAndroid),
      onTonalAndroid: l(onTonalAndroid, other.onTonalAndroid),
      selectedWeb: l(selectedWeb, other.selectedWeb),
      focus: l(focus, other.focus),
      switchOn: l(switchOn, other.switchOn),
      wakeCap: l(wakeCap, other.wakeCap),
      wakeIcon: l(wakeIcon, other.wakeIcon),
      windCap: l(windCap, other.windCap),
      windIcon: l(windIcon, other.windIcon),
      orbTrack: l(orbTrack, other.orbTrack),
      orbInner: l(orbInner, other.orbInner),
      destructive: l(destructive, other.destructive),
      swipeMove: l(swipeMove, other.swipeMove),
      scrim: l(scrim, other.scrim),
      grabber: l(grabber, other.grabber),
      menuAndroid: l(menuAndroid, other.menuAndroid),
      toast: l(toast, other.toast),
      onToast: l(onToast, other.onToast),
      toastAction: l(toastAction, other.toastAction),
      barAndroid: l(barAndroid, other.barAndroid),
      glassTop: l(glassTop, other.glassTop),
      glassBottom: l(glassBottom, other.glassBottom),
      glassEdge: l(glassEdge, other.glassEdge),
      gridLine: l(gridLine, other.gridLine),
      gridDivider: l(gridDivider, other.gridDivider),
      blockEdge: l(blockEdge, other.blockEdge),
      fabAndroid: l(fabAndroid, other.fabAndroid),
      shadow: l(shadow, other.shadow),
    );
  }
}

DotColors _resolve(Brightness brightness, Color accent, {bool more = false}) {
  final dark = brightness == Brightness.dark;
  final p = dark ? DotPalette.dark : DotPalette.light;
  // Increase Contrast (ED-248 C): edges and the thread at tertiary.
  final edge = more ? p.tertiary : null;
  final isTeal =
      accent == DotAccent.teal.light || accent == DotAccent.teal.dark;
  // White on the light accents, teal ink on the dark ones (ED-174).
  final onAccent =
      contrastRatio(DotPrimitives.white, accent) >=
          contrastRatio(DotPrimitives.tealInk, accent)
      ? DotPrimitives.white
      : DotPrimitives.tealInk;
  // Teal has Concept E's own text and tonal pair; another App colour gets
  // the same roles derived from it (ED-161).
  final tonal = isTeal
      ? p.tonal
      : Color.alphaBlend(accent.withValues(alpha: dark ? 0.22 : 0.12), p.card);
  final accentText = isTeal
      ? p.accentText
      : inkFor(accent, backgrounds: [p.ground, p.card, tonal], toward: p.ink);
  return DotColors._(
    brightness: brightness,
    ground: p.ground,
    card: p.card,
    ink: p.ink,
    secondary: more ? DotContrast.secondary(brightness) : p.secondary,
    hairline: edge ?? Color.alphaBlend(p.hairline, p.card),
    threadAhead: edge ?? p.threadAhead,
    accent: accent,
    accentText: accentText,
    onAccent: onAccent,
    accentFill: inkFor(
      accent,
      backgrounds: [onAccent],
      // Deeper under white text, lighter under teal ink.
      toward: onAccent == DotPrimitives.white
          ? DotPalette.light.ink
          : DotPalette.dark.ink,
      // Bold glyphs on a coloured fill anti-alias darker than the nominal
      // colour; aim higher so the rendered text clears 4.5.
      minRatio: 5,
    ),
    tonal: tonal,
    success: p.success,
    sunk: p.sunk,
    chip: p.chip,
    tile: p.tile,
    control: p.control,
    sheet: p.sheet,
    avatar: p.avatar,
    canvas: p.canvas,
    sidebarTint: p.sidebarTint,
    ink2: p.ink2,
    tertiary: p.tertiary,
    ring: p.ring,
    placeholder: p.placeholder,
    threadOnRaised: edge ?? p.threadOnRaised,
    controlOutline: edge ?? p.controlOutline,
    hairlineStrong: edge ?? Color.alphaBlend(p.hairlineStrong, p.card),
    calendarIcon: p.calendarIcon,
    tabOff: p.tabOff,
    tonalAndroid: p.tonalAndroid,
    onTonalAndroid: p.onTonalAndroid,
    selectedWeb: p.selectedWeb,
    focus: isTeal ? p.focus : accentText,
    switchOn: p.switchOn,
    wakeCap: p.wakeCap,
    wakeIcon: p.wakeIcon,
    windCap: p.windCap,
    windIcon: p.windIcon,
    orbTrack: p.orbTrack,
    orbInner: p.orbInner,
    destructive: p.destructive,
    swipeMove: p.swipeMove,
    scrim: p.scrim,
    grabber: p.grabber,
    menuAndroid: p.menuAndroid,
    toast: p.toast,
    onToast: p.onToast,
    toastAction: p.toastAction,
    barAndroid: p.barAndroid,
    glassTop: p.glassTop,
    glassBottom: p.glassBottom,
    glassEdge: p.glassEdge,
    gridLine: p.gridLine,
    gridDivider: p.gridDivider,
    blockEdge: edge ?? p.blockEdge,
    fabAndroid: p.fabAndroid,
    shadow: p.shadow,
  );
}
