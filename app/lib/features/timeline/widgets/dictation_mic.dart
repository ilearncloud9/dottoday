import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/speech/dictation_controller.dart';
import 'package:dottoday/data/speech/mic_settings.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:dottoday/shared/speech/mic_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The language dictation listens for: the app's language and region.
String dictationLocale(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

/// Whether the mic may show for this context's language (D2): only where
/// an on-device recognizer exists; null while unknown.
bool? micAvailable(WidgetRef ref, BuildContext context) {
  final a = ref.watch(speechAvailabilityProvider(dictationLocale(context)));
  return a.value == null ? null : a.value != SpeechAvailability.unavailable;
}

/// A [MicButton] wired to [field] (docs/09 M14.5, ADR-0014): the
/// permission flow on first use (Dottoday's own words first on Android,
/// D5), then listening into [field] at its cursor in [mode]. The field is
/// the session's owner. Listening stops on a second tap, when the user
/// types, when [focus] moves away (not to the mic), when the app is
/// hidden, and when this widget goes.
class DictationMic extends ConsumerStatefulWidget {
  const DictationMic({
    required this.field,
    required this.focus,
    required this.mode,
    super.key,
  });

  final TextEditingController field;
  final FocusNode focus;
  final DictationMode mode;

  @override
  ConsumerState<DictationMic> createState() => _DictationMicState();
}

class _DictationMicState extends ConsumerState<DictationMic> {
  // Leaf view state (CLAUDE.md §4): the mic's own focus, the text this
  // session last wrote, and the lifecycle hook.
  final _micFocus = FocusNode();
  String? _written;
  late final DictationController _controller;
  late final AppLifecycleListener _life;

  @override
  void initState() {
    super.initState();
    // Read now: dispose may not use ref.
    _controller = ref.read(dictationControllerProvider.notifier);
    _life = AppLifecycleListener(onHide: _stop);
    widget.field.addListener(_typed);
    widget.focus.addListener(_focusMoved);
  }

  @override
  void dispose() {
    widget.field.removeListener(_typed);
    widget.focus.removeListener(_focusMoved);
    _life.dispose();
    _micFocus.dispose();
    _stop();
    super.dispose();
  }

  bool get _listening =>
      ref.read(dictationControllerProvider).listeningFor(widget.field);

  void _stop() => unawaited(_controller.stopFor(widget.field));

  /// Typing while listening: the keyboard wins.
  void _typed() {
    if (_listening && widget.field.text != _written) _stop();
  }

  void _focusMoved() {
    if (!widget.focus.hasFocus && !_micFocus.hasFocus) _stop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dictationControllerProvider, (prev, next) {
      final d = next.dictation;
      if (next.owner != widget.field || d == null) return;
      // Only new words: a stop must not undo what was typed since.
      if (identical(d, prev?.dictation) || d.text == widget.field.text) return;
      _written = d.text;
      widget.field.value = TextEditingValue(
        text: d.text,
        selection: TextSelection.collapsed(offset: d.cursor),
      );
    });
    final s = ref.watch(dictationControllerProvider);
    final mine = s.owner == widget.field;
    final state = switch (s.phase) {
      DictationPhase.listening when mine => MicState.listening,
      DictationPhase.starting ||
      DictationPhase.fetching when mine => MicState.busy,
      _ => MicState.idle,
    };
    return MicButton(
      state: state,
      focusNode: _micFocus,
      onPressed: () => unawaited(_toggle(context)),
    );
  }

  Future<void> _toggle(BuildContext context) async {
    if (_listening) return _controller.stop();
    final locale = dictationLocale(context);
    final command = context.l10n.dictationCommand;
    final rationale = ref.read(micNeedsRationaleProvider);
    final recognizer = ref.read(speechRecognizerProvider);
    _controller.preparing(widget.field);
    var a = await recognizer.availability(locale);
    // The language's model isn't on the device yet (Android 13+): this
    // tap asks Android for it; the next one listens (owner, 2026-10-30).
    if (a == SpeechAvailability.downloadable ||
        a == SpeechAvailability.downloading) {
      return _controller.prepareLanguage(widget.field, locale);
    }
    if (a == SpeechAvailability.needsPermission) {
      final go = !rationale || (context.mounted && await _rationale(context));
      a = go ? await recognizer.requestPermission(locale) : a;
    }
    if (!mounted) return;
    if (a != SpeechAvailability.available) {
      return _controller.notStarted(
        widget.field,
        failure: a == SpeechAvailability.needsPermission
            ? null
            : const PermissionFailure(AppPermission.microphone),
      );
    }
    widget.focus.requestFocus();
    final value = widget.field.value;
    _written = value.text;
    await _controller.start(
      owner: widget.field,
      text: value.text,
      cursor: value.selection.isValid ? value.selection.end : value.text.length,
      mode: widget.mode,
      localeTag: locale,
      command: widget.mode == DictationMode.brainDump ? command : null,
    );
  }

  /// Dottoday's own words before Android's dialog (D5).
  static Future<bool> _rationale(BuildContext context) async {
    final l10n = context.l10n;
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.micRationaleTitle),
        content: Text(l10n.micRationaleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.promptNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.micRationaleContinue),
          ),
        ],
      ),
    );
    return yes ?? false;
  }
}

/// Under a dictated field (M14.5): while the language's model downloads,
/// "Getting speech ready on this device…" and then that it is ready; while
/// listening, [listeningCaption] (Brain dump's "Pause, or say "next" …";
/// none for Notes); after the
/// microphone was refused, "Microphone is off for Dottoday" with Open
/// settings; after another stop, why. Quiet, never red.
class DictationNotice extends ConsumerWidget {
  const DictationNotice({
    required this.field,
    this.listeningCaption,
    super.key,
  });

  final TextEditingController field;
  final String? listeningCaption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(dictationControllerProvider);
    if (s.owner != field) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final style = t.styles.rowMeta.copyWith(color: t.colors.muted);
    final caption = listeningCaption;
    if (s.phase == DictationPhase.fetching || s.ready) {
      return _gap(
        Semantics(
          liveRegion: true,
          child: Text(
            s.ready ? l10n.micReady : l10n.micGettingReady,
            style: style,
          ),
        ),
      );
    }
    if (s.phase == DictationPhase.listening && caption != null) {
      return _gap(
        Semantics(liveRegion: true, child: Text(caption, style: style)),
      );
    }
    final line = switch (s.failure) {
      PermissionFailure() => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DotSpace.s,
        children: [
          Text(l10n.micDenied, style: style),
          TextButton(
            onPressed: () => unawaited(ref.read(micSettingsOpenerProvider)()),
            child: Text(l10n.notifOpenSettings),
          ),
        ],
      ),
      final AppFailure f => Text(failureMessage(l10n, f), style: style),
      null => null,
    };
    return line == null ? const SizedBox.shrink() : _gap(line);
  }

  /// The space above a shown line; nothing when there is none.
  static Widget _gap(Widget child) => Padding(
    padding: const EdgeInsetsDirectional.only(top: DotSpace.s),
    child: child,
  );
}
