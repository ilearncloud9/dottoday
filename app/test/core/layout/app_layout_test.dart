import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<T> _read<T>(
  WidgetTester tester,
  Size size,
  T Function(BuildContext) read, {
  EdgeInsets padding = EdgeInsets.zero,
  double scale = 1,
}) async {
  late T out;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: padding,
        textScaler: TextScaler.linear(scale),
      ),
      child: Builder(
        builder: (context) {
          out = read(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return out;
}

void main() {
  WidthClass klass(BuildContext c) => AppLayout.classOf(c);

  testWidgets('600 / 840 by width (ED-167)', (tester) async {
    expect(
      await _read(tester, const Size(599, 900), klass),
      WidthClass.compact,
    );
    expect(await _read(tester, const Size(600, 900), klass), WidthClass.medium);
    expect(await _read(tester, const Size(839, 900), klass), WidthClass.medium);
    expect(
      await _read(tester, const Size(840, 900), klass),
      WidthClass.expanded,
    );
  });

  testWidgets('H1: under 480 usable height keeps the phone layout (ED-168)', (
    tester,
  ) async {
    // iPhone 16 Pro in landscape.
    expect(
      await _read(tester, const Size(874, 402), klass),
      WidthClass.compact,
    );
    // Tall enough, but the safe areas leave less than 480.
    expect(
      await _read(
        tester,
        const Size(900, 500),
        klass,
        padding: const EdgeInsets.only(top: 30),
      ),
      WidthClass.compact,
    );
    // The Mac's minimum window never reaches it (ED-169).
    expect(
      await _read(tester, const Size(840, 640), klass),
      WidthClass.expanded,
    );
  });

  testWidgets('the keyboard never changes the class (ED-168)', (tester) async {
    late WidthClass out;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1024, 700),
          viewInsets: EdgeInsets.only(bottom: 320),
        ),
        child: Builder(
          builder: (context) {
            out = AppLayout.classOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(out, WidthClass.expanded);
  });

  testWidgets('a side panel floats below 1160 and docks from it (ED-167)', (
    tester,
  ) async {
    bool docks(BuildContext c) =>
        AppLayout.docks(c, available: MediaQuery.sizeOf(c).width);
    expect(await _read(tester, const Size(1159, 800), docks), isFalse);
    expect(await _read(tester, const Size(1160, 800), docks), isTrue);
  });

  testWidgets('above 130 % text Today needs 600 beside it (ED-168 M)', (
    tester,
  ) async {
    bool docks(BuildContext c) => AppLayout.docks(c, available: 1000);
    expect(await _read(tester, const Size(1200, 800), docks), isTrue);
    expect(
      await _read(tester, const Size(1200, 800), docks, scale: 1.4),
      isFalse,
    );
  });

  testWidgets('a short window never docks (H1)', (tester) async {
    bool docks(BuildContext c) => AppLayout.docks(c, available: 1280);
    expect(await _read(tester, const Size(1280, 460), docks), isFalse);
  });
}
