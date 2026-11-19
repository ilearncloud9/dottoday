// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspected_task.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The task picked on the Workspace's Day, 3 days or Week (ED-170 C1,
/// ED-391): the 248 inspector shows it; null = nothing picked, and the
/// inspector is away. The address carries it as `?task=` (E-FullA-v2),
/// so the task link host sets and clears it. Held in core so the grid,
/// the host and the inspector meet without importing each other.

@ProviderFor(InspectedTask)
final inspectedTaskProvider = InspectedTaskProvider._();

/// The task picked on the Workspace's Day, 3 days or Week (ED-170 C1,
/// ED-391): the 248 inspector shows it; null = nothing picked, and the
/// inspector is away. The address carries it as `?task=` (E-FullA-v2),
/// so the task link host sets and clears it. Held in core so the grid,
/// the host and the inspector meet without importing each other.
final class InspectedTaskProvider
    extends $NotifierProvider<InspectedTask, String?> {
  /// The task picked on the Workspace's Day, 3 days or Week (ED-170 C1,
  /// ED-391): the 248 inspector shows it; null = nothing picked, and the
  /// inspector is away. The address carries it as `?task=` (E-FullA-v2),
  /// so the task link host sets and clears it. Held in core so the grid,
  /// the host and the inspector meet without importing each other.
  InspectedTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inspectedTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inspectedTaskHash();

  @$internal
  @override
  InspectedTask create() => InspectedTask();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$inspectedTaskHash() => r'7ff7e20e641bc52aa5d193b26ebacae66f840d01';

/// The task picked on the Workspace's Day, 3 days or Week (ED-170 C1,
/// ED-391): the 248 inspector shows it; null = nothing picked, and the
/// inspector is away. The address carries it as `?task=` (E-FullA-v2),
/// so the task link host sets and clears it. Held in core so the grid,
/// the host and the inspector meet without importing each other.

abstract class _$InspectedTask extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// ⌥⌘I, View › Show Inspector and the toolbar's last button (ED-218):
/// whether the person put the inspector away. Kept for the app's life,
/// not saved.

@ProviderFor(InspectorHidden)
final inspectorHiddenProvider = InspectorHiddenProvider._();

/// ⌥⌘I, View › Show Inspector and the toolbar's last button (ED-218):
/// whether the person put the inspector away. Kept for the app's life,
/// not saved.
final class InspectorHiddenProvider
    extends $NotifierProvider<InspectorHidden, bool> {
  /// ⌥⌘I, View › Show Inspector and the toolbar's last button (ED-218):
  /// whether the person put the inspector away. Kept for the app's life,
  /// not saved.
  InspectorHiddenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inspectorHiddenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inspectorHiddenHash();

  @$internal
  @override
  InspectorHidden create() => InspectorHidden();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$inspectorHiddenHash() => r'3106578c31e8fca2b75f7e96cb75565936b1990f';

/// ⌥⌘I, View › Show Inspector and the toolbar's last button (ED-218):
/// whether the person put the inspector away. Kept for the app's life,
/// not saved.

abstract class _$InspectorHidden extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
