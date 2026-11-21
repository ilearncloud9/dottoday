import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/shell/native_tab_bar.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/native_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  const channel = MethodChannel('dottoday/native_tab_bar');

  testWidgets('the iPad gets Settings as sidebar-only, the places as tabs, '
      'and the + (ED-265)', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    late ShellBar bar;
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) {
            bar = ShellBar(
              items: shellDestinations(context.l10n, inbox: 0),
              selected: 0,
              onSelect: (_) {},
              onAdd: () {},
              addLabel: context.l10n.quickAddTooltip,
            );
            return const SizedBox();
          },
        ),
      ),
    );
    await ChannelNativeBar(NativeBarKind.pad).configure(bar);
    final args = calls.single.arguments as Map<Object?, Object?>;
    final items = (args['items']! as List<Object?>)
        .cast<Map<Object?, Object?>>();
    expect(
      {for (final i in items) i['label']: i['foot']},
      {
        'Today': false,
        'Inbox': false,
        'Calendar': false,
        'Search': false,
        'Settings': true,
      },
    );
    expect(args['showAdd'], isTrue);
    expect(args['addLabel'], 'Add a task');
  });
}
