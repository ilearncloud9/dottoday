import 'package:dottoday/core/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'generated/app_localizations.dart';

/// Shorthand for the current [AppLocalizations]; every user-facing string
/// goes through this (CLAUDE.md §2, docs/03 §5).
///
/// ```dart
/// Text(context.l10n.appTitle);
/// ```
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
