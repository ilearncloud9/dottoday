import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/layout/feature_id.dart';
import 'package:dottoday/features/layout/layout_policy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'layout_providers.g.dart';

/// The stored layout (docs/14 §6), full until the profile has loaded.
/// Only the layout switch and [layoutPolicy] read it; Views ask the policy.
@Riverpod(keepAlive: true)
UiLayout uiLayout(Ref ref) => ref.watch(
  currentProfileProvider.select(
    (p) => p.value?.settings.uiLayout ?? UiLayout.full,
  ),
);

/// The visibility policy for the stored layout (ADR-0016).
@Riverpod(keepAlive: true)
LayoutPolicy layoutPolicy(Ref ref) => LayoutPolicy(ref.watch(uiLayoutProvider));

/// How [feature] shows now; rebuilds the caller only when that changes.
FeatureVisibility watchFeature(WidgetRef ref, FeatureId feature) =>
    ref.watch(layoutPolicyProvider.select((p) => p.visibility(feature)));

/// Whether [feature]'s entry point is drawn now (shown or simplified).
bool watchOnScreen(WidgetRef ref, FeatureId feature) =>
    watchFeature(ref, feature).onScreen;

/// Whether [feature] is drawn in its simplified, minimal form now.
bool watchSimplified(WidgetRef ref, FeatureId feature) =>
    watchFeature(ref, feature) == FeatureVisibility.simplified;
