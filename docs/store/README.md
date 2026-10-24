# Store assets (M8.6)

Everything the App Store, Play Console and the web need, as repo files.
Nothing here has been uploaded: logging in to App Store Connect / Play
Console, filling the forms and publishing the policy are owner gates
(`docs/08-testing-qa.md` §6.1).

| What | Where | Made by |
|---|---|---|
| App icons, launch screens (iOS, Android, macOS, web) | `app/ios/Runner/Assets.xcassets`, `app/android/app/src/main/res`, `app/macos/Runner/Assets.xcassets`, `app/web/icons`, `app/web/favicon.png` | `cd app && dart run tool/gen_app_icons.dart` (checked by `test/tool/app_icons_test.dart`) |
| Store icon to upload (Play 512 × 512, App Store 1024 × 1024) | `app/web/icons/Icon-maskable-512.png` (Play: full-bleed, Play masks it), `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` | the generator |
| Screenshots | `screenshots/<locale>/` | `cd app && STORE_SCREENSHOTS=1 flutter test --tags store-screenshots` (`test/store/store_screenshots_test.dart`) |
| Listing copy (en, de, fr, es) | `listing/*.md` | by hand; limits and no-shame words checked by `test/policy/store_listing_test.dart`, `test/policy/no_shame_copy_test.dart` |
| App Privacy / Data safety answers | `privacy-labels.md` | from the code; review before filling the consoles |
| Age rating questionnaires, age gate | `age-rating.md` | by hand |
| Privacy policy page | `app/web/privacy.html` (+ `privacy.css`), served with the web build at `/privacy.html` | by hand, from `privacy-labels.md` §1 |

## Icon

The day dot on its thread (docs/10 §1): the conic ring filling from
12 o'clock with the small centre dot (`DayDot`), threaded on the dotted
free-time line. White on the indigo accent `#3B6CF6`; launch screens show it
in the accent on the surface colour (`#FAFAF8` / `#121214`, accent
`#7FA0FF` in dark). Below 40 px of mark the thread is dropped. Derived for
M8.6 (no reference render) — the owner may replace the design by editing
`_mark` in the generator; every platform follows.

## Screenshots

Rendered by the widget-test harness (the golden sweep's screens, the demo
day at 09:22 with Deep work live, real Inter font) inside the app shell, at
the consoles' pixel sizes:

| Set | Pixels | Console slot | Theme |
|---|---|---|---|
| `iphone_6_9_*` | 1320 × 2868 | App Store iPhone 6.9" (scales to smaller iPhones) | light |
| `ipad_13_*` | 2064 × 2752 | App Store iPad 13" (required: the app runs on iPad) | light |
| `android_phone_*` | 1080 × 1920 (9:16) | Play phone screenshots | dark |
| `mac_*` | 2880 × 1800 | Mac App Store (16:10) | light |

Five per set: Today, Add (step 2 over Today), the task sheet (phones) or
Week board (iPad, Mac), Month, Inbox. Only `en` is committed; the other
languages are generated on demand (`STORE_LOCALES=de,fr,es`). In those the
app's own text is translated but the demo tasks stay English (they are test
fixtures) — localise the demo titles before using localised sets, or use the
English set for every storefront. No device frame or status bar: both
consoles accept plain app screenshots. A Play feature graphic (1024 × 500)
is not made; the owner may add one with the icon on the accent.
