import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_provider.g.dart';

/// The app's [GoRouter]. Overridden in `bootstrap()` with
/// `buildRouter(appScreens)`; reading it without the override is a wiring bug.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => throw UnimplementedError(
      'routerProvider must be overridden in bootstrap().',
    );
