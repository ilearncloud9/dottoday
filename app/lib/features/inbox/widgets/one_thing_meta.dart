import 'package:dottoday/core/l10n/l10n.dart';

/// An Inbox row's [meta] with "· Your one thing" when it is today's one
/// thing (docs/15 §8), so the ring never relies on colour.
String inboxMetaWithOneThing(
  AppLocalizations l10n,
  String meta, {
  required bool oneThing,
}) => oneThing ? l10n.oneThingMetaJoin(meta) : meta;
