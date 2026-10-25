# Adds ios/Shared (the B6 App Intents, the action queue and the snapshot
# patch, docs/09 M9.2) to both the Runner app and the DottodayWidgets
# extension, its Localizable.strings to both, and DotIntentsTests.swift to
# RunnerTests. Idempotent. Run from app/:
#   GEM_HOME=$(brew --prefix cocoapods)/libexec $(brew --prefix ruby)/bin/ruby \
#     tool/ios_add_shared_intents.rb
require 'xcodeproj'

SOURCES = %w[DotStore.swift SnapshotPatch.swift DotActions.swift DotIntents.swift].freeze
LANGUAGES = %w[en de fr es].freeze

project = Xcodeproj::Project.open('ios/Runner.xcodeproj')
targets = %w[Runner DottodayWidgets].map { |n| project.targets.find { |t| t.name == n } }
tests = project.targets.find { |t| t.name == 'RunnerTests' }

group = project.main_group['Shared'] || project.main_group.new_group('Shared', 'Shared')
SOURCES.each do |name|
  ref = group.files.find { |f| f.path == name } || group.new_file(name)
  targets.each do |t|
    t.add_file_references([ref]) unless t.source_build_phase.files_references.include?(ref)
  end
end

strings = group.children.find { |c| c.isa == 'PBXVariantGroup' && c.name == 'Localizable.strings' }
unless strings
  strings = group.new_variant_group('Localizable.strings')
  LANGUAGES.each { |l| strings.new_file("#{l}.lproj/Localizable.strings").name = l }
end
targets.each do |t|
  t.resources_build_phase.add_file_reference(strings, true)
end

test_group = project.main_group['RunnerTests']
test_ref = test_group.files.find { |f| f.path == 'DotIntentsTests.swift' } ||
           test_group.new_file('DotIntentsTests.swift')
tests.add_file_references([test_ref]) unless tests.source_build_phase.files_references.include?(test_ref)

project.save
