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

Fonts: download Inter (OFL) into `assets/fonts/Inter-Variable.ttf`.
Palette: `assets/design/palette.json` is generated per docs/03-ux-spec.md §1 in Milestone 1.
