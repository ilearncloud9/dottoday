import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';

/// Which dawn the mission screen is drawn on (ED-459): the light one, or
/// E-R2-19-B-Dark's in dark mode. The screen itself reads in the dark
/// theme either way, so the app's own brightness is taken before that and
/// handed down here.
class DawnSkyScope extends InheritedWidget {
  const DawnSkyScope({required this.sky, required super.child, super.key});

  final DawnSky sky;

  /// The nearest sky, or the light dawn when there is none.
  static DawnSky of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DawnSkyScope>()?.sky ??
      DawnSky.light;

  @override
  bool updateShouldNotify(DawnSkyScope old) => old.sky != sky;
}
