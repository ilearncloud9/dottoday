import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wake_up_dock.g.dart';

/// Whether the Wake Up card is docked beside Today (E-R2-19-B "iPad · the
/// card docks beside Today"; every platform from the expanded width,
/// ED-456). Opened by Today's gate or by the card's route; × and Later
/// close it.
@riverpod
class WakeUpDocked extends _$WakeUpDocked {
  @override
  bool build() => false;

  void open() => state = true;

  void close() => state = false;
}

/// The docked card: a raised panel at the left of Today, 380 wide (400 on
/// Android tablets), Today sharp beside it (ED-456).
class WakeUpCardPanel extends ConsumerWidget {
  const WakeUpCardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final android =
        touchApp(context) && DotIdiom.of(context) == DotIdiom.material;
    return Container(
      width: android ? DotSize.wakeCardDockAndroid : DotSize.wakeCardDock,
      margin: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.m,
        DotSpace.m,
        0,
        DotSpace.m,
      ),
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.sheetCard),
        border: Border.all(color: t.colors.outline),
        boxShadow: DotElevation.floating,
      ),
      clipBehavior: Clip.antiAlias,
      // Beside Today's page, not inside it: its own surface for the
      // buttons' ink.
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: WakeUpCard(
            onClose: () => ref.read(wakeUpDockedProvider.notifier).close(),
          ),
        ),
      ),
    );
  }
}
