import 'package:dottoday/domain/notifications/sound_catalogue.dart';

// Where each platform finds a catalogue sound (docs/12 §4, §5). A sound id
// never builds a path: only these, from catalogue entries.

/// The file iOS and macOS look up by name for [sound]: the first-party
/// tones as `.wav` (copied to `Library/Sounds` by `installAlarmSound`),
/// everything else as the `.caf` the build bundles (`ios/Runner/Sounds`,
/// `tool/xcode_add_sounds.rb`; `dot_alarm.caf` is copied like the tones).
String appleSoundFile(CatalogueSound sound) =>
    sound.category == SoundCategory.dottoday
    ? '${sound.file}.wav'
    : '${sound.file}.caf';

/// The Android raw resource of [sound] (`res/raw/<file>.*`, kept through
/// shrinking by `keep.xml`).
String androidSoundResource(CatalogueSound sound) => sound.file;

/// The Flutter asset the web plays for [sound]: the first-party `.wav`
/// tones, else the build's `.m4a` (Safari and Chrome both play AAC).
String webSoundAsset(CatalogueSound sound) =>
    sound.category == SoundCategory.dottoday
    ? 'assets/sounds/${sound.file}.wav'
    : 'assets/sounds/${sound.file}.m4a';
