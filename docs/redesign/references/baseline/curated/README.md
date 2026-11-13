# Curated baseline screenshots (local, not committed)

12 design-reference shots chosen from the Prompt B evidence (owner-approved shortlist, 2026-11-03). JPEG, 1200 px long edge, quality 80, about 1 MB in total. `sips` on this Mac can't write WebP. Synthetic sample data only; nothing signed in.

| File | Source | Verification | Shows |
|---|---|---|---|
| 01-iphone-today-light | `prompt-b/iphone/ios_today.png` | Simulator | iPhone Today baseline |
| 02-iphone-today-dark | `prompt-b/iphone/ios_dark_today.png` | Simulator | Dark theme |
| 03-iphone-settings-long-list | `prompt-b/iphone/ios_settings.png` | Simulator | One long Settings list (P1) |
| 04-iphone-add-material-sheet | `prompt-b/iphone/ios_add_when.png` | Simulator | Add flow in a Material bottom sheet with drag handle on iOS (P2) |
| 05-ipad-portrait-stretched-phone | `prompt-b/ipad/ios_today.png` | Simulator | R3 stretched phone; R2 toast over the Settings gear |
| 06-android-phone-today | `prompt-b/android/android_today.png` | Emulator | Android phone baseline |
| 07-android-tablet-spread-clipped | `prompt-b/android_tablet/android_today.png` | Emulator | R1 clipped Wind Down, R2 toast, R4 no + in the rail |
| 08-android-settings-day-shape | `prompt-b/android/android_settings_wake_up.png` | Emulator | Day shape group: 10+ rows, permission warning inline (P1). The iOS time wheel itself isn't in this shot |
| 09-iphone-wake-up-mission | `prompt-b/iphone/ios_wake_up_mission.png` | Simulator | Small, mostly static mission graphic (P7) |
| 10-iphone-minimal-today | `prompt-b/iphone/ios_minimal_today.png` | Simulator | Minimal mode |
| 11-web-1280-spread | new web capture, 1280×800 @2x | Local headless Chromium | R1 confirmed on web: "Wind Down · 11:00 PM" clipped in both side columns; R4 no + |
| 12-web-599-no-reading-width | new web capture, 599×900 @2x | Local headless Chromium | R5: time and title drift apart; the timeline sits in a sheet-style card |

Web captures: release build served on 127.0.0.1:8097, onboarding completed with "Continue without an account", 4 synthetic tasks (Standup, Deep work, Lunch, Gym). No app code changed, no sign-in, no network to Supabase.

**Also visible in 11 and 12:** rows say "· not done" after a task's end time. That's a candidate for the no-shame copy audit (CLAUDE.md §11), noted for the concepts, not a Prompt B finding.
