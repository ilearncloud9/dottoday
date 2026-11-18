import 'package:flutter/painting.dart';

/// Primitive colours shared by both themes.
///
/// With [DotPalette], the only file with raw hex values besides the
/// generated task palette. Widgets never read these: they read roles from
/// `DotTheme.of(context)`.
abstract final class DotPrimitives {
  static const white = Color(0xFFFFFFFF);

  /// Ink on the dark teal accent (ED-174).
  static const tealInk = Color(0xFF0C2523);
}

/// Concept E's colour values for one theme: light (E_DESIGN_RULES.md §4)
/// and dark P1 Warm Charcoal (ED-174 to ED-181). Every dark value is the
/// one the approved dark boards draw for the light value beside it.
final class DotPalette {
  const DotPalette._({
    required this.ground,
    required this.card,
    required this.sunk,
    required this.chip,
    required this.tile,
    required this.control,
    required this.sheet,
    required this.avatar,
    required this.canvas,
    required this.sidebarTint,
    required this.ink,
    required this.ink2,
    required this.secondary,
    required this.tertiary,
    required this.ring,
    required this.placeholder,
    required this.threadAhead,
    required this.threadOnRaised,
    required this.controlOutline,
    required this.hairline,
    required this.hairlineStrong,
    required this.calendarIcon,
    required this.tabOff,
    required this.accentText,
    required this.tonal,
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
    required this.success,
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
    required this.fabAndroid,
    required this.shadow,
  });

  static const light = DotPalette._(
    ground: Color(0xFFFBF7F1),
    card: Color(0xFFFFFDF9),
    sunk: Color(0xFFF6F1EA),
    chip: Color(0xFFEDE7DF),
    tile: Color(0xFFF1ECE4),
    control: Color(0xFFECE5DC),
    // Sheets sit on the page ground, cards inside (owner, ED-366).
    sheet: Color(0xFFFBF7F1),
    avatar: Color(0xFFE7DFEF),
    canvas: Color(0xFFEFE7DB),
    // The Mac sidebar's tint over the system material (ED-130): #EFE7DB
    // at 35 %.
    sidebarTint: Color(0x59EFE7DB),
    ink: Color(0xFF241F2B),
    ink2: Color(0xFF4E4757),
    secondary: Color(0xFF6A6273),
    tertiary: Color(0xFF7A7280),
    ring: Color(0xFF8A8494),
    placeholder: Color(0xFF6F6978),
    threadAhead: Color(0xFFBEB6C7),
    threadOnRaised: Color(0xFFBEB6C7),
    controlOutline: Color(0xFFCFC6D6),
    hairline: Color(0x14241F2B),
    hairlineStrong: Color(0x1F241F2B),
    calendarIcon: Color(0xFF3B3543),
    tabOff: Color(0xFF6E6E73),
    accentText: Color(0xFF0B4642),
    tonal: Color(0xFFE2EFEC),
    tonalAndroid: Color(0xFFCFE8E4),
    onTonalAndroid: Color(0xFF062F2C),
    selectedWeb: Color(0xFFD9ECE9),
    focus: Color(0xFF11615C),
    switchOn: Color(0xFF11615C),
    wakeCap: Color(0xFFFBEBC8),
    wakeIcon: Color(0xFF9A5A0E),
    windCap: Color(0xFFE6E3F7),
    windIcon: Color(0xFF4B3FB0),
    orbTrack: Color(0xFFE4E3F7),
    orbInner: Color(0xFFF1F0FB),
    destructive: Color(0xFFC8322F),
    swipeMove: Color(0xFF6A6273),
    success: Color(0xFF2FA37A),
    scrim: Color(0x4D241F2B),
    grabber: Color(0x4D3C3C43),
    menuAndroid: Color(0xFFF7EFF4),
    // The Undo toast (E-R2-7, ED-280): ink, cream words, light-teal action.
    toast: Color(0xFF2E2836),
    onToast: Color(0xFFFBF7F1),
    toastAction: Color(0xFFA3E2D9),
    // Android's floating toolbar and + (ED-125), before their frost.
    barAndroid: Color(0xFFF2EBE2),
    // The iPhone's glass capsules (ED-034), as E-Phones draws them: a
    // top-to-bottom fill over the blur and a light top edge.
    glassTop: Color(0x9EFFFFFF),
    glassBottom: Color(0x70FFFDF9),
    glassEdge: Color(0xE6FFFFFF),
    // The hour grid (E-FullA-v2 Week): hour lines at 6 %, day dividers 7 %.
    gridLine: Color(0x0F241F2B),
    gridDivider: Color(0x12241F2B),
    fabAndroid: Color(0xFFCFE8E4),
    shadow: Color(0xFF241F2B),
  );

