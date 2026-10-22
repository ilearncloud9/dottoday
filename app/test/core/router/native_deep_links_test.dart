import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/native_deep_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/test_app.dart';

const _v7 = '01929a3e-7c4b-7d2a-9f10-3b5c6d7e8f90';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('links queued before launch, then later ones, open their '
      'screens', (tester) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(nativeDeepLinkChannel, (call) async {
      expect(call.method, 'takePending');
      return ['dottoday://task/$_v7'];
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(nativeDeepLinkChannel, null),
    );
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(testRouterApp(router));

    await listenForNativeDeepLinks(router);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('route:task:$_v7')), findsOneWidget);

    await messenger.handlePlatformMessage(
      nativeDeepLinkChannel.name,
      nativeDeepLinkChannel.codec.encodeMethodCall(
        const MethodCall('open', 'dottoday://inbox'),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('route:inbox')), findsOneWidget);

    await messenger.handlePlatformMessage(
      nativeDeepLinkChannel.name,
      nativeDeepLinkChannel.codec.encodeMethodCall(
        const MethodCall('open', 'dottoday://task/../admin'),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('route:today')), findsOneWidget);
  });
}
