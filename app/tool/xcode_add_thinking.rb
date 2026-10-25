# Adds the on-device model bridge (ios/Runner/ThinkingBridge.swift, docs/09
# M10.1) to the iOS Runner and, as the same file, to the macOS Runner.
# Idempotent. Run from app/:
#   GEM_HOME=$(brew --prefix cocoapods)/libexec $(brew --prefix ruby)/bin/ruby \
#     tool/xcode_add_thinking.rb
require 'xcodeproj'

FILE = 'ThinkingBridge.swift'.freeze

ios = Xcodeproj::Project.open('ios/Runner.xcodeproj')
target = ios.targets.find { |t| t.name == 'Runner' }
group = ios.main_group['Runner']
ref = group.files.find { |f| f.path == FILE } || group.new_file(FILE)
target.add_file_references([ref]) unless target.source_build_phase.files_references.include?(ref)
ios.save

mac = Xcodeproj::Project.open('macos/Runner.xcodeproj')
target = mac.targets.find { |t| t.name == 'Runner' }
group = mac.main_group['Runner']
path = "../../ios/Runner/#{FILE}"
ref = group.files.find { |f| f.path == path } || group.new_reference(path)
ref.name = FILE
target.add_file_references([ref]) unless target.source_build_phase.files_references.include?(ref)
mac.save
