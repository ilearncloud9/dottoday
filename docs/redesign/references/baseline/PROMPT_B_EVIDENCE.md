# Prompt B evidence manifest

**Captured:** 2026-11-03 on `redesign/design-lab` at `f449aa76`.

**What's in Git:** this manifest and the Prompt B documents only.

**What's local only:** the screenshots and logs under `prompt-b/` (273 PNGs + 5 logs, about 64 MB). By owner decision they're kept on the owner's Mac for later visual comparison and are **not committed**. Every finding below is described in words, so the documents can be read without them.

## 1. How each target was verified

| Target | Verification level in Prompt B | Device / configuration |
|---|---|---|
| iPhone | **Simulator only** | "Redesign iPhone": iPhone 17, iOS 26.5, portrait, 1206×2622 px (402×874 pt). Light and dark runs |
| iPad portrait | **Simulator only** | "Redesign iPad": iPad Pro 11-inch (M5), iOS 26.5, portrait, 1668×2420 px (834 pt wide = medium width class). Light only |
| iPad landscape | **NOT VERIFIED** | The simulator couldn't be rotated (device access timed out) |
| Android phone | **Emulator only** | `Redesign_Phone`: Pixel 9 profile, API 37, 1080×2424 px @ 420 dpi, portrait. Light only |
| Android tablet | **Emulator only** | `Redesign_Tablet`: Pixel Tablet profile, API 37, 2560×1600 px @ 320 dpi (1280 dp wide), landscape. Light only |
| Foldable | **NOT VERIFIED** | No fold/hinge run |
| macOS | **NOT VERIFIED** | No Mac build (owner decision 14). Mac rows in the audits come from reading the code only |
| Web desktop | **Local browser, viewport emulation** | Release build served on `127.0.0.1:8097` in the Claude in-app browser (Chromium). Onboarding done with "Continue without an account"; one synthetic task added. Not saved as files: observed only |
| Web mobile | **NOT VERIFIED on a phone** | Phone widths (320, 390) were emulated in the desktop browser only |
| Real devices | **None used for the redesign build** | The only real-device evidence is the owner's iPhone screenshots of the current App Store app (§4) |

**Isolation:** every build used a scratch defines file with `SUPABASE_URL=http://localhost:9` and a dummy anon key. Nothing signed in, nothing synced, and the web probe made no request to that address. The dedicated simulators and emulators (left shut down) never ran the original app's data.

## 2. Local screenshot sets (`prompt-b/`, not in Git)

Captured with `app/tool/device_tests.sh <ios|android> <device> sweep` (`SWEEP_THEME=dark` for the dark run). The app loads the synthetic "M11 sample" day; no real task text appears.

| Folder | Files | Naming |
|---|---|---|
| `iphone/` | 110 | `ios_<shot>.png` (light) and `ios_dark_<shot>.png` |
| `ipad/` | 55 | `ios_<shot>.png` |
| `android/` | 54 | `android_<shot>.png` |
| `android_tablet/` | 54 | `android_<shot>.png` |
| `logs/` | 5 | `iphone_light`, `iphone_dark`, `ipad_portrait`, `android_phone`, `android_tablet` (`.log`) |

**Shot names (55 on iOS):** add_duration, add_paste, add_time_menu, add_what, add_when, brain_dump, brain_dump_mic, brain_dump_proposal, feedback, health_wake_up, inbox, inbox_selecting, learned_explained, low_energy, minimal_add, minimal_everything, minimal_later, minimal_settings, minimal_task_sheet, minimal_today, onboarding_account, onboarding_day_shape, onboarding_done, onboarding_habits, onboarding_layout, onboarding_reminders, onboarding_welcome, past_days, privacy_ai_status, proposal_origin, reality, routine_drop, routine_editor, routines, running_late, search, settings, settings_account, settings_export, settings_learning, settings_privacy, settings_reminders, settings_sounds, settings_wake_up, settings_whats_new, siri_page, sync, today, wake_up_card, wake_up_explain, wake_up_mission, wake_up_one_thing, wake_up_options, wake_up_rotation, week_review.

