import 'package:dottoday/data/shell/window_material.dart';
import 'package:dottoday/shared/navigation/mac_window_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

const _channel = MethodChannel('dottoday/window_material');

void _mock(
  WidgetTester tester,
  Future<Object?> Function(MethodCall call) handler,
) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _channel,
    handler,
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _channel,
      null,
    ),
  );
}

/// What the Mac side would send Flutter: a settings change.
Future<void> _changed(WidgetTester tester, bool vibrant) =>
    tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      _channel.name,
      _channel.codec.encodeMethodCall(MethodCall('changed', vibrant)),
      (_) {},
    );

void main() {
  testWidgets('the Mac: vibrant until Reduce Transparency or Increase '
      'Contrast turns on, then solid (ED-130)', (tester) async {
    _mock(tester, (call) async => call.method == 'vibrant' ? true : null);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final seen = <bool>[];
    container.listen(
      sidebarVibrancyProvider,
      (_, next) => next.whenData(seen.add),
      fireImmediately: true,
    );
    await tester.pump();
    expect(seen, [true]);
    await _changed(tester, false);
    await tester.pump();
    expect(seen, [true, false]);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('a Mac build without the bridge paints solid', (tester) async {
    _mock(tester, (_) async => throw MissingPluginException());
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(sidebarVibrancyProvider, (_, _) {});
    await tester.pump();
    expect(container.read(sidebarVibrancyProvider).value, isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('other targets never ask', (tester) async {
    final calls = <MethodCall>[];
    _mock(tester, (call) async {
      calls.add(call);
      return true;
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(sidebarVibrancyProvider, (_, _) {});
    await tester.pump();
    expect(container.read(sidebarVibrancyProvider).value, isFalse);
    expect(calls, isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('the Mac window takes the app theme, once per change '
      '(ED-176)', (tester) async {
    final sent = <Object?>[];
    _mock(tester, (call) async {
      if (call.method == 'appearance') sent.add(call.arguments);
      return null;
    });
    await tester.pumpWidget(
      testApp(const ProviderScope(child: MacWindowChrome(child: SizedBox()))),
    );
    await tester.pumpWidget(
      testApp(const ProviderScope(child: MacWindowChrome(child: SizedBox()))),
    );
    await tester.pumpWidget(
      testApp(
        const ProviderScope(child: MacWindowChrome(child: SizedBox())),
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();
    expect(sent, ['light', 'dark']);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  Future<double> topInset(WidgetTester tester) async {
    late double top;
    await tester.pumpWidget(
      ProviderScope(
        child: testApp(
          MacWindowChrome(
            child: Builder(
              builder: (context) {
                top = MediaQuery.paddingOf(context).top;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return top;
  }

  testWidgets('the Mac content keeps clear of the transparent title bar, '
      'and has none in full screen (ED-377)', (tester) async {
    _mock(tester, (call) async => call.method == 'titlebar' ? 28 : null);
    expect(await topInset(tester), 28);
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      _channel.name,
      _channel.codec.encodeMethodCall(const MethodCall('titlebar', 0)),
      (_) {},
    );
    await tester.pump();
    final top = MediaQuery.paddingOf(
      tester.element(find.byType(SizedBox).last),
    ).top;
    expect(top, 0);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('other targets add nothing', (tester) async {
    _mock(tester, (call) async => 28);
    expect(await topInset(tester), 0);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
