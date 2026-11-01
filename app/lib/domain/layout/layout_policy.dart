import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/layout/feature_id.dart';

/// What a feature looks like in minimal mode (docs/14 §3).
enum FeatureVisibility {
  /// Unchanged.
  shown,

  /// The same feature with fewer controls; defaults instead of choices.
  simplified,

  /// Fully working, reached through a *More* row or revealed by a hint.
  /// View-only: nothing below the View changes (docs/14 §6).
  hidden,

  /// Off until full mode, through the feature's existing switch: the View
  /// passes "off" into it and never writes it (docs/14 §6).
  off;

  /// Whether the View draws the feature's entry point where full mode does.
  bool get onScreen => this == shown || this == simplified;
}

/// The one place a View asks "do I draw this?" (docs/14 §6, ADR-0016).
///
/// In full layout every feature is [FeatureVisibility.shown]; in minimal
/// layout each follows its §3 row in [minimalTable].
///
/// ```dart
/// final v = ref.watch(layoutPolicyProvider.select(
///   (p) => p.visibility(FeatureId.search),
/// ));
/// if (!v.onScreen) return const SizedBox.shrink();
/// ```
final class LayoutPolicy {
  const LayoutPolicy(this.layout);

  /// The layout this policy answers for.
  final UiLayout layout;

  /// Whether this is the minimal layout (for the layout switch only).
  bool get isMinimal => layout == UiLayout.minimal;

  /// How [feature] shows in [layout].
  FeatureVisibility visibility(FeatureId feature) => switch (layout) {
    UiLayout.full => FeatureVisibility.shown,
    UiLayout.minimal => minimalTable[feature]!,
  };

  @override
  bool operator ==(Object other) =>
      other is LayoutPolicy && other.layout == layout;

  @override
  int get hashCode => layout.hashCode;

