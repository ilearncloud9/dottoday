# Bundles the notification sounds (assets/sounds: the alarm chime and the
# reminder set, docs/09 M6.5.4, M8.4d) into the macOS app's Resources, where
# UNNotificationSound(named:) and the Sound picker's preview find them.
# Why: the sandboxed Mac app can't write its container's Library/Sounds —
# macOS makes it a link to ~/Library/Sounds — so the copy iOS does at start
# never lands there (found in M8.5). The files stay in assets/sounds (one
# source); the project only references them. Idempotent. Run from app/:
#   GEM_HOME=$(brew --prefix cocoapods)/libexec $(brew --prefix ruby)/bin/ruby \
#     tool/xcode_add_sounds.rb
require 'xcodeproj'

SOUNDS = Dir.children('assets/sounds').select { |f| f.end_with?('.wav', '.caf') }.sort.freeze

project = Xcodeproj::Project.open('macos/Runner.xcodeproj')
runner = project.targets.find { |t| t.name == 'Runner' }
group = project.main_group['Runner']['Sounds'] || project.main_group['Runner'].new_group('Sounds')
SOUNDS.each do |name|
  ref = group.files.find { |f| f.display_name == name } ||
        group.new_reference("../assets/sounds/#{name}", :project)
  ref.name = name
  next if runner.resources_build_phase.files_references.include?(ref)

  runner.resources_build_phase.add_file_reference(ref)
end
project.save
