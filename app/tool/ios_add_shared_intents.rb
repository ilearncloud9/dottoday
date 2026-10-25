# Adds ios/Shared (the B6 App Intents, the action queue, the snapshot
# patch, docs/09 M9.2; the Live Activity's state, views and intents, M9.3)
# to both the Runner app and the DottodayWidgets
# extension, its Localizable.strings to both, and DotIntentsTests.swift to
# RunnerTests. Idempotent. Run from app/:
#   GEM_HOME=$(brew --prefix cocoapods)/libexec $(brew --prefix ruby)/bin/ruby \
#     tool/ios_add_shared_intents.rb
require 'xcodeproj'

SOURCES = %w[
  DotStore.swift SnapshotPatch.swift DotActions.swift DotIntents.swift DotTokens.swift
  TaskSymbols.swift DotActivity.swift LiveActivities.swift LiveActivityViews.swift Snapshot.swift
].freeze
# Extension-only files (the Live Activity's configuration, M9.3; controls, M9.5).
EXTENSION_SOURCES = %w[DotLiveActivity.swift DotControls.swift].freeze
# App-only files (Siri / Shortcuts phrases, M9.5: one provider per app).
APP_SOURCES = %w[DotShortcuts.swift].freeze
LANGUAGES = %w[en de fr es].freeze

project = Xcodeproj::Project.open('ios/Runner.xcodeproj')
targets = %w[Runner DottodayWidgets].map { |n| project.targets.find { |t| t.name == n } }
tests = project.targets.find { |t| t.name == 'RunnerTests' }

# Moved to Shared (M9.5): drop the extension's old reference first.
project.main_group['DottodayWidgets'].files.select { |f| SOURCES.include?(f.path) }.each do |ref|
  ref.build_files.each(&:remove_from_project)
  ref.remove_from_project
end

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

widgets_group = project.main_group['DottodayWidgets']
EXTENSION_SOURCES.each do |name|
  ref = widgets_group.files.find { |f| f.path == name } || widgets_group.new_file(name)
  extension = targets.last
  extension.add_file_references([ref]) unless extension.source_build_phase.files_references.include?(ref)
end

runner_group = project.main_group['Runner']
APP_SOURCES.each do |name|
  ref = runner_group.files.find { |f| f.path == name } || runner_group.new_file(name)
  targets.first.add_file_references([ref]) unless targets.first.source_build_phase.files_references.include?(ref)
end
phrases = runner_group.children.find { |c| c.isa == 'PBXVariantGroup' && c.name == 'AppShortcuts.strings' }
unless phrases
  phrases = runner_group.new_variant_group('AppShortcuts.strings')
  LANGUAGES.each { |l| phrases.new_file("#{l}.lproj/AppShortcuts.strings").name = l }
end
targets.first.resources_build_phase.add_file_reference(phrases, true)

test_group = project.main_group['RunnerTests']
%w[DotIntentsTests.swift LiveActivityViewsTests.swift WidgetSnapshotTests.swift].each do |name|
  next unless File.exist?("ios/RunnerTests/#{name}")
  test_ref = test_group.files.find { |f| f.path == name } || test_group.new_file(name)
  tests.add_file_references([test_ref]) unless tests.source_build_phase.files_references.include?(test_ref)
end

project.save
