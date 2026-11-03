# Design Lab plan (Prompt B proposal)

**Status:** proposal only, 2026-11-03. Nothing is built until you approve it (it's built in Prompt E).

## Goal

An isolated place to preview the new design system and per-platform shells with synthetic data. It must not be able to touch:
- your data or the original app's data;
- the local or hosted Supabase project;
- notifications or alarms.

It must still run the real widgets on every target.

## Proposal

1. **A separate entry point**, `app/lib/design_lab/main_design_lab.dart`, run with `flutter run -t lib/design_lab/main_design_lab.dart`. It never goes through `bootstrap()`. The production `main.dart` is unchanged.

2. **In-memory everything**, using the existing override seams:
   - **Database:** `AppDatabase(NativeDatabase.memory())`. The provider is built for this (`data/db/database_providers.dart:30`). No file is created, so even a simulator with the original app installed keeps its database untouched. On web, an in-memory database too.
   - **Supabase:** not initialised. Sync gateways are overridden with fakes. Fakes already exist in `test/support/` (`fake_sync_server.dart`, `account_fakes.dart`, `calendar_fakes.dart`, `fake_notification_platform.dart`, `fake_speech.dart`, …). The ones the lab needs move to a lab-only folder, not into `lib/` production code.
   - **Notifications, alarms, Live Activity, widgets, calendar, haptics:** overridden with no-op or recording fakes. **No `AlarmGateway.sync`, no `zonedSchedule`, no home-widget writes.**
   - **Clock:** a fixed `Clock` so screens are reproducible.
   - **Secure storage, app lock, background refresh:** not started.

3. **Synthetic fixtures only**:
   - reuse `test/support/sample_day.dart`, `sample_inbox.dart`, `sample_month.dart`, `sample_proposal.dart` and the debug "demo day";
   - add dense, empty, long-title, overlap, all-day-heavy and many-alerts days;
   - no real task text.

4. **Lab UI:** a gallery route listing every new component and every shell.

   Controls:
   - platform idiom (iOS / iPadOS / macOS / Android / web, via `debugDefaultTargetPlatformOverride`);
   - width (320 … 1440 probes);
   - text scale (1×, 1.3×, 2×);
   - light/dark, RTL, reduced motion and reduced transparency.

   Each screen state is reachable by URL on web, so reviewers can share a link.

5. **Guard rails:**
   - a policy test fails if anything under `lib/design_lab/` imports `supabase_flutter`, `flutter_local_notifications`, the alarm channel or `bootstrap.dart`;
   - the lab never ships: release builds use `main.dart`, and CI builds the lab only in debug.

## Running it safely (owner decision 14)

| Target | How |
|---|---|
| iPhone, iPad | Dedicated simulators ("Redesign iPhone", "Redesign iPad"); in-memory DB, so the shared bundle ID can't reach stored data |
| Android phone, tablet | Dedicated emulators (`Redesign_Phone`, `Redesign_Tablet`) |
| Mac | **Not run** (owner, 2026-11-03). Checked via widget tests with `TargetPlatform.macOS`, and the web build at the same widths. With an in-memory DB the Mac lab couldn't touch `~/Library/Containers/app.dottoday.planner` data, but running it still needs your OK |
| Web | Local browser on its own port (not the original app's), no sign-in. Run `tool/web_db_assets.sh` before the build (`PLATFORM_BASELINE.md` §9.3 R6) |

## What needs your approval

- The entry point and folder (`lib/design_lab/`). It's a new top-level folder under `lib/`; CLAUDE.md §3 doesn't list it. *Rec:* allow it as lab-only, with the policy test above.
- Moving reused fakes from `test/support/` into a lab-only location (`lib/design_lab/fakes/`). They then compile into debug lab builds only.
- No new dependencies are needed.

## Not covered by the lab

These need real OS integration and wait for a dev flavour (decision 6):
- native menus and windows on the Mac;
- real notifications and alarms;
- Live Activity;
- home widgets;
- performance on real hardware.
