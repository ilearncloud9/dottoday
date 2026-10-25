# Beta release runbook (TestFlight · Play internal · web staging)

Written in M8.5 (2026-10-24). Everything up to the upload is prepared and was
checked by the agent; every step marked **OWNER** touches a store account,
signing keys or paid hosting, so only the owner runs it (CLAUDE.md §10). The
same steps are listed as gates in `08-testing-qa.md` §6.1. What the beta
collects is in `08-testing-qa.md` §5.

All commands run in `app/` unless noted.

## 0. Before the first upload (OWNER, once)

1. **Pick the real identifiers.** The app still uses the template
   `com.yourcompany.dottoday` (Android `applicationId`/`namespace`, iOS and
   macOS `PRODUCT_BUNDLE_IDENTIFIER`, the widget extension
   `com.yourcompany.dottoday.widgets`, the App Group
   `group.com.yourcompany.dottoday`, `app_id` in `tool/device_tests.sh` and
   `tool/killed_app_check.sh`). The template id is not unique to Dottoday:
   on this Mac its sandbox container already held another app's file. Store ids are permanent after the first
   upload, so choose them first (for example `app.dottoday` /
   `app.dottoday.widgets` / `group.app.dottoday`) and ask the agent to rename
   everywhere in one commit; the device suites then re-run.
2. **Apple Developer Program** (paid) — the Personal Team can't upload to
   TestFlight or provision the App Group. Register the app id, the widget
   extension id and the App Group in Certificates, Identifiers & Profiles;
   create the app in App Store Connect (iOS, and macOS if the Mac beta goes
   through TestFlight too).
3. **Google Play Console** — create the app, accept Play App Signing, fill
   the declarations listed in 08 §6.1 (exact alarms, full-screen intent,
   data safety).
4. **`.env.prod`** — the hosted `SUPABASE_URL` and `SUPABASE_ANON_KEY` are in
   (2026-10-24); `SENTRY_DSN`, `FEEDBACK_EMAIL` and
   `WEB_PUSH_VAPID_PUBLIC_KEY` are still empty: crash-free rate (the beta's
   main number) needs `SENTRY_DSN`.
5. Hosted Supabase: the Edge Function deploys, secrets and Auth redirect URLs
   in 08 §6.1, or sign-in, account deletion and web push won't work for
   testers. The app is fully usable signed out.

## 1. Version and build numbers

