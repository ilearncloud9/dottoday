import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';

/// "Your clock is 7 min fast — reminders may be early": the one line the
/// Sync sheet and the notification health panel show (docs/09 M6.5.7).
String clockSkewText(AppLocalizations l10n, ClockSkew skew) =>
    skew.fast ? l10n.clockFast(skew.minutes) : l10n.clockSlow(skew.minutes);
