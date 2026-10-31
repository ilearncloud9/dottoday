# Bundles the notification sounds into the Apple apps' Resources, where
# UNNotificationSound(named:) and the Sound picker's preview find them.
#
# macOS: the alarm chime and the first-party reminder set (assets/sounds,
# docs/09 M6.5.4, M8.4d) plus the catalogue's .caf files (ios/Runner/Sounds,
# docs/12 §4). Why: the sandboxed Mac app can't write its container's
# Library/Sounds — macOS makes it a link to ~/Library/Sounds — so the copy
# iOS does at start never lands there (found in M8.5).
# iOS: every catalogue sound's .caf, the first-party tones included, so each
# is in the app bundle where AlarmKit can play it (docs/15-wake-up.md); the
# first-party start-up copy to Library/Sounds stays too (docs/12 §4).
# macOS already bundles the first-party files from assets/sounds, so a
# catalogue .caf of the same name isn't added twice.
#
# The files stay where the build writes them (one source); the projects only
# reference them. Idempotent. Run from app/:
#   GEM_HOME=$(brew --prefix cocoapods)/libexec $(brew --prefix ruby)/bin/ruby \
#     tool/xcode_add_sounds.rb
require 'xcodeproj'

FIRST_PARTY = Dir.children('assets/sounds').select { |f| f.end_with?('.wav', '.caf') }.sort.freeze
CATALOGUE = Dir.children('ios/Runner/Sounds').select { |f| f.end_with?('.caf') }.sort.freeze

# Adds each [name => path relative to the project's directory] to the Runner
# target's Resources, under Runner/Sounds in the project navigator.
def bundle(project_path, files)
  project = Xcodeproj::Project.open(project_path)
  runner = project.targets.find { |t| t.name == 'Runner' }
  group = project.main_group['Runner']['Sounds'] || project.main_group['Runner'].new_group('Sounds')
  files.each do |name, path|
    ref = group.files.find { |f| f.display_name == name } || group.new_reference(path, :project)
    ref.name = name
    next if runner.resources_build_phase.files_references.include?(ref)

    runner.resources_build_phase.add_file_reference(ref)
  end
  project.save
end

bundle('macos/Runner.xcodeproj',
       (CATALOGUE - FIRST_PARTY).to_h { |n| [n, "../ios/Runner/Sounds/#{n}"] }
         .merge(FIRST_PARTY.to_h { |n| [n, "../assets/sounds/#{n}"] }))
bundle('ios/Runner.xcodeproj', CATALOGUE.to_h { |n| [n, "Runner/Sounds/#{n}"] })
