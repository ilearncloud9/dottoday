import 'package:dottoday/app.dart';
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../pass_onboarding.dart';
import 'cr160_lab.dart';
import 'no_dialog_notifications.dart';

/// Starts the real app (bootstrap) and returns the lab on its container.
/// [fresh]: a session an earlier run left is signed out first, so the run
/// starts from the device's guest; otherwise (after a reload) the
/// persisted session is kept.
Future<Cr160Lab> startLab(WidgetTester tester, {bool fresh = true}) async {
  final flutterOnError = FlutterError.onError;
  final platformOnError = PlatformDispatcher.instance.onError;
  await bootstrap();
  FlutterError.onError = flutterOnError;
  PlatformDispatcher.instance.onError = platformOnError;
  await tester.pump(const Duration(milliseconds: 500));
  final c = ProviderScope.containerOf(tester.element(find.byType(DottodayApp)));
  final lab = Cr160Lab(c);
  if (fresh) {
    await lab.network(online: true);
    if (lab.app.auth.currentUser != null) await lab.signOut();
    await lab.actions.useWithoutAccount();
    await passOnboarding(tester);
  }
  if (!kIsWeb) {
    await ensureNotificationsWithoutDialog(
      c.read(localNotificationsPluginProvider),
      needExact: defaultTargetPlatform == TargetPlatform.android,
    );
  }
  report('platform ${kIsWeb ? 'web' : defaultTargetPlatform.name}');
  return lab;
}
