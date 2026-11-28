import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The ICU select key for [field] (`time` is reserved there).
String conflictFieldKey(ConflictField field) => switch (field) {
  ConflictField.time => 'start', // l10n-ignore: an ICU select key
  _ => field.name,
};

/// This device / Other device and their values, the other marked "in use
/// now" (E-G4-7 C2): labelled rows, read as one by a screen reader.
class ConflictRows extends StatelessWidget {
  const ConflictRows({required this.conflict, super.key});

  final SyncConflict conflict;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    Widget row(String label, String value, {bool inUse = false}) => Semantics(
      container: true,
      label: inUse
          ? '$label, $value, ${l10n.conflictInUse}' // l10n-ignore: joined
          : '$label, $value', // l10n-ignore: joined labels
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: DotSpace.m,
        children: [
          SizedBox(
            width: DotSize.conflictLabel,
            child: Text(label, style: t.styles.rowMeta),
          ),
          Expanded(
            child: Text(
              value,
              style: t.styles.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (inUse) Text(l10n.conflictInUse, style: t.styles.rowMeta),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xs,
      children: [
        row(l10n.conflictThisDevice, conflict.mine),
        row(l10n.conflictOtherDevice, conflict.theirs, inUse: true),
      ],
    );
  }
}

/// A notes conflict's two versions in full, each in its own box (Q4a):
/// This device, then Other device "in use now". With [copyable] (the two
/// together over the limit, Q4i) each label also shows its length and
/// Copy, so either can be kept by hand; nothing is trimmed.
class ConflictNotes extends StatelessWidget {
  const ConflictNotes({
    required this.conflict,
    required this.copyable,
    super.key,
  });

  final SyncConflict conflict;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        _Version(
          label: l10n.conflictThisDevice,
          text: conflict.mineNotes ?? '',
          copyable: copyable,
        ),
        _Version(
          label: l10n.conflictOtherDevice,
          text: conflict.theirsNotes ?? '',
          copyable: copyable,
          inUse: true,
        ),
      ],
    );
  }
}

class _Version extends StatelessWidget {
  const _Version({
    required this.label,
    required this.text,
    required this.copyable,
    this.inUse = false,
  });

  final String label;
  final String text;
  final bool copyable;
  final bool inUse;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xs,
      children: [
        Row(
          spacing: DotSpace.s,
          children: [
            Expanded(child: Text(label, style: t.styles.rowMeta)),
            if (copyable)
              Text(
                l10n.conflictCharacters(text.length),
                style: t.styles.rowMeta,
              ),
            if (inUse) Text(l10n.conflictInUse, style: t.styles.rowMeta),
            if (copyable)
              TextButton(
                onPressed: () => unawaited(_copy(context)),
                child: Text(l10n.conflictCopy),
              ),
          ],
        ),
        Semantics(
          label: inUse
              ? '$label, ${l10n.conflictInUse}' // l10n-ignore: joined labels
              : label,
          child: ConstrainedBox(
            // Long notes scroll inside their box (Q4i).
            constraints: const BoxConstraints(
              maxHeight: DotSize.conflictNotesMax,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.colors.ground,
                borderRadius: BorderRadius.circular(DotRadii.field),
                border: Border.all(color: t.colors.hairline),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DotSpace.s),
                child: Text(text, style: t.styles.body),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.conflictCopied;
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }
}
