import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether Routines is its own place in the content area: the Mac and the
/// web in Full, where the Workspace sidebar lists it (E-R2-30, ED-451,
/// ED-500). Settings then shows it without its list pane, and the page
/// draws as the board does: one column, its count in a pill. Elsewhere it
/// stays Settings › Planning › Routines.
///
/// ```dart
/// if (watchRoutinesAlone(context, ref)) return navigator; // no list pane
/// ```
bool watchRoutinesAlone(BuildContext context, WidgetRef ref) =>
    !touchApp(context) && !watchSimplified(ref, FeatureId.navigation);
