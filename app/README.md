# app/ — Flutter project seed

This folder holds the seeds; the agent runs `flutter create` here in Milestone 0 and keeps these files:

```
cd app
flutter create --org com.yourcompany --project-name dottoday --platforms ios,android,macos,web .
# then restore pubspec.yaml, analysis_options.yaml, .gitignore from git (flutter create overwrites them)
git checkout -- pubspec.yaml analysis_options.yaml .gitignore
flutter pub get
dart run build_runner build -d
```

Env (ADR-0005): copy `.env.example` to `.env` (git-ignored) and run with
`flutter run --dart-define-from-file=.env`. Release builds use `.env.prod`:
`flutter build <target> --dart-define-from-file=.env.prod`. Values are compile-time constants —
**after changing `.env`, do a full restart (stop and `flutter run` again); hot reload/restart won't
pick them up.** Without the flag the app fails at startup with an `EnvConfigError` naming this
command.

Toolchain: Apple targets need **Xcode 26+** (iOS/macOS 26 SDK; `connectivity_plus` uses
`NWPath.isUltraConstrained`). CI pins Xcode 26.5 on `macos-26`. Minimums (docs/07): iOS 16, Android
API 26, macOS 12.

Fonts: download Inter (OFL) into `assets/fonts/Inter-Variable.ttf`.
Palette: `assets/design/palette.json` is generated per docs/03-ux-spec.md §1 in Milestone 1.
