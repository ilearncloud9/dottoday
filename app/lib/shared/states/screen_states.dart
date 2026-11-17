import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/states/state_message.dart';
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

/// Skeleton dots on a dotted thread (E-G4-7-States A1; §5.4: "never a
/// spinner for > 300 ms"): grey 34 pt dots in the thread's 54 pt rows,
/// each with a short and a long bar, on the dotted line. Still, so it
/// needs nothing for reduced motion; a screen reader hears "Loading".
class LoadingThread extends StatelessWidget {
  const LoadingThread({super.key});

  /// Each row's long bar, as a share of [DotSize.skeletonTitle]'s width.
  static const _widths = [1.0, 0.8, 0.93, 0.73, 0.87, 0.8];

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
        padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
        child: CustomPaint(
          painter: _DottedThread(
            c.threadAhead,
            rtl: Directionality.of(context) == TextDirection.rtl,
          ),
          child: Column(
            children: [
              for (final w in _widths) _SkeletonRow(width: w, color: c.control),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dot, a short bar and a long one ([width] of the long bar's most).
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: DotSize.threadRowAhead,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.page),
      child: Row(
        spacing: DotSpace.m + DotSpace.xxs,
        children: [
          _Blob(
            size: const Size.square(DotSize.threadDot),
            color: color,
            round: true,
          ),
          // Bars shrink to fit a narrow slot (a side day), never overflow.
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.s - 1,
              children: [
                _Blob(size: DotSize.skeletonMeta, color: color),
                _Blob(
                  size: Size(
                    DotSize.skeletonTitle.width * width,
                    DotSize.skeletonTitle.height,
                  ),
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color, this.round = false});

  final Size size;
  final Color color;
  final bool round;

  @override
  Widget build(BuildContext context) => Container(
    // A bar takes its width or what is left; a dot keeps its square.
    width: round ? size.width : null,
    constraints: round ? null : BoxConstraints(maxWidth: size.width),
    height: size.height,
    decoration: BoxDecoration(
      color: color,
      shape: round ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: round ? null : BorderRadius.circular(size.height / 2),
    ),
  );
}

/// The 2 px dotted line through the skeleton dots' centres, from the
/// first row's centre to the last's.
final class _DottedThread extends CustomPainter {
  const _DottedThread(this.color, {required this.rtl});

  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = DotSpace.xxs;
    final x = rtl
        ? size.width - DotSpace.page - DotSize.threadDot / 2
        : DotSpace.page + DotSize.threadDot / 2;
    const half = DotSize.threadRowAhead / 2;
    for (var y = half; y < size.height - half; y += DotSpace.xs) {
      canvas.drawLine(Offset(x, y), Offset(x, y + DotSpace.xxs), paint);
    }
  }

  @override
  bool shouldRepaint(_DottedThread old) => old.color != color || old.rtl != rtl;
}

/// Didn't load (E-G4-7-States A6; §5.4: never a raw exception): what
/// failed and that nothing was lost, with Try again, in the state kit's
/// [StateMessage].
class ErrorState extends StatelessWidget {
  const ErrorState({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Align(
      alignment: Alignment.topCenter,
      child: StateMessage(
        glyph: DotGlyphs.warning,
        title: l10n.stateErrorTitle,
        body: _body(l10n),
        action: l10n.stateRetry,
        onAction: onRetry,
      ),
    );
  }

  /// The board's line, "Your tasks are safe on this device."; a failure
  /// with its own words (not reading this device) says those instead.
  String _body(AppLocalizations l10n) => switch (error) {
    StorageFailure() => l10n.stateErrorSafe,
    final AppFailure f => failureMessage(l10n, f),
    _ => l10n.stateErrorSafe,
  };
}
