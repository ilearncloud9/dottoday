// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/onboarding_gate.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/dot_golden.dart';
import '../support/onboarding_fakes.dart';
import '../support/reveal_hint_fakes.dart';
import '../support/timeline_fakes.dart';

// docs/14 §7, M16: the five minimal screens (Today, Add, the task sheet,
// Settings, onboarding step 0) × light/dark × 1×/2× × the largest text
// × RTL, plus Today with a reveal hint. The design-review sweep lists them
// (docs/08 §7).

final _day = DateTime(2026, 10, 21);
final _now = DateTime.utc(2026, 10, 21, 7, 22);

const _minimal = Settings(
  uiLayout: UiLayout.minimal,
  use24h: false,
  firstDayOfWeek: 7,
);

/// Every hint retired, unless [hints] (a hint row in the golden).
List<Override> _overrides({bool hints = false}) => [
  ...timelineOverrides(
    now: _now,
    learningMeta: captionPutAway(_day),
    occurrences: FakeOccurrenceRepository(demoDayRows(_day)),
    subtasks: FakeSubtaskRepository(demoDaySubtasks(_day)),
    profile: testProfile(settings: _minimal).copyWith(displayName: 'Kody'),
    revealHints: FakeRevealHintRepository([
      if (!hints)
        for (final h in HintId.values)
          RevealHint(
            id: revealHintRowId(testUserId, h),
            userId: testUserId,
            hintId: h,
            dismissedAtUtc: _now,
            createdAt: _now,
            updatedAt: _now,
          ),
    ]),
  ),
  appVersionProvider.overrideWith((ref) async => '0.1.0 (1)'),
  envProvider.overrideWithValue(
    Env(
      supabaseUrl: Uri.parse('https://example.supabase.co'),
      supabaseAnonKey: 'anon',
    ),
  ),
];

/// Minimal Today in its shell: no tab bar, the floating Add alone.
Widget _today() => DotShell(
  destinations: [
    ShellDestination(glyph: DotGlyphs.today, label: 'Today', visible: false),
  ],
  selected: 0,
  onSelect: (_) {},
  onAdd: () {},
  addLabel: 'Add task',
  compactBar: false,
  addAtEveryWidth: true,
  body: const TodayScreen(),
);

Widget _add() => Builder(
  builder: (context) => Container(
    decoration: BoxDecoration(
      color: DotTheme.of(context).colors.raised,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(DotRadii.sheet),
      ),
    ),
    padding: const EdgeInsets.only(top: DotSpace.l),
    child: const AddFlowSheet(
      request: AddRequest(languageCode: 'en', text: 'Call Sam'),
    ),
  ),
);

Widget _sheet([String title = 'Deep work: roadmap']) =>
    TaskScreen(id: demoDayRows(_day).firstWhere((o) => o.title == title).id);

void main() {
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);
  const compact = {'compact'};
  for (final (name, build) in [
    ('minimal_today', _today),
    ('minimal_add', _add),
    ('minimal_settings', () => const SettingsScreen()),
  ]) {
    goldenMatrix(
      name,
      height: 844,
      widths: compact,
      a11yVariants: true,
      // Fresh fakes per cell: shared ones carry state between cells.
      build: (_) => ProviderScope(overrides: _overrides(), child: build()),
    );
  }
  // The live task's sheet, with Done filled. Its large-text and RTL cells
  // use a finished task (Not done, outlined): white bold text on the
  // accent fill at 200 % rasterises differently by test order in the
  // engine (0.14 %, over the 0.1 % tolerance), and the check stays strict.
  goldenMatrix(
    'minimal_task_sheet',
    height: 844,
    widths: compact,
    build: (_) => ProviderScope(overrides: _overrides(), child: _sheet()),
  );
  goldenMatrix(
    'minimal_task_sheet_done',
    height: 844,
    widths: compact,
    a11yVariants: true,
    build: (_) =>
        ProviderScope(overrides: _overrides(), child: _sheet('Morning run')),
  );
  goldenMatrix(
    'minimal_today_hint',
    height: 844,
    widths: compact,
    a11yVariants: true,
    build: (_) =>
        ProviderScope(overrides: _overrides(hints: true), child: _today()),
  );
  goldenMatrix(
    'minimal_onboarding_layout',
    height: 844,
    widths: compact,
    a11yVariants: true,
    build: (_) => ProviderScope(
      overrides: [
        ..._overrides(),
        onboardingProvider.overrideWith(
          () => FakeOnboarding(
            const OnboardingProgress(step: OnboardingStep.layout),
          ),
        ),
      ],
      child: const OnboardingGate(child: SizedBox.shrink()),
    ),
  );
}
