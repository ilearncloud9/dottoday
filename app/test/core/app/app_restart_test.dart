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

  testWidgets('the old tree unmounts before the new one mounts '
      '(a Mac menu bar survives a restart)', (tester) async {
    await tester.pumpWidget(
      AppRestart(
        create: ProviderContainer.new,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: PlatformMenuBar(
            menus: const [],
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () => AppRestart.of(context),
                child: const Text('restart'), // l10n-ignore: test value
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('restart'));
    await tester.pumpAndSettle();
    // A one-frame swap trips the menu delegate's lock (two bars at once)
    // and, in release, the old bar's dispose clears the new one's menus.
    expect(tester.takeException(), isNull);
    expect(find.text('restart'), findsOneWidget);
  });
}