  /// docs/14 §3's "In minimal mode" column, row for row.
  static const minimalTable = <FeatureId, FeatureVisibility>{
    FeatureId.todayThread: FeatureVisibility.shown,
    FeatureId.weekStrip: FeatureVisibility.simplified,
    FeatureId.macWeekMonth: FeatureVisibility.hidden,
    FeatureId.addTask: FeatureVisibility.simplified,
    FeatureId.taskSheet: FeatureVisibility.simplified,
    FeatureId.recurrenceEditor: FeatureVisibility.hidden,
    FeatureId.inbox: FeatureVisibility.simplified,
    FeatureId.dragMove: FeatureVisibility.shown,
    FeatureId.shiftRunningLate: FeatureVisibility.simplified,
    FeatureId.wakeBedtime: FeatureVisibility.shown,
    FeatureId.capTimeEdit: FeatureVisibility.hidden,
    FeatureId.windDown: FeatureVisibility.hidden,
    FeatureId.notifications: FeatureVisibility.simplified,
    FeatureId.bedtimeReview: FeatureVisibility.simplified,
    FeatureId.syncAccount: FeatureVisibility.shown,
    FeatureId.calendarImport: FeatureVisibility.simplified,
    FeatureId.export: FeatureVisibility.hidden,
    FeatureId.lightDarkLanguage: FeatureVisibility.shown,
    FeatureId.onboarding: FeatureVisibility.simplified,
    FeatureId.alarmsHealth: FeatureVisibility.shown,
    FeatureId.wakeUpAlarm: FeatureVisibility.simplified,
    FeatureId.wakeUpCard: FeatureVisibility.simplified,
    FeatureId.wakeUpCheck: FeatureVisibility.shown,
    FeatureId.actualTimestamps: FeatureVisibility.shown,
    FeatureId.subtaskDurations: FeatureVisibility.hidden,
    FeatureId.liveActivity: FeatureVisibility.shown,
    FeatureId.homeWidgets: FeatureVisibility.simplified,
    FeatureId.wallpaper: FeatureVisibility.simplified,
    FeatureId.focus: FeatureVisibility.shown,
    FeatureId.breakDown: FeatureVisibility.simplified,
    FeatureId.smallestStep: FeatureVisibility.shown,
    FeatureId.unstick: FeatureVisibility.shown,
    FeatureId.brainDump: FeatureVisibility.simplified,
    FeatureId.paperPlan: FeatureVisibility.simplified,
    FeatureId.captureAnywhere: FeatureVisibility.shown,
    FeatureId.rebalance: FeatureVisibility.simplified,
    FeatureId.routines: FeatureVisibility.hidden,
    FeatureId.realityThread: FeatureVisibility.hidden,
    FeatureId.energySuggestions: FeatureVisibility.off,
    FeatureId.weekReview: FeatureVisibility.hidden,
    FeatureId.lowEnergy: FeatureVisibility.shown,
    FeatureId.journal: FeatureVisibility.hidden,
    FeatureId.bodyDouble: FeatureVisibility.simplified,
    FeatureId.integrations: FeatureVisibility.hidden,
    FeatureId.watch: FeatureVisibility.shown,
    FeatureId.proUpsell: FeatureVisibility.hidden,
    FeatureId.headerExtras: FeatureVisibility.hidden,
    FeatureId.doneCircle: FeatureVisibility.shown,
    FeatureId.dotTapSheet: FeatureVisibility.shown,
    FeatureId.overlaps: FeatureVisibility.shown,
    FeatureId.liveRowDetails: FeatureVisibility.simplified,
    FeatureId.multiSelect: FeatureVisibility.shown,
    FeatureId.structuredDrag: FeatureVisibility.shown,
    FeatureId.allDayDrop: FeatureVisibility.shown,
    FeatureId.addButtonDrag: FeatureVisibility.shown,
    FeatureId.inboxTabDrop: FeatureVisibility.simplified,
    FeatureId.trashTarget: FeatureVisibility.shown,
    FeatureId.pinned: FeatureVisibility.simplified,
    FeatureId.allDayChips: FeatureVisibility.shown,
    FeatureId.emptyDayActions: FeatureVisibility.simplified,
    FeatureId.dayMenuExtras: FeatureVisibility.hidden,
    FeatureId.brainDumpEntry: FeatureVisibility.hidden,
    FeatureId.dictation: FeatureVisibility.hidden,
    FeatureId.inboxNudge: FeatureVisibility.hidden,
    FeatureId.needMoreTimeNudge: FeatureVisibility.hidden,
    FeatureId.rebalancePrompt: FeatureVisibility.simplified,
    FeatureId.weekPrompt: FeatureVisibility.hidden,
    FeatureId.siri: FeatureVisibility.hidden,
    FeatureId.realityCaption: FeatureVisibility.hidden,
    FeatureId.learnedLines: FeatureVisibility.hidden,
    FeatureId.learningPage: FeatureVisibility.hidden,
    FeatureId.travelTime: FeatureVisibility.hidden,
    FeatureId.calendarWriteBack: FeatureVisibility.hidden,
    FeatureId.timeZones: FeatureVisibility.simplified,
    FeatureId.search: FeatureVisibility.hidden,
    FeatureId.pastDays: FeatureVisibility.hidden,
    FeatureId.navigation: FeatureVisibility.simplified,
    FeatureId.spread: FeatureVisibility.simplified,
    FeatureId.inboxExtras: FeatureVisibility.hidden,
    FeatureId.sheetExtras: FeatureVisibility.hidden,
    FeatureId.iconLibrary: FeatureVisibility.hidden,
    FeatureId.sounds: FeatureVisibility.hidden,
    FeatureId.haptics: FeatureVisibility.hidden,
    FeatureId.quietReminders: FeatureVisibility.hidden,
    FeatureId.dayShapeExtras: FeatureVisibility.hidden,
    FeatureId.planningSettings: FeatureVisibility.hidden,
    FeatureId.accent: FeatureVisibility.hidden,
    FeatureId.backups: FeatureVisibility.hidden,
    FeatureId.trash: FeatureVisibility.hidden,
    FeatureId.infoPages: FeatureVisibility.hidden,
    FeatureId.privacy: FeatureVisibility.hidden,
    FeatureId.statusHint: FeatureVisibility.hidden,
    FeatureId.appLock: FeatureVisibility.shown,
    FeatureId.syncConflicts: FeatureVisibility.shown,
    FeatureId.recovery: FeatureVisibility.shown,
    FeatureId.installBanner: FeatureVisibility.hidden,
    FeatureId.onboardingExtras: FeatureVisibility.simplified,
  };
}
