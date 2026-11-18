import 'package:dottoday/core/router/workspace_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dottoday/core/router/workspace_routes.dart';

part 'workspace_view.g.dart';

/// The view a person last chose, which the sidebar's Plan opens (owner,
/// M19.2): Week until one is chosen. Kept for the app's life, not saved.
@Riverpod(keepAlive: true)
class LastWorkspaceView extends _$LastWorkspaceView {
  @override
  WorkspaceView build() => WorkspaceView.week;

  void choose(WorkspaceView view) => state = view;
}
