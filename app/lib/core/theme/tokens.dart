import 'package:flutter/painting.dart';

/// Primitive colours, named by what they look like, not by role: Concept E
/// light (docs/redesign/E_DESIGN_RULES.md §4.1, M18.1) and dark, the P1
/// Warm Charcoal set (ED-174, ED-178; M18.2).
///
/// The only file with raw hex values besides the generated task palette.
/// Widgets never read these: they read roles from `DotTheme.of(context)`.
abstract final class DotPrimitives {
  /// E `ground`: the app background.
  static const ground = Color(0xFFFBF7F1);

  /// E `surface`: cards, sheets, popovers.
  static const cream = Color(0xFFFFFDF9);
  static const white = Color(0xFFFFFFFF);

  /// E `ink`: primary text (15.07:1 on [ground]).
  static const ink = Color(0xFF241F2B);

  /// E `secondary`: times, summaries, labels (5.45:1 on [ground]).
  static const grey6A = Color(0xFF6A6273);

  /// E `hairline`: rgba(36,31,43,.08), row and card edges.
  static const hairline = Color(0x14241F2B);

  /// E `threadAhead`: the dotted thread and free-time dots.
  static const lilacBE = Color(0xFFBEB6C7);

  /// Dark `ground`: the app background.
  static const charcoal17 = Color(0xFF171416);

  /// Dark `surface`: cards and sheets.
  static const charcoal1F = Color(0xFF1F1B1E);

  /// Dark `text` (on ground 15.6:1).
  static const linen = Color(0xFFF3ECE4);

  /// Dark `secondary`.
  static const greyC7 = Color(0xFFC7BEC4);

  /// Dark `divider`: hairlines and card edges.
  static const charcoal3E = Color(0xFF3E373D);

  /// Dark dotted thread ahead (T2-B, ED-178: 3.15:1 on ground).
  static const mauve6B = Color(0xFF6B6369);

  /// Ink on the dark teal accent (ED-174).
  static const tealInk = Color(0xFF0C2523);

  /// Light success (done check on a completed day).
  static const green2F = Color(0xFF2FA37A);

  /// Dark success (ED-174).
  static const green82 = Color(0xFF82CF9F);

  /// Floating-element shadow, E ink at 10 %.
  static const shadow = Color(0x1A241F2B);
}
