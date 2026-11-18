// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The view a person last chose, which the sidebar's Plan opens (owner,
/// M19.2): Week until one is chosen. Kept for the app's life, not saved.

@ProviderFor(LastWorkspaceView)
final lastWorkspaceViewProvider = LastWorkspaceViewProvider._();

/// The view a person last chose, which the sidebar's Plan opens (owner,
/// M19.2): Week until one is chosen. Kept for the app's life, not saved.
final class LastWorkspaceViewProvider
    extends $NotifierProvider<LastWorkspaceView, WorkspaceView> {
  /// The view a person last chose, which the sidebar's Plan opens (owner,
  /// M19.2): Week until one is chosen. Kept for the app's life, not saved.
  LastWorkspaceViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastWorkspaceViewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastWorkspaceViewHash();

  @$internal
  @override
  LastWorkspaceView create() => LastWorkspaceView();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspaceView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspaceView>(value),
    );
  }
}

String _$lastWorkspaceViewHash() => r'884afa06c80e7bbce8230571a4440928d187172e';

/// The view a person last chose, which the sidebar's Plan opens (owner,
/// M19.2): Week until one is chosen. Kept for the app's life, not saved.

abstract class _$LastWorkspaceView extends $Notifier<WorkspaceView> {
  WorkspaceView build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WorkspaceView, WorkspaceView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkspaceView, WorkspaceView>,
              WorkspaceView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
