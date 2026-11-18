import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The web's single keys that are characters, not key names (ED-095).
abstract final class WebKeys {
  /// Previous day, week or month.
  static const previous = CharacterActivator('[');

  /// Next day, week or month.
  static const next = CharacterActivator(']');
}

/// Whether the web's single-key shortcuts are on (Settings › General ›
/// Single-key shortcuts, ED-095; WCAG 2.1.4 lets them be turned off). Set
/// once above all routes; true when nothing sets it.
class SingleKeysOn extends InheritedWidget {
  const SingleKeysOn({required this.on, required super.child, super.key});

  final bool on;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SingleKeysOn>()?.on ?? true;

  @override
  bool updateShouldNotify(SingleKeysOn oldWidget) => on != oldWidget.on;
}

/// A screen's web single keys (ED-095): `[` `]` for the previous and next
/// day, `t` for today, `f` for Focus and so on, standing in for the ⌘ keys
/// the browser keeps. They act only on the web, outside text fields and
/// while [SingleKeysOn] is on; otherwise the key goes on untouched.
///
/// ```dart
/// SingleKeys(
///   bindings: {const CharacterActivator('['): () => step(-1)},
///   child: day,
/// )
/// ```
class SingleKeys extends StatelessWidget {
  const SingleKeys({
    required this.bindings,
    required this.child,
    this.web = kIsWeb,
    super.key,
  });

  final Map<ShortcutActivator, VoidCallback> bindings;
  final Widget child;

  /// Whether this is the web build (tests set it).
  final bool web;

  @override
  Widget build(BuildContext context) {
    if (!web || bindings.isEmpty) return child;
    final on = SingleKeysOn.of(context);
    return Shortcuts(
      shortcuts: {
        for (final MapEntry(:key, :value) in bindings.entries)
          key: _SingleKeyIntent(value),
      },
      child: Actions(
        actions: {_SingleKeyIntent: _SingleKeyAction(on: on)},
        child: child,
      ),
    );
  }
}

final class _SingleKeyIntent extends Intent {
  const _SingleKeyIntent(this.run);

  final VoidCallback run;
}

final class _SingleKeyAction extends Action<_SingleKeyIntent> {
  _SingleKeyAction({required this.on});

  final bool on;

  @override
  bool isEnabled(_SingleKeyIntent intent) => on && focusedTextField() == null;

  @override
  Object? invoke(_SingleKeyIntent intent) {
    intent.run();
    return null;
  }
}

/// Previous / next period and back to the current one (Week, Month;
/// ED-095): ⌘← / ⌘→ / ⌘T in the apps (Ctrl elsewhere), `[` `]` `t` on the
/// web, where the browser keeps ⌘/Ctrl T.
class PeriodKeys extends StatelessWidget {
  const PeriodKeys({
    required this.onPrevious,
    required this.onNext,
    required this.onCurrent,
    required this.child,
    this.web = kIsWeb,
    super.key,
  });

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCurrent;
  final Widget child;
  final bool web;

  @override
  Widget build(BuildContext context) {
    // The Mac Go menu sends its day moves as intents (M5.5): here they
    // step the period.
    final moves = Actions(
      actions: {
        ShowTodayIntent: CallbackAction<ShowTodayIntent>(
          onInvoke: (_) => onCurrent(),
        ),
        ShowDayIntent: CallbackAction<ShowDayIntent>(
          onInvoke: (i) => i.days < 0 ? onPrevious() : onNext(),
        ),
      },
      child: child,
    );
    if (web) {
      return SingleKeys(
        web: true,
        bindings: {
          WebKeys.previous: onPrevious,
          WebKeys.next: onNext,
          const SingleActivator(LogicalKeyboardKey.keyT): onCurrent,
        },
        child: moves,
      );
    }
    final p = defaultTargetPlatform;
    return CallbackShortcuts(
      bindings: {
        AppShortcuts.activator(p, LogicalKeyboardKey.arrowLeft): onPrevious,
        AppShortcuts.activator(p, LogicalKeyboardKey.arrowRight): onNext,
        AppShortcuts.activator(p, LogicalKeyboardKey.keyT): onCurrent,
      },
      child: moves,
    );
  }
}