  static const dark = DotPalette._(
    ground: Color(0xFF171416),
    card: Color(0xFF28232A),
    sunk: Color(0xFF1F1B1E),
    chip: Color(0xFF2F2A30),
    tile: Color(0xFF2F2A30),
    control: Color(0xFF37313A),
    sheet: Color(0xFF171416),
    avatar: Color(0xFF37313A),
    canvas: Color(0xFF28232A),
    // D1, #3B2F2A at 30 % (ED-176).
    sidebarTint: Color(0x4D3B2F2A),
    ink: Color(0xFFF3ECE4),
    ink2: Color(0xFFC7BEC4),
    secondary: Color(0xFFC7BEC4),
    tertiary: Color(0xFF8C838A),
    ring: Color(0xFF8C838A),
    placeholder: Color(0xFFA0999F),
    threadAhead: Color(0xFF6B6369),
    threadOnRaised: Color(0xFF7B7279),
    controlOutline: Color(0xFF4A4348),
    hairline: Color(0x1AFFF5EB),
    hairlineStrong: Color(0x29FFF5EB),
    calendarIcon: Color(0xFFE6DEE2),
    tabOff: Color(0xFFC7BEC4),
    accentText: Color(0xFFA3E2D9),
    tonal: Color(0xFF1E3A37),
    tonalAndroid: Color(0xFF1E3A37),
    onTonalAndroid: Color(0xFFA3E2D9),
    selectedWeb: Color(0xFF1E3A37),
    focus: Color(0xFF7FD6CB),
    switchOn: Color(0xFF2A8C83),
    wakeCap: Color(0xFF483924),
    wakeIcon: Color(0xFFD9A23A),
    windCap: Color(0xFF333148),
    windIcon: Color(0xFFA9ACEB),
    orbTrack: Color(0xFF302F48),
    orbInner: Color(0xFF28232A),
    destructive: Color(0xFFB5473C),
    swipeMove: Color(0xFF636366),
    success: Color(0xFF82CF9F),
    scrim: Color(0x99000000),
    grabber: Color(0x4DEBEBF5),
    menuAndroid: Color(0xFF37313A),
    toast: Color(0xFFF3ECE4),
    onToast: Color(0xFF171416),
    toastAction: Color(0xFF0B4642),
    barAndroid: Color(0xFF2B262A),
    glassTop: Color(0x19FFFFFF),
    glassBottom: Color(0xB82B262A),
    glassEdge: Color(0x25FFFFFF),
    gridLine: Color(0x14FFF5EB),
    gridDivider: Color(0x17FFF5EB),
    fabAndroid: Color(0xFF2B262A),
    shadow: Color(0xFF000000),
  );

  final Color ground,
      card,
      sunk,
      chip,
      tile,
      control,
      sheet,
      avatar,
      canvas,
      sidebarTint,
      ink,
      ink2,
      secondary,
      tertiary,
      ring,
      placeholder,
      threadAhead,
      threadOnRaised,
      controlOutline,
      hairline,
      hairlineStrong,
      calendarIcon,
      tabOff,
      accentText,
      tonal,
      tonalAndroid,
      onTonalAndroid,
      selectedWeb,
      focus,
      switchOn,
      wakeCap,
      wakeIcon,
      windCap,
      windIcon,
      orbTrack,
      orbInner,
      destructive,
      swipeMove,
      success,
      scrim,
      grabber,
      menuAndroid,
      toast,
      onToast,
      toastAction,
      barAndroid,
      glassTop,
      glassBottom,
      glassEdge,
      gridLine,
      gridDivider,
      fabAndroid,
      shadow;
}

/// Accent alphas on the hour grid (E-FullA-v2 Week; dark on its -Dark
/// board).
abstract final class GridAlpha {
  /// Today's column (light 3.5 %, dark 4 %).
  static const today = 0.035;
  static const todayDark = 0.04;

  /// Today's day header.
  static const todayHead = 0.05;

  /// The now line across every day, and on today's column.
  static const nowLine = 0.22;
  static const nowLineToday = 0.65;

  /// The now bead's 1 px edge in the gutter.
  static const nowBeadEdge = 0.3;

  /// Where a dragged task would land.
  static const drop = 0.07;
}
