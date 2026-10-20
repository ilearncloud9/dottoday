import 'package:dottoday/core/env/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'env_provider.g.dart';

/// The loaded [Env]. Overridden in `bootstrap()`; reading it without the
/// override is a wiring bug.
@Riverpod(keepAlive: true)
Env env(Ref ref) =>
    throw UnimplementedError('envProvider must be overridden in bootstrap().');
