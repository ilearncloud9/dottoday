import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root: loads config, then starts the app.
///
/// Throws [EnvConfigError] before the first frame if `app/.env` is incomplete,
/// so misconfiguration never reaches the UI (docs/09 M0.3).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final env = Env.fromMap(dotenv.env);

  runApp(
    ProviderScope(
      overrides: [
        envProvider.overrideWithValue(env),
        routerProvider.overrideWithValue(buildRouter(appScreens)),
      ],
      child: const DottodayApp(),
    ),
  );
}
