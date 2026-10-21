import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Platform chrome that may differ (docs/10 §4, and only these): bar shape
/// and height, sheet handle, switch style, chip radius, FAB shape.
///
/// Layout never reads this; it adapts by `WidthClass`. Read from
/// `Theme.of(context).platform`, never `dart:io` `Platform`, so tests and
/// the web build pick it the same way.
enum DotIdiom {
  /// iPhone: floating pill tab bar, round add button, pill chips.
  cupertino,

  /// Android, web and any narrow Mac window (Mac ≡ web, §4): Material 3
  /// NavigationBar, rounded-square FAB, 8 px chips.
  material;

  static DotIdiom of(BuildContext context) =>
      !kIsWeb && Theme.of(context).platform == TargetPlatform.iOS
      ? cupertino
      : material;
}

/// The chip outline for this idiom: pill on iPhone, 8 px corners elsewhere
/// (§4). For `FilterChip.shape` and custom chips alike.
OutlinedBorder dotChipShape(BuildContext context) =>
    DotIdiom.of(context) == DotIdiom.cupertino
    ? const StadiumBorder()
    : RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.chipAndroid),
      );
