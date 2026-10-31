import 'package:dottoday/core/router/deep_link_guard.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/14 §7, M16: every Hidden feature is reachable within two taps from
// a More row. The More rows are Settings › Everything else…, the task
// sheet's More, Add's More, and the Today menu's Show everything (owner,
// 2026-10-30). Each entry names its More row, the taps after it, and the
// route it lands on, which must be one the router serves.

enum More { everythingElse, sheetMore, addMore, showEverything }

typedef Reach = ({More from, int taps, String route});

const _everything = '/settings/everything';

/// Hidden feature → how minimal reaches it (route of the screen it is on).
const reach = <FeatureId, Reach>{
  FeatureId.macWeekMonth: (from: More.showEverything, taps: 1, route: '/week'),
  FeatureId.recurrenceEditor: (from: More.sheetMore, taps: 1, route: '/today'),
  // Not built: the thread ends at the Bedtime cap either way.
  FeatureId.windDown: (from: More.showEverything, taps: 0, route: '/today'),
  FeatureId.export: (
    from: More.everythingElse,
    taps: 1,
    route: '/settings/export',
  ),
  FeatureId.subtaskDurations: (from: More.sheetMore, taps: 0, route: '/today'),
  FeatureId.routines: (
    from: More.everythingElse,
    taps: 1,
    route: '/settings/routines',
  ),
  FeatureId.realityThread: (
    from: More.showEverything,
    taps: 0,
    route: '/today',
  ),
  FeatureId.weekReview: (from: More.showEverything, taps: 2, route: '/today'),
  FeatureId.journal: (from: More.everythingElse, taps: 2, route: '/search'),
  // Phase 2: nothing to reach yet.
  FeatureId.integrations: (
    from: More.everythingElse,
    taps: 0,
    route: _everything,
  ),
  FeatureId.proUpsell: (from: More.everythingElse, taps: 0, route: _everything),
  FeatureId.dayMenuExtras: (
    from: More.showEverything,
    taps: 1,
    route: '/today',
  ),
  FeatureId.brainDumpEntry: (
    from: More.showEverything,
    taps: 2,
    route: '/today',
  ),
  FeatureId.dictation: (from: More.sheetMore, taps: 2, route: '/today'),
  FeatureId.inboxNudge: (
    from: More.everythingElse,
    taps: 1,
    route: _everything,
  ),
  FeatureId.needMoreTimeNudge: (
    from: More.everythingElse,
    taps: 1,
    route: _everything,
  ),
  FeatureId.weekPrompt: (from: More.showEverything, taps: 0, route: '/today'),
  FeatureId.siri: (from: More.everythingElse, taps: 1, route: '/settings/siri'),
  FeatureId.realityCaption: (
    from: More.showEverything,
    taps: 0,
    route: '/today',
  ),
  FeatureId.learnedLines: (from: More.addMore, taps: 0, route: '/today'),
  FeatureId.learningPage: (
    from: More.everythingElse,
    taps: 0,
    route: _everything,
  ),
  FeatureId.travelTime: (from: More.sheetMore, taps: 1, route: '/today'),
  FeatureId.calendarWriteBack: (
    from: More.everythingElse,
    taps: 1,
    route: '/settings/calendars',
  ),
  FeatureId.search: (from: More.everythingElse, taps: 1, route: '/search'),
  FeatureId.pastDays: (from: More.everythingElse, taps: 2, route: '/search'),
  FeatureId.inboxExtras: (from: More.showEverything, taps: 1, route: '/inbox'),
  FeatureId.sheetExtras: (from: More.sheetMore, taps: 0, route: '/today'),
  FeatureId.iconLibrary: (from: More.sheetMore, taps: 1, route: '/today'),
  FeatureId.sounds: (
    from: More.everythingElse,
    taps: 1,
    route: '/settings/sounds',
  ),
  FeatureId.quietReminders: (
    from: More.everythingElse,
    taps: 0,
    route: _everything,
  ),
  FeatureId.dayShapeExtras: (
    from: More.everythingElse,
    taps: 0,
    route: _everything,
  ),
  FeatureId.planningSettings: (
    from: More.everythingElse,
    taps: 0,
    route: _everything,
  ),
  FeatureId.accent: (from: More.everythingElse, taps: 0, route: _everything),
  FeatureId.backups: (
    from: More.everythingElse,
    taps: 1,
    route: '/settings/export',
  ),
  FeatureId.trash: (from: More.everythingElse, taps: 1, route: _everything),
  FeatureId.infoPages: (
    from: More.everythingElse,
    taps: 1,
    route: '/settings/help',
  ),
  FeatureId.privacy: (
    from: More.everythingElse,
    taps: 1,
    route: '/settings/privacy',
  ),
  FeatureId.statusHint: (from: More.showEverything, taps: 1, route: '/today'),
  FeatureId.headerExtras: (from: More.showEverything, taps: 0, route: '/today'),
  FeatureId.installBanner: (
    from: More.showEverything,
    taps: 0,
    route: '/today',
  ),
};

void main() {
  final hidden = [
    for (final MapEntry(:key, :value) in LayoutPolicy.minimalTable.entries)
      if (value == FeatureVisibility.hidden) key,
  ];

  test('every Hidden feature has a way back, within two taps', () {
    expect(
      hidden.where((f) => !reach.containsKey(f)),
      isEmpty,
      reason: 'add its reach here when §3 hides a feature',
    );
    for (final f in hidden) {
      expect(reach[f]!.taps, lessThanOrEqualTo(2), reason: '$f');
    }
    expect(
      reach.keys.where((f) => !hidden.contains(f)),
      isEmpty,
      reason: 'a reach for a feature §3 no longer hides',
    );
  });

  test('every reach lands on a route the router serves', () {
    for (final MapEntry(:key, :value) in reach.entries) {
      expect(
        allowListedLocation(Uri.parse(value.route)),
        value.route,
        reason: '$key',
      );
    }
  });
}
