# Adds the missions' sensor bridge (ios/Runner/MissionSensors.swift, docs/15
# §8, M17.7a) to the iOS Runner. iPhone only: the Mac runs the on-screen
# missions and never rings a Wake Up alarm. Idempotent. Run from app/:
#   GEM_HOME=$(brew --prefix cocoapods)/libexec $(brew --prefix ruby)/bin/ruby \
#     tool/xcode_add_mission_sensors.rb
require 'xcodeproj'

FILE = 'MissionSensors.swift'.freeze

ios = Xcodeproj::Project.open('ios/Runner.xcodeproj')
target = ios.targets.find { |t| t.name == 'Runner' }
group = ios.main_group['Runner']
ref = group.files.find { |f| f.path == FILE } || group.new_file(FILE)
target.add_file_references([ref]) unless target.source_build_phase.files_references.include?(ref)
ios.save