**Android (54):** the same, without `siri_page`, and with `brain_dump_no_mic` instead of `brain_dump_mic`. This is platform branching in the sweep, not a missing shot.

## 3. Results

- **All five sweep runs passed.**
- **a11y-tree checks:** tap target ≥ 44 pt, Android 48 dp, every target labelled. 39 screens per iOS run and 38 per Android run, with no failures.
- **Overflow:** no `RenderFlex overflowed` and no exceptions in any log.
- **Sweep caveat:** on iOS and Android the logs carry a test warning. The clean-up tap on "Vary the sound" in `integration_test/support/sweep_m17.dart:76` lands off-screen. It runs *after* the `wake_up_rotation` shot, so no screenshot is affected, but the switch may stay on for later legs. This is a harness issue, not an app finding.

## 4. Owner real-device screenshots (current app, not the redesign build)

`owner-ios-2026-11-02/` was taken by the owner on their iPhone, dark theme, App Store build.
- **In Git:** `01-settings-top`, `02-settings-scrolled`, `05-wake-mission-catch-the-dot`.
- **Local only:** `03-today-more-menu` and `04-today`. They show personal tasks and are excluded by owner decision. `UX_AUDIT.md` P3 cites `03` in words: the ⋯ menu covers the Today header.

## 5. Findings and where the evidence is

| # | Finding (in words) | Seen on | Evidence (local only unless noted) |
|---|---|---|---|
| R1 | In the three-day spread, the side-day columns clip "Wind Down · 11:00 PM": the "PM" line is cut off | Android tablet emulator, 1280 dp | `android_tablet/android_today.png`. Web at 1280 wraps the same label in cramped columns (observed, not saved) |
| R2 | Toasts sit across the bottom of the window and cover the rail's Settings gear. The sweep's "M11 sample loaded" toast covers it on iPad and Android tablet; on web the "added… Undo" toast covered it at 600–1280 and stayed up for over 40 s | iPad simulator, Android tablet emulator, web | `ipad/ios_today.png`, `android_tablet/android_today.png`; web observed, not saved |
| R3 | iPad portrait (834 pt, medium) is a stretched phone. A Siri card, a "New: Wake Up…" banner and "See how it works" push the thread to mid-screen, and the thread sits in a sheet-style card with a drag handle | iPad simulator | `ipad/ios_today.png` |
| R4 | No add (+) button at expanded width (≥ 840) in the full layout (minimal mode keeps it): the rail shows Today, Inbox, Week, Search only | Android tablet emulator; web 840–1440. iPad landscape **inferred, not verified** | `android_tablet/android_today.png`; web observed, not saved; code `app/lib/shared/navigation/dot_shell.dart:113-115` and `app/lib/app_shell.dart:71` (in Git) |
| R5 | No reading-width cap on compact rows: at 599 the time and the title drift far apart | Web 599 | Observed, not saved |
| R6 | The web build needs `tool/web_db_assets.sh` before `flutter build web`. Without `sqlite3mc.wasm` the encrypted database can't open (404 on `/sqlite3mc.wasm`) and Today shows "This didn't load". It's a documented release step (`docs/release-beta.md` §5), not an app defect; the Design Lab plan now includes it | Web | Browser network log (observed); `tool/web_db_assets.sh` (in Git) |

## 6. Sensitive-content check (2026-11-03)

- **Screenshots:** reviewed the account, settings, sync, feedback, privacy and past-days screens. None is signed in ("Name: Not set", "On this device"), there's no email, no device identifier and no real task text; only the synthetic sample day.
- **Logs:** no keys, tokens or email addresses. They contain local file paths (the Mac user's home folder), one more reason they stay local.

## 7. Reproducing

1. Recreate the defines file with a dead Supabase URL and a dummy key.
2. From `app/`, run `DEFINES=<file> tool/device_tests.sh ios <simulator-udid> sweep` (or `android emulator-5554`) on the dedicated devices.
3. For web, run `tool/web_db_assets.sh`, then `flutter build web --dart-define-from-file=<file>`, and serve `app/build/web` with the `web-build-8097` launch config.
