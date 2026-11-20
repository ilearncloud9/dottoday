import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/recent_icons.dart';
import 'package:dottoday/domain/icon_guess/icon_guess.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Icons [title] suggests, guessed on the device (ED-086 "Suggested").
List<TaskIcon> suggestedIcons(BuildContext context, String title) => [
  for (final k in guessIconKeys(
    title,
    language: Localizations.localeOf(context).languageCode,
  ))
    TaskIcon.fromKey(k),
];

/// The icons last picked on this device, newest first (owner, 4c).
List<TaskIcon> recentIcons(WidgetRef ref) => [
  for (final k in ref.watch(recentIconsProvider).value ?? const <String>[])
    TaskIcon.fromKey(k),
].where((i) => i.glyph != null).toList();
