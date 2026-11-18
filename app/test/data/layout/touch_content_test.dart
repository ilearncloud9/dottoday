import 'package:dottoday/data/layout/touch_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<bool> _touch(WidgetTester tester, TargetPlatform platform) async {
  late bool out;
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        themeAnimationDuration: Duration.zero,
        home: Consumer(
          builder: (context, ref, _) {
            out = watchTouchContent(context, ref);
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return out;
}

void main() {
  testWidgets('touch tablets use the touch content scale; the Mac keeps the '
      'pointer sizes (ED-256, ED-261)', (tester) async {
    expect(await _touch(tester, TargetPlatform.iOS), isTrue);
    expect(await _touch(tester, TargetPlatform.android), isTrue);
    expect(await _touch(tester, TargetPlatform.macOS), isFalse);
    expect(await _touch(tester, TargetPlatform.windows), isFalse);
  });
}
