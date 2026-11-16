import 'dart:ui' show Brightness;

import 'package:dottoday/core/theme/contrast.dart';
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
/// Text('Today', style: TextStyle(color: c.accentInk));
/// ```
final class DotColors {
  const DotColors._({
    required this.brightness,
    required this.surface,
    required this.raised,
    required this.text,
    required this.muted,
    required this.outline,
    required this.threadAhead,
    required this.accent,
    required this.accentInk,
    required this.onAccent,
    required this.accentFill,
    required this.accentTint,
    required this.success,
    required this.sunk,
    required this.chip,
    required this.tile,
    required this.control,
    required this.sheet,
    required this.avatar,
    required this.canvas,
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
    required this.shadow,
  });

  /// Light roles with [accent] (Settings › Appearance).
  factory DotColors.light([DotAccent accent = DotAccent.fallback]) =>
      _resolve(Brightness.light, accent.light);

  /// Dark roles with [accent] (Settings › Appearance).
  factory DotColors.dark([DotAccent accent = DotAccent.fallback]) =>
      _resolve(Brightness.dark, accent.dark);

  final Brightness brightness;

  /// E `ground`: the page background.
  final Color surface;

  /// E card: cards, sheets, the now card (`#FFFDF9` / `#28232A`).
  final Color raised;

  /// E `ink`: primary text and active icons.
  final Color text;

  /// E `secondary`: times, summaries, labels.
  final Color muted;

  /// Row and card edges, opaque over [raised] (Concept E: [hairline]).
  final Color outline;

  /// The dotted thread ahead and free-time dots.
  final Color threadAhead;

  /// The accent: Add, Done, selected tab, now-bead, sync dot.
  final Color accent;

  /// E accent text: links, chip text, text on [accentTint].
  final Color accentInk;

  /// Text and icons on an [accent] fill.
  final Color onAccent;

  /// Buttons with text on them: [accent], deepened (light) or brightened
  /// (dark) only when [onAccent] would fall under 5:1 (ED-161's derived
  /// shade for App colours).
  final Color accentFill;

  /// E tonal: chips, the Focus tile, +5 / +15 / +30.
  final Color accentTint;

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

  /// Dark sheet level (light sheets are [raised]).
  final Color sheet;

  /// Profile circle.
  final Color avatar;

  /// Workspace time grid.
  final Color canvas;

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

  /// Base colour of elevation shadows (see `DotElevation`).
  final Color shadow;

  // Concept E names for the roles above that still carry Concept A names.
  // Rebuilt widgets read only these (test/policy/concept_e_names_test.dart);
  // plan M20.14 renames the fields and deletes the old names (ED-360).

  /// The page background (Concept A name: [surface]).
  Color get ground => surface;

  /// Cards, sheets, the now card (Concept A name: [raised]).
  Color get card => raised;

  /// Primary text and active icons (Concept A name: [text]).
  Color get ink => text;

  /// Times, summaries, labels (Concept A name: [muted]).
  Color get secondary => muted;

  /// Row and card edges (Concept A name: [outline]).
  Color get hairline => outline;

  /// Links, chip text, text on [tonal] (Concept A name: [accentInk]).
  Color get accentText => accentInk;

  /// Chips, the Focus tile, +5 / +15 / +30 (Concept A name: [accentTint]).
  Color get tonal => accentTint;

  bool get isDark => brightness == Brightness.dark;

  /// The night on a day dot (docs/15 W6): [text] over [surface] at 12 %
  /// (light) or 18 % (dark), opaque. Faint by design, never a warning.
  Color get night =>
      Color.alphaBlend(text.withValues(alpha: isDark ? 0.18 : 0.12), surface);

  /// Interpolates every role; used by theme animations.
  DotColors lerp(DotColors other, double t) {
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return DotColors._(
      brightness: t < 0.5 ? brightness : other.brightness,
      surface: l(surface, other.surface),
      raised: l(raised, other.raised),
      text: l(text, other.text),
      muted: l(muted, other.muted),
      outline: l(outline, other.outline),
      threadAhead: l(threadAhead, other.threadAhead),
      accent: l(accent, other.accent),
      accentInk: l(accentInk, other.accentInk),
      onAccent: l(onAccent, other.onAccent),
      accentFill: l(accentFill, other.accentFill),
      accentTint: l(accentTint, other.accentTint),
      success: l(success, other.success),
      sunk: l(sunk, other.sunk),
      chip: l(chip, other.chip),
      tile: l(tile, other.tile),
      control: l(control, other.control),
      sheet: l(sheet, other.sheet),
      avatar: l(avatar, other.avatar),
      canvas: l(canvas, other.canvas),
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
      shadow: l(shadow, other.shadow),
    );
  }
}

DotColors _resolve(Brightness brightness, Color accent) {
  final dark = brightness == Brightness.dark;
  final p = dark ? DotPalette.dark : DotPalette.light;
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
    surface: p.ground,
    raised: p.card,
    text: p.ink,
    muted: p.secondary,
    outline: Color.alphaBlend(p.hairline, p.card),
    threadAhead: p.threadAhead,
    accent: accent,
    accentInk: accentText,
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
    accentTint: tonal,
    success: p.success,
    sunk: p.sunk,
    chip: p.chip,
    tile: p.tile,
    control: p.control,
    sheet: p.sheet,
    avatar: p.avatar,
    canvas: p.canvas,
    ink2: p.ink2,
    tertiary: p.tertiary,
    ring: p.ring,
    placeholder: p.placeholder,
    threadOnRaised: p.threadOnRaised,
    controlOutline: p.controlOutline,
    hairlineStrong: Color.alphaBlend(p.hairlineStrong, p.card),
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
    shadow: p.shadow,
  );
}
