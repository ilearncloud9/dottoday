import 'package:dottoday/core/app/app_restart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// AppRestart (docs/09 M3f.9): a fresh container after recovery, so no
// provider keeps an error from the old database.

final _count = NotifierProvider<_Count, int>(_Count.new);

final class _Count extends Notifier<int> {
  @override
  int build() => 0;

  void up() => state++;
}

void main() {
  testWidgets('restart starts every provider again', (tester) async {
    final made = <ProviderContainer>[];
    await tester.pumpWidget(
      AppRestart(
        create: () {
          made.add(ProviderContainer());
          return made.last;
        },
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Consumer(
            builder: (context, ref, _) => GestureDetector(
              onTap: ref.read(_count.notifier).up,
              onLongPress: () => AppRestart.of(context),
              child: Text('${ref.watch(_count)}'), // l10n-ignore: test value
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('0'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.longPress(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    expect(made, hasLength(2));
  });
}