- Marketing version = `pubspec.yaml` `version:` name, which must match the
  newest `Release` value in `lib/domain/release/releases.dart` (What's new).
  The first beta is **0.1.0**.
- Build number = the `+N` part, passed explicitly on every store build so it
  only ever goes up: **first beta `--build-number=1`**, then 2, 3, … for every
  upload to any store (one counter for iOS, Android and macOS keeps the
  builds comparable in crash reports). Record each in the table at the end.
- A new marketing version (0.2.0 …) = a `Release` value + its ARB notes + a
  CHANGELOG section + the pubspec bump, in one commit (08 §6.2).

## 2. Android → Play internal testing

1. **OWNER** — create the upload key once, outside the repo:
   ```sh
   keytool -genkeypair -v -keystore ~/keys/dottoday-upload.jks \
     -keyalg RSA -keysize 4096 -validity 10000 -alias upload
   ```
   and `app/android/key.properties` (git-ignored, like `*.jks`):
   ```properties
   storeFile=/Users/<you>/keys/dottoday-upload.jks
   storePassword=…
   keyAlias=upload
   keyPassword=…
   ```
   `android/app/build.gradle.kts` signs release builds with it when the file
   exists; without it they stay debug-signed (Play refuses those).
2. Build (prerequisite: Android Studio › SDK Manager › SDK Tools ›
   **Android SDK Command-line Tools**; without them Flutter writes the
   `.aab` but stops with "failed to strip debug symbols", as on this Mac in
   M8.5):
   ```sh
   flutter build appbundle --release --dart-define-from-file=.env.prod \
     --build-name=0.1.0 --build-number=1
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`. Check the
   signer: `keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab`
   must show your upload certificate, not `CN=Android Debug`.
3. **OWNER** — Play Console › Testing › Internal testing › Create release ›
   upload the `.aab`, release notes from the CHANGELOG section, add the
   tester list (email list or Google Group), Review and roll out. Copy the
   opt-in link to the testers.

## 3. iOS → TestFlight

1. **OWNER** — in Xcode, `ios/Runner.xcworkspace` › Runner and
   DottodayWidgets targets › Signing & Capabilities: the paid team,
   automatic signing; App Groups on both. Add
   `com.apple.developer.usernotifications.time-sensitive` to
   `ios/Runner/Release.entitlements` if it is not there yet (08 §6.1,
   M6.5.4).
2. Build the archive and the IPA:
   ```sh
   flutter build ipa --release --dart-define-from-file=.env.prod \
     --build-name=0.1.0 --build-number=1
   ```
   Output: `build/ios/archive/Runner.xcarchive` and
   `build/ios/ipa/*.ipa`. (Without a paid team the agent can only check
   `flutter build ios --release --no-codesign`, which M8.5 did.)
3. **OWNER** — upload: open the archive in Xcode › Organizer › Distribute App
   › App Store Connect › Upload, or
   `xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios --apiKey … --apiIssuer …`
   (an App Store Connect API key). Then App Store Connect › TestFlight: the
   export-compliance answer (the app uses only standard encryption — HTTPS
   and SQLCipher — exempt), internal testers group, "What to test" from the
   CHANGELOG section.
4. **On a tester's iPhone** (OWNER): the device checks in 08 §6.1 —
   background refresh (§4 below), time-sensitive alarm with the app killed,
   widgets and Live Activity, VoiceOver.

### macOS (optional, same counter)

`flutter build macos --release --dart-define-from-file=.env.prod
--build-name=0.1.0 --build-number=1` (team JBHAWSBYLG is already set), then
Xcode › Product › Archive on `macos/Runner.xcworkspace` › Distribute ›
TestFlight & App Store (OWNER). Add the time-sensitive entitlement to
`macos/Runner/Release.entitlements` and flip the macOS case in
`test/policy/time_sensitive_entitlement_test.dart` at the same time.

## 4. iOS background refresh on a device (OWNER, from M5.2)

The simulator registers `dottoday.refresh` and submits the request, but
`BGTaskScheduler` refuses it there (`BGTaskSchedulerErrorDomain error 1`),
so `_simulateLaunchForTaskWithIdentifier:` finds nothing scheduled (checked
in M8.5, 08 §4.1). On a TestFlight or
Xcode-installed device build:

1. Run from Xcode (Debug, the paid team) on the iPhone, put Dottoday in the
   background (home), then pause in the debugger and run
   ```
   e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"dottoday.refresh"]
   ```
   and continue.
2. Pass: the Xcode console shows
   `performBackgroundRequest.newData` from `BackgroundWorker` (and, signed
   in, the next sync shows on the other device). `.failed` = the job
   returned false; the log line before it says why.
3. Without Xcode: leave the phone on charge overnight with the app used that
   day; the next morning Today's repeats reach 90 days ahead and Settings ›
   Reminders › Notification health is fresh.

## 5. Web → staging

1. Build and add the security headers for the hosted project:
   ```sh
   ../tool/web_db_assets.sh   # the pinned sqlite3mc.wasm (encrypted web DB)
   flutter build web --release --dart-define-from-file=.env.prod
   tool/web_csp.sh "$(grep ^SUPABASE_URL= .env.prod | cut -d= -f2-)" build/web "$(grep ^SENTRY_DSN= .env.prod | cut -d= -f2-)"
   ```
   `build/web/_headers` carries the CSP, HSTS and framing headers
   (Netlify / Cloudflare Pages format; on another host, copy them into its
   header config).
2. **OWNER** — pick the host and the staging name (for example
   `staging.dottoday.app` on Cloudflare Pages or Netlify; both have free
   tiers but need an account). Deploy `build/web` as a static site, with
   every unknown path served `index.html` (the app uses hash routes, so a
   plain static host works). HTTPS is required: the service worker, web push
   and the sealed session (ADR-0003) need a secure origin.
3. **OWNER** — hosted Supabase: add the staging origin to Auth › URL
   Configuration › Redirect URLs and to `CALENDAR_RETURN_ORIGINS`.
4. Smoke test on the staging URL (agent can do this once it exists): first
   load works offline after one visit, Today/Inbox/Settings, sign-in link,
   reminders in real Chrome (08 §6.1 E), response headers match
   `_headers`.

## 6. Upload log

| Date | Build | Platform | Track | Who | Notes |
|---|---|---|---|---|---|
| — | 0.1.0 (1) | — | — | — | not uploaded yet (owner gate) |
