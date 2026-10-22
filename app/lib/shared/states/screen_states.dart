import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a screen shows before its data is there (docs/10 §5.4, docs/09
/// M3f.9b): skeleton dots while any of [inputs] loads, an inline error
/// with [onRetry] if one failed; null once all have data. A failed input
/// with a previous value keeps showing it (a refresh hiccup is not an
/// error screen).
///
/// ```dart
/// if (screenState([profile, today], onRetry: retry) case final s?) return s;
/// ```
Widget? screenState(
  List<AsyncValue<Object?>> inputs, {
  required VoidCallback onRetry,
}) {
  for (final v in inputs) {
    if (v.hasError && !v.hasValue) {
      return ErrorState(error: v.error!, onRetry: onRetry);
    }
  }
  if (inputs.any((v) => !v.hasValue)) return const LoadingThread();
  return null;
}

/// A [StateScaffold] keyed [key] while any of [inputs] isn't there yet;
/// null once all are (then read them with `requireValue`).
Widget? waitFor(
  Key key,
  List<AsyncValue<Object?>> inputs, {
  required VoidCallback onRetry,
}) => inputs.every((a) => a.hasValue)
    ? null
    : StateScaffold(key: key, inputs: inputs, onRetry: onRetry);

/// A whole screen that is loading or failed: [screenState] in a Scaffold
/// (keyed like the screen, for its route tests).
class StateScaffold extends StatelessWidget {
  const StateScaffold({required this.inputs, required this.onRetry, super.key});

  final List<AsyncValue<Object?>> inputs;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: screenState(inputs, onRetry: onRetry) ?? const LoadingThread(),
    ),
  );
}

/// Skeleton dots on a dotted thread (§5.4: "never a spinner for > 300
/// ms"). Still, so it needs nothing for reduced motion.
class LoadingThread extends StatelessWidget {
  const LoadingThread({super.key});

  static const _rows = 4;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Semantics(
      label: context.l10n.stateLoading,
      container: true,
      excludeSemantics: true,
      // Clipped, never overflowing, in a short slot (a side day).
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(DotSpace.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _rows; i++) ...[
              _SkeletonRow(wide: i.isEven, color: c.hairline),
              if (i < _rows - 1)
                // The glyph's line is its centre: under the dots' centres.
                DotIcon(
                  DotGlyphs.dottedLine,
                  color: c.hairline,
                  size: DotSize.rowDot,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A dot and a title bar.
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.wide, required this.color});

  final bool wide;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    spacing: DotSpace.m,
    children: [
      _Blob(size: DotSize.rowDot, color: color, round: true),
      Expanded(
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: wide ? 0.7 : 0.45,
          child: _Blob(size: DotSpace.m, color: color),
        ),
      ),
    ],
  );
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color, this.round = false});

  final double size;
  final Color color;
  final bool round;

  @override
  Widget build(BuildContext context) => Container(
    height: size,
    width: round ? size : null,
    decoration: BoxDecoration(
      color: color,
      shape: round ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: round ? null : BorderRadius.circular(size / 2),
    ),
  );
}

/// Inline, actionable error (§5.4: never a raw exception): what failed,
/// that nothing was lost, Try again.
class ErrorState extends StatelessWidget {
  const ErrorState({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(DotSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.s,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.stateErrorTitle, style: t.styles.cardTitle),
          ),
          Text(_reason(l10n), style: t.styles.body),
          Text(
            l10n.stateErrorSafe,
            style: t.styles.body.copyWith(color: t.colors.muted),
          ),
          FilledButton(onPressed: onRetry, child: Text(l10n.stateRetry)),
        ],
      ),
    );
  }

  String _reason(AppLocalizations l10n) => switch (error) {
    // A load, not a save: the generic storage text would say "save".
    StorageFailure() => l10n.stateReadFailed,
    final AppFailure f => failureMessage(l10n, f),
    _ => l10n.failureUnexpected,
  };
}
