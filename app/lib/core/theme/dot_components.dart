import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:dottoday/core/theme/dot_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Concept E's shared surfaces as Material component themes (M18.4 part
/// 1, E-Phones-2, rules §6.3–6.4, §7): sheets, dialogs, chips and menus.
/// Built per platform, as `DotTheme` caches ThemeData by platform.
final class DotComponents {
  DotComponents(this.c, this.type, this.platform);

  final DotColors c;
  final DotType type;
  final TargetPlatform platform;

  bool get _ios => !kIsWeb && platform == TargetPlatform.iOS;
  bool get _android => !kIsWeb && platform == TargetPlatform.android;

  /// Sheets sit on the page ground with cards inside (ED-366): 38 top
  /// corners and the system grabber on iPhone, 28 and a 32 × 4 handle on
  /// Android.
  BottomSheetThemeData get sheet => BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: c.sheet,
    modalBackgroundColor: c.sheet,
    surfaceTintColor: Colors.transparent,
    modalBarrierColor: c.scrim,
    shadowColor: c.shadow,
    modalElevation: _sheetLift,
    dragHandleColor: _ios ? c.grabber : c.ring,
    dragHandleSize: _ios ? DotSize.grabber : DotSize.handleAndroid,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(_ios ? DotRadii.sheetIos : DotRadii.sheet),
      ),
    ),
  );

  /// A question or a wide-screen sheet: the sheet's ground, radius 28
  /// (rules §7.2), never wider than a prompt (CR-160 B7 gate, G2).
  DialogThemeData get dialog => DialogThemeData(
    constraints: const BoxConstraints(
      minWidth: DotSize.dialogMin,
      maxWidth: DotSize.promptWidth,
    ),
    backgroundColor: c.sheet,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(DotRadii.sheet)),
    ),
  );

  /// Chips (E-Phones-2 "Today ✓ · Tomorrow"): 34 tall, fully round, 700
  /// 14; picked in the accent with a white check, the rest tonal. The hit
  /// area stays 44 / 48 (padded tap targets, rules §6.4).
  ChipThemeData get chip => ChipThemeData(
    shape: const StadiumBorder(),
    side: BorderSide.none,
    showCheckmark: true,
    checkmarkColor: c.onAccent,
    labelPadding: EdgeInsets.zero,
    padding: const EdgeInsets.symmetric(
      horizontal: DotSpace.m + DotSpace.xxs,
      vertical: DotSpace.s,
    ),
    color: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled)
          ? c.control
          : s.contains(WidgetState.selected)
          ? c.accentFill
          : c.accentTint,
    ),
    // The chip resolves its state from the label's colour, not the style.
    labelStyle: type.chip.copyWith(
      color: WidgetStateColor.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? c.muted
            : s.contains(WidgetState.selected)
            ? c.onAccent
            : c.accentInk,
      ),
    ),
    iconTheme: IconThemeData(color: c.accentInk, size: DotSize.rowIcon),
  );

  /// Menus drawn in Flutter: the iOS pull-down's 26 corners, the Android
  /// M3 menu (22, its own tint), 10 on Mac and the web (ED-239). The
  /// native menus come with the shell (M18.5).
  MenuStyle get menu => MenuStyle(
    backgroundColor: WidgetStatePropertyAll(_menuFill),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    elevation: const WidgetStatePropertyAll(_menuLift),
    shadowColor: WidgetStatePropertyAll(c.shadow),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(_menuRadius)),
    ),
  );

  PopupMenuThemeData get popupMenu => PopupMenuThemeData(
    color: _menuFill,
    surfaceTintColor: Colors.transparent,
    elevation: _menuLift,
    shadowColor: c.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_menuRadius),
    ),
  );

  /// An error at a field turns its line ink and 2 px (E-G4-7-States D);
  /// the words come from `FieldError`.
  InputDecorationTheme get input => InputDecorationTheme(
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: c.text, width: DotSize.smallDotOutline),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: c.text, width: DotSize.smallDotOutline),
    ),
    errorStyle: type.fieldError,
  );

  /// Segmented choices (E-G4-7-States D, "check + weight, not colour
  /// alone"): a pill track, the picked segment on the card colour with
  /// its check and 700, the rest 600 in ink2.
  SegmentedButtonThemeData get segmented => SegmentedButtonThemeData(
    style: ButtonStyle(
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      side: const WidgetStatePropertyAll(BorderSide.none),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.raised : c.tile,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? c.ring
            : s.contains(WidgetState.selected)
            ? c.text
            : c.ink2,
      ),
      textStyle: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? type.chip
            : type.chip.copyWith(
                fontWeight: FontWeight.w600,
                fontVariations: const [FontVariation.weight(_unpicked)],
              ),
      ),
    ),
  );

  /// The unpicked segment's weight (600).
  static const double _unpicked = 600;

  Color get _menuFill => _android ? c.menuAndroid : c.raised;

  double get _menuRadius => _ios
      ? DotRadii.pullDownIos
      : _android
      ? DotRadii.menuAndroid
      : DotRadii.menuMac;

  /// Material elevations standing in for the drawn shadows: the sheet's
  /// `0 -10 40` at 18 %, the menu's `0 8 18`.
  static const double _sheetLift = 10;
  static const double _menuLift = 8;
}
